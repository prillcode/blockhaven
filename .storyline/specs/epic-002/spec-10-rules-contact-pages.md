---
spec_id: 10
story_id: 10
epic_id: 002
title: Rules & Contact Pages
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 10: Rules & Contact Pages

## Overview
Create Rules page with full rules list and Contact page with FAQ.

## Files to Create
```
src/pages/Rules.tsx
src/pages/Contact.tsx
```

## Implementation Summary

### Rules.tsx
```typescript
import { Helmet } from 'react-helmet-async';
import { rules } from '@/data/rules';
import { Card } from '@/components/ui';

export function Rules() {
  return (
    <>
      <Helmet>
        <title>Server Rules - BlockHaven</title>
        <meta name="description" content="BlockHaven server rules and guidelines" />
      </Helmet>

      <div className="container mx-auto px-4 py-16">
        <h1 className="text-5xl font-bold text-center mb-12">Server Rules</h1>
        <div className="max-w-3xl mx-auto space-y-6">
          {rules.map((rule) => (
            <Card key={rule.id}>
              <div className="flex gap-4">
                <span className="text-2xl font-bold text-primary-500">{rule.id}</span>
                <div>
                  <h3 className="text-xl font-bold mb-2">{rule.title}</h3>
                  <p className="text-gray-600 dark:text-gray-300 mb-3">{rule.description}</p>
                  {rule.examples && (
                    <ul className="space-y-1">
                      {rule.examples.map((ex, i) => (
                        <li key={i} className="text-sm text-gray-500">• {ex}</li>
                      ))}
                    </ul>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      </div>
    </>
  );
}
```

### Contact.tsx
```typescript
import { Helmet } from 'react-helmet-async';
import { Card } from '@/components/ui';

export function Contact() {
  const faqs = [
    { q: 'How do I join the server?', a: 'Copy the IP 5.161.69.191:25565 and add it to your Minecraft server list.' },
    { q: 'What version is the server?', a: 'Paper 1.21.11 - works with Java and Bedrock editions.' },
    { q: 'Can I play on mobile?', a: 'Yes! Bedrock Edition (mobile, console, Windows 10) is fully supported.' },
    { q: 'How do I claim land?', a: 'Use a golden shovel to claim land corners. Right-click first corner, then second corner.' },
  ];

  return (
    <>
      <Helmet>
        <title>Contact - BlockHaven</title>
      </Helmet>

      <div className="container mx-auto px-4 py-16">
        <h1 className="text-5xl font-bold text-center mb-12">Contact & FAQ</h1>
        
        <Card className="max-w-2xl mx-auto mb-8">
          <h2 className="text-2xl font-bold mb-4">Contact Form</h2>
          <p className="text-gray-600 dark:text-gray-300">
            Contact form will be available soon. For now, please join our Discord server.
          </p>
        </Card>

        <div className="max-w-2xl mx-auto space-y-4">
          <h2 className="text-3xl font-bold mb-6">Frequently Asked Questions</h2>
          {faqs.map((faq, i) => (
            <Card key={i}>
              <h3 className="font-bold mb-2">{faq.q}</h3>
              <p className="text-gray-600 dark:text-gray-300">{faq.a}</p>
            </Card>
          ))}
        </div>
      </div>
    </>
  );
}
```

## Dependencies
**Depends on:** Specs 01, 02

---

**Next:** `/dev-story .storyline/specs/epic-002/spec-10-rules-contact-pages.md`
