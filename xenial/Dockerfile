FROM ubuntu:16.04

LABEL org.label-schema.name="CyVerse VICE WebShell" \
      org.label-schema.description="Built from Ubuntu 16.04 w/ MiniConda3" \
      org.label-schema.url="https://cyverse.org" \
      org.label-schema.vcs-url="e.g. https://github.com/cyverse-vice/cli" \
      org.label-schema.vendor="CyVerse" \
      org.label-schema.schema-version="1.0.0"

USER root

# Add sudo to user
RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
ARG LOCAL_USER=user
ARG PRIV_CMDS='/bin/ch*,/bin/cat,/bin/gunzip,/bin/tar,/bin/mkdir,/bin/ps,/bin/mv,/bin/cp,/usr/bin/apt*,/usr/bin/pip*,/bin/yum'

RUN adduser --disabled-password --gecos "VICE_User" --uid 1000 user  && \
    usermod -aG sudo user && \
    echo "$LOCAL_USER ALL=NOPASSWD: $PRIV_CMDS" >> /etc/sudoers

# Install MiniConda and Tini
ENV TZ America/Phoenix
ENV LANG=C.UTF-8 
ENV LC_ALL "en_US.UTF-8"
ENV PATH /opt/conda/bin:$PATH
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    gettext-base git mercurial subversion \
    tmux && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/user/.bashrc && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/user/.zshrc && \
    chown -R user:user /opt/conda

RUN apt-get update && \
    apt-get install -y curl grep sed dpkg && \
    curl -L "https://github.com/krallin/tini/releases/download/v0.19.0/tini_0.19.0-amd64.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install a few dependencies for iCommands, text editing, and monitoring instances
RUN apt-get update && \
    apt-get install -y lsb-release apt-transport-https curl gnupg2 libfuse2 gcc less nodejs software-properties-common apt-utils glances htop nano  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y vim-nox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y emacs-nox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add - && \
    echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/renci-irods.list && \
    apt-get update && \
    apt install -y irods-icommands 
    
# install ttyd
RUN curl -L "https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64" > ttyd && \
    chmod a+x ttyd && \
    mv ttyd /usr/local/bin/ttyd

# Install ZSH shell
RUN apt-get update && \
    apt-get install -y zsh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# getting locales error
RUN apt-get clean && apt-get update && apt-get install locales && locale-gen en_US.UTF-8

# Install CyberDuck CLI
RUN echo "deb https://s3.amazonaws.com/repo.deb.cyberduck.io stable main" > /etc/apt/sources.list.d/cyberduck.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FE7097963FEFBE72 && \
    apt-get update && \
    apt-get install duck

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt update && \
    apt install gh

# update terminal message
RUN add-apt-repository ppa:dawidd0811/neofetch
RUN apt-get update && apt install neofetch figlet lolcat cowsay fortune w3m-img imagemagick -y
ENV PATH=${PATH}:/usr/games
COPY 01-custom /etc/motd
RUN chmod +x /etc/motd

# ready to set user 
USER user

# Install OhMyZSH theme
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set message of the day on terminal start for both bash and zsh
RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && /etc/motd' >> ~/.zshrc
RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && /etc/motd' >> ~/.bashrc

# set path for Go and Rust
ENV PATH=$PATH:/usr/local/go/bin:/home/user/.cargo/bin
ENV rustup completions bash > ~/.local/share/bash-completion/completions/rustup

# set shell as bash and terminal as linux
ENV SHELL=bash
ENV TERM=xterm

# open port 7681 for ttyd
EXPOSE 7681

#set working directory
WORKDIR /home/user

# changes tmux layout while running
COPY entry.sh /bin
RUN echo 'set-option -g status off' >> ~/.tmux.conf

# add iRODS iCommands to user profile as JSON
RUN mkdir /home/user/.irods 

ENTRYPOINT ["bash", "/bin/entry.sh"]

CMD ["ttyd", "bash"]
