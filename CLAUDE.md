# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains Docker configurations for creating browser-based cloud shell environments for CyVerse Discovery Environment. It provides various terminal interfaces (bash, zsh) and specialized environments (KASM, Landisii, ParFlow) that run in containers with ttyd for browser access.

## Build Commands

### Build Docker Images Locally

```bash
# Build bash variant (primary, includes Claude Code)
cd bash && docker build -t cli:bash .

# Build zsh variant (Ubuntu 20.04 base)
cd zsh && docker build -t cli:zsh .

# Build other specialized variants
cd kasm && docker build -t cli:kasm .
cd landisii && docker build -t cli:landisii .
cd parflow && docker build -t cli:parflow .
```

### Test Images Locally

```bash
# Run bash variant
docker run -it -p 7681:7681 cli:bash

# Run from Harbor registry
docker run -it --rm -p 7681:7681 harbor.cyverse.org/vice/cli/bash:latest
```

Access the terminal at: http://localhost:7681

## Architecture Overview

### Directory Structure
- **bash/**: Main cloud shell with Jupyter base, Claude Code pre-installed, and comprehensive tooling
- **zsh/**: Alternative shell with zsh and oh-my-zsh configuration
- **kasm/**: Desktop environment with KasmVNC for GUI applications
- **landisii/**: Specialized environment for Landis-II ecological modeling
- **parflow/**: Environment for ParFlow hydrological modeling
- **xenial/**: Legacy Ubuntu 16.04 base (deprecated)

### Core Components

1. **Base Images**:
   - bash uses `quay.io/jupyter/minimal-notebook:latest` (Ubuntu 24.04)
   - Others use various Ubuntu bases (20.04, 22.04)

2. **Terminal Access**: All variants use `ttyd` for browser-based terminal access on port 7681

3. **Process Management**: `tini` is used as init process to handle signal forwarding and zombie reaping

4. **Session Management**: `tmux` provides persistent sessions and multiplexing

5. **Entry Point**: `entry.sh` script handles:
   - iRODS environment configuration
   - MCP server configuration for Claude Code
   - User profile setup (AWS, SSH, Git configs)
   - Session initialization

### Key Technologies

- **ttyd**: WebSocket terminal server for browser access
- **tmux**: Terminal multiplexer for session persistence
- **MiniConda/Mamba**: Python environment management
- **GoCommands**: CyVerse data management tools
- **iRODS iCommands**: Data store integration
- **Claude Code**: AI coding assistant (bash variant only)
- **Git Credential Manager**: Secure credential storage

## CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/harbor.yml`):
- Triggers on pushes to main branch
- Builds and pushes Docker images to Harbor registry
- Currently only builds bash variant
- Uses Docker Buildx with layer caching

## Environment Variables

Key variables used in containers:
- `IPLANT_USER`: CyVerse username for iRODS configuration
- `TZ`: Timezone (default: America/Phoenix)
- `GCM_CREDENTIAL_STORE`: Git credential storage method

## Development Notes

### Adding New Variants
1. Create new directory with Dockerfile
2. Include required components: ttyd, tini, tmux
3. Add entry script for initialization
4. Update GitHub Actions workflow if automated builds needed

### Modifying Existing Images
- Test changes locally before committing
- Ensure ttyd port (7681) remains exposed
- Maintain compatibility with CyVerse VICE environment
- Keep entry.sh script updated for initialization tasks

### Integration Points
- **CyVerse Data Store**: Mounted at `/home/jovyan/data-store` (bash) or `/home/user/data-store`
- **iRODS**: Configuration auto-generated from environment variables
- **MCP Server**: Provides file system access for Claude Code