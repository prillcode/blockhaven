# BlockHaven

Family-friendly, anti-griefer Minecraft server with cross-platform support (Java + Bedrock).

**Domain:** [blockhaven.gg](https://blockhaven.gg)

## Structure

```
├── mc-server/   # Minecraft server (Docker + Paper + plugins)
└── web/         # Marketing website (React/Vue)
```

## Quick Start

```bash
cd mc-server
cp .env.example .env
# Edit .env with your settings
docker-compose up -d
```

## Features

- Cross-platform play (Java + Bedrock via Geyser)
- Multiple worlds (Survival Easy, Survival Hard, Creative, Resource)
- Land claims (GriefPrevention)
- Player economy with jobs and shops
- Premium private worlds for subscribers

## Links

- [Server Documentation](./mc-server/docs/)
- [Tebex Store](https://store.blockhaven.gg) *(coming soon)*
- [Discord](https://discord.gg/blockhaven) *(coming soon)*

## License

Private project. All rights reserved.
