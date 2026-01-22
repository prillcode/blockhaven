---
spec_id: 03
story_id: 03
epic_id: 003
title: Contact Form Endpoint with Discord Integration
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 03: Contact Form Endpoint with Discord Integration

## Overview
Create POST /api/contact endpoint that validates input and sends to Discord webhook.

## Files to Create
```
src/routes/contact.ts
src/utils/discord-webhook.ts
src/types/contact.ts
```

## Implementation

### src/types/contact.ts
```typescript
export interface ContactFormData {
  name: string;
  email: string;
  subject: string;
  message: string;
}

export interface ValidationError {
  field: string;
  message: string;
}
```

### src/utils/discord-webhook.ts
```typescript
const WEBHOOK_URL = process.env.DISCORD_WEBHOOK_URL;

if (!WEBHOOK_URL) {
  console.warn('⚠️  DISCORD_WEBHOOK_URL not set - contact form will not work');
}

export async function sendToDiscord(data: {
  name: string;
  email: string;
  subject: string;
  message: string;
}): Promise<boolean> {
  if (!WEBHOOK_URL) {
    throw new Error('Discord webhook URL not configured');
  }

  const embed = {
    title: `📬 Contact Form: ${data.subject}`,
    color: 0x5dcce3, // Minecraft diamond blue
    fields: [
      { name: 'From', value: data.name, inline: true },
      { name: 'Email', value: data.email, inline: true },
      { name: 'Subject', value: data.subject, inline: false },
      { name: 'Message', value: data.message, inline: false },
    ],
    timestamp: new Date().toISOString(),
    footer: { text: 'BlockHaven Contact Form' },
  };

  try {
    const response = await fetch(WEBHOOK_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ embeds: [embed] }),
    });

    if (!response.ok) {
      console.error('Discord webhook failed:', response.status);
      return false;
    }

    return true;
  } catch (error) {
    console.error('Error sending to Discord:', error);
    return false;
  }
}
```

### src/routes/contact.ts
```typescript
import { Hono } from 'hono';
import { sendToDiscord } from '../utils/discord-webhook';
import type { ContactFormData, ValidationError } from '../types/contact';

const contact = new Hono();

function validateContactForm(data: any): ValidationError[] {
  const errors: ValidationError[] = [];

  if (!data.name || data.name.trim().length < 2) {
    errors.push({ field: 'name', message: 'Name must be at least 2 characters' });
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!data.email || !emailRegex.test(data.email)) {
    errors.push({ field: 'email', message: 'Valid email is required' });
  }

  if (!data.subject || data.subject.trim().length < 3) {
    errors.push({ field: 'subject', message: 'Subject must be at least 3 characters' });
  }

  if (!data.message || data.message.trim().length < 10) {
    errors.push({ field: 'message', message: 'Message must be at least 10 characters' });
  }

  // Max lengths
  if (data.name && data.name.length > 100) {
    errors.push({ field: 'name', message: 'Name too long (max 100)' });
  }

  if (data.subject && data.subject.length > 200) {
    errors.push({ field: 'subject', message: 'Subject too long (max 200)' });
  }

  if (data.message && data.message.length > 2000) {
    errors.push({ field: 'message', message: 'Message too long (max 2000)' });
  }

  return errors;
}

contact.post('/', async (c) => {
  const body = await c.req.json();

  // Validate
  const errors = validateContactForm(body);
  if (errors.length > 0) {
    return c.json({ error: 'Validation failed', errors }, 400);
  }

  // Send to Discord
  const success = await sendToDiscord({
    name: body.name.trim(),
    email: body.email.trim(),
    subject: body.subject.trim(),
    message: body.message.trim(),
  });

  if (!success) {
    return c.json({ error: 'Failed to send message. Please try again.' }, 500);
  }

  return c.json({ success: true, message: 'Message sent successfully' });
});

export default contact;
```

### Update src/index.ts
```typescript
// Add import
import contact from './routes/contact';

// Add route
app.route('/api/contact', contact);
```

## Testing with curl
```bash
# Valid submission
curl -X POST http://localhost:3001/api/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","subject":"Test","message":"This is a test message from the API"}'

# Invalid email
curl -X POST http://localhost:3001/api/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"invalid","subject":"Test","message":"Test message"}'
```

## Testing Checklist
- [ ] Valid submissions return 200 and message appears in Discord
- [ ] Missing name returns 400 validation error
- [ ] Invalid email format returns 400
- [ ] Short message (<10 chars) returns 400
- [ ] Long message (>2000 chars) returns 400
- [ ] Discord embed formatted correctly
- [ ] Webhook failures handled gracefully

## Dependencies
**Depends on:** Spec 01 (Hono server)
**Enables:** Epic 004 ContactForm widget

---

**Next:** `/dev-story .storyline/specs/epic-003/spec-03-contact-form-endpoint.md`
