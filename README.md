[![Project Supported by CyVerse](https://de.cyverse.org/Powered-By-CyVerse-blue.svg)](https://learning.cyverse.org/projects/vice/en/latest/) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) [![license](https://img.shields.io/badge/license-GPLv3-blue.svg)](https://opensource.org/licenses/GPL-3.0)

# Cloud Shell

Browser-based interactive terminal for use in [CyVerse Discovery Environment](https://learning.cyverse.org/vice/about/) Featured Apps listing.

[![Harbor Build Status](https://github.com/cyverse-vice/cli/actions/workflows/harbor.yml/badge.svg)](https://github.com/cyverse-vice/cli/actions) ![GitHub commits since tagged version](https://img.shields.io/github/commits-since/cyverse-vice/cli/latest/main?style=flat-square)

## Quick Launch

| Version | Instant Launch | Regular Launch |
|---------|----------------|----------------|
| 24.04 | <a href="https://de.cyverse.org/instantlaunch/77c2a01e-60b9-11f0-b966-008cfa5ae621" target="_blank" rel="noopener noreferrer"><img src="https://de.cyverse.org/Powered-By-CyVerse-blue.svg"></a> | <a href="https://de.cyverse.org/apps/de/5f2f1824-57b3-11ec-8180-008cfa5ae621/versions/52fbf0a0-60b9-11f0-9c1d-008cfa5ae621/launch" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/Cloud%20Shell-24.04-green?style=plastic&logo=ubuntu"></a> |
| gpu-24.04 | <a href="https://de.cyverse.org/instantlaunch/c99a981e-7eab-11f0-94d3-008cfa5ae621" target="_blank" rel="noopener noreferrer"><img src="https://de.cyverse.org/Powered-By-CyVerse-blue.svg"></a> | <a href="https://de.cyverse.org/apps/de/5f2f1824-57b3-11ec-8180-008cfa5ae621/versions/33e7f454-7d04-11f0-82b5-008cfa5ae621/launch" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/Cloud%20Shell-gpu--24.04-green?style=plastic&logo=ubuntu"></a> |

## Features

This cloud shell environment includes:

### AI Development Tools
- **Claude Code** - Anthropic AI coding assistant (`claude`)
- **Gemini CLI** - Google AI CLI (`gemini`)
- **OpenAI Codex** - OpenAI coding assistant (`codex`)
- **Node.js 20.x** - JavaScript runtime for AI tools

### Development Tools
- **GitHub CLI (`gh`)** - Command-line tool for GitHub operations
- **Git Credential Manager** - Secure credential storage
- **Go** - Go programming language
- **AWS CLI** - Amazon Web Services CLI

### CyVerse Integration
- **GoCommands (`gocmd`)** - CyVerse data transfer utilities
- **iRODS iCommands** - Direct access to CyVerse Data Store

### System Utilities
- **ttyd** - Browser-based terminal access (port 7681)
- **tmux** - Terminal multiplexer for persistent sessions
- **MiniConda/Mamba** - Python environment management
- **Monitoring** - htop, glances for system monitoring
- **Text editors** - nano, vim, emacs

## Run Locally

```bash
# Clone and build
git clone https://github.com/cyverse-vice/cli.git
cd cli/bash
docker build -t cli:bash .

# Run container
docker run -it -p 7681:7681 cli:bash
```

Access the terminal at: http://localhost:7681

## Run from Harbor Registry

```bash
docker run -it --rm -p 7681:7681 harbor.cyverse.org/vice/cli/bash:latest
```

## Build Your Own Container

```dockerfile
FROM harbor.cyverse.org/vice/cli/bash:latest

# Add your customizations
RUN apt-get update && apt-get install -y your-package
```

## Available Variants

| Variant | Description |
|---------|-------------|
| bash | Main cloud shell with AI tools (recommended) |
| zsh | Alternative shell with zsh and oh-my-zsh |
| kasm | Desktop environment with KasmVNC |
| landisii | Landis-II ecological modeling |
| parflow | ParFlow hydrological modeling |

## Resources

- [CyVerse VICE Documentation](https://learning.cyverse.org/vice/about/)
- [Integrate Your Own Tools](https://learning.cyverse.org/de/create_apps/)
- [GoCommands Documentation](https://learning.cyverse.org/ds/gocommands/)
