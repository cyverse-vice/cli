[![Project Supported by CyVerse](https://de.cyverse.org/Powered-By-CyVerse-blue.svg)](https://learning.cyverse.org/projects/vice/en/latest/) [![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) [![harbor](https://github.com/cyverse-vice/cli/actions/workflows/harbor.yml/badge.svg?branch=main)](https://github.com/cyverse-vice/cli/actions/workflows/harbor.yml)

# Cloud Shell

## Instructions

Launch in CyVerse with a verified user account (free):

quick launch | size | 
------------ | ---- | 
<a href="" target="_blank"><img src="https://img.shields.io/badge/Ubuntu%2020.04-bash-red?style=plastic&logo=ubuntu"></a> | 
<a href="" target="_blank"><img src="https://img.shields.io/badge/Ubuntu%2020.04-zsh-teal?style=plastic&logo=ubuntu"></a> | 

Shell with BASH and ZSH command line interface (CLI). Intended for running shell commands on [CyVerse VICE](https://learning.cyverse.org/projects/vice/en/latest/).

Uses `tini` and `ttyd` to run a terminal in a browser.

Built with an Ubuntu 20.04 base, also includes MiniConda `conda`, `python`, `go`, and iRODS `icommands`

Text editors include `emacs`, `nano`, `vi`, & `vim`

Monitors include `top`, `htop`, & `glances`

To build and run the container locally:

```
git clone https://github.com/cyverse-vice/cli.git
cd cli/zsh
docker build -t cli:focal-zsh .
docker run -it -p 7681:7861 cli:focal-zsh
```
### testing

To test locally

```
docker run -it --rm -p 7681:7681 harbor.cyverse.org/vice/cli/bash:latest
```
To port and build your own version of this container, you can use the hosted version from [CyVerse Harbor](https://harbor.cyverse.org/harbor/projects/17/repositories/cli)

To your own Dockerfile, add:

```
FROM harbor.cyverse.org/vice/cli/bash:latest
```
