[![Project Supported by CyVerse](https://de.cyverse.org/Powered-By-CyVerse-blue.svg)](https://learning.cyverse.org/projects/vice/en/latest/) [![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) [![license](https://img.shields.io/badge/license-GPLv3-blue.svg)](https://opensource.org/licenses/GPL-3.0) 

# Cloud Shell

Browser based interactive terminal for use in [CyVere Discovery Environment](https://learning.cyverse.org/vice/about/) Featured Apps listing. 

## Developer Instructions

Up to date as of: 03/05/2025

Launch in CyVerse with a [verified user account (free)](https://user.cyverse.org):

[![!Harbor](https://github.com/cyverse-vice/cli/actions/workflows/harbor.yml/badge.svg)](https://github.com/cyverse-vice/cli/actions) ![GitHub commits since tagged version](https://img.shields.io/github/commits-since/cyverse-vice/cli/latest/main?style=flat-square) 

[![quicklaunch](https://img.shields.io/badge/Ubuntu%2020.04-bash-red?style=plastic&logo=ubuntu)](https://de.cyverse.org/apps/de/5f2f1824-57b3-11ec-8180-008cfa5ae621/launch)

Shell with BASH and ZSH command line interface (CLI). Intended for running shell commands on [CyVerse VICE](https://learning.cyverse.org/vice/extend_apps/).

Uses `tini` and `ttyd` to run a terminal in a browser.

Built with an Ubuntu 20.04 base, also includes MiniConda `conda`, `python`, `go`, and iRODS `icommands`

Text editors include `emacs`, `nano`, `vi`, & `vim`

Monitors include `top`, `htop`, & `glances`

To build and run the image locally:

```
git clone https://github.com/cyverse-vice/cli.git
cd cli/zsh
docker build -t cli:zsh .
docker run -it -p 7681:7861 cli:zsh
```

Test from [CyVerse Harbor](https://harbor.cyverse.org/harbor/projects/17/repositories/cli%2Fbash):

```
docker run -it --rm -p 7681:7681 harbor.cyverse.org/vice/cli/bash:latest
```

To build your own version of this image, you can use the hosted version:

```
FROM harbor.cyverse.org/vice/cli/bash:latest
```

[Integrate your own Containers and Apps into CyVerse](https://learning.cyverse.org/de/create_apps/)
