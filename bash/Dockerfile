FROM ubuntu:20.04

LABEL org.label-schema.name="CyVerse VICE Cloud Shell" \
      org.label-schema.description="Built from Ubuntu 22.04 w/ MiniConda3" \
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

RUN apt-get update && \
    apt-get install -y sudo && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    rm -rf /var/lib/apt/lists/*

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

# Install Go
RUN wget -q -c https://dl.google.com/go/go1.16.4.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local

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

# Install GoCommands
# https://learning.cyverse.org/ds/gocommands/
RUN cd /usr/local/bin && \
    GOCMD_VER=$(curl -L -s https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt); \
    curl -L -s https://github.com/cyverse/gocommands/releases/download/${GOCMD_VER}/gocmd-${GOCMD_VER}-linux-amd64.tar.gz | tar zxvf -

# update terminal message
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

# set path for Go 
ENV PATH=$PATH:/usr/local/go/bin

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

# install mamba
RUN conda install -c conda-forge mamba

ENTRYPOINT ["bash", "/bin/entry.sh"]

CMD ["ttyd", "bash"]
