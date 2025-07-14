FROM jupyter/minimal-notebook:latest

LABEL org.label-schema.name="CyVerse VICE Cloud Shell" \
      org.label-schema.description="Built from Ubuntu 24.04 w/ MiniConda3" \
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
    echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    rm -rf /var/lib/apt/lists/*

# Install Tini
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

RUN apt-get update && \
    apt-get install -y curl grep sed dpkg && \
    curl -L "https://github.com/krallin/tini/releases/download/v0.19.0/tini_0.19.0-amd64.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget -q -c https://dl.google.com/go/go1.24.5.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local

# install ttyd
RUN curl -L "https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64" > ttyd && \
    chmod a+x ttyd && \
    mv ttyd /usr/local/bin/ttyd

# getting locales error
RUN apt-get clean && apt-get update && apt-get install locales && locale-gen en_US.UTF-8

# Install GoCommands
# https://learning.cyverse.org/ds/gocommands/
RUN cd /usr/local/bin && \
    GOCMD_VER=$(curl -L -s https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt); \
    curl -L -s https://github.com/cyverse/gocommands/releases/download/${GOCMD_VER}/gocmd-${GOCMD_VER}-linux-amd64.tar.gz | tar zxvf -

# update terminal message
RUN apt-get update && apt install lolcat neofetch figlet w3m-img imagemagick -y
ENV PATH=${PATH}:/usr/games
COPY 01-custom /etc/motd
RUN chmod +x /etc/motd

# install git-credential-manager 
RUN wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.6.1/gcm-linux_amd64.2.6.1.deb

RUN sudo dpkg -i gcm-linux_amd64.2.6.1.deb

# set the ENV for the credential type
ENV GCM_CREDENTIAL_STORE=cache

USER jovyan

RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc 

# Set message of the day on terminal start for both bash and zsh
RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && /etc/motd' >> ~/.bashrc

# set path for Go 
ENV PATH=$PATH:/usr/local/go/bin

# set shell as bash and terminal as linux
ENV SHELL=bash
ENV TERM=xterm

# open port 7681 for ttyd
EXPOSE 7681

#set working directory
WORKDIR /home/jovyan/data-store

# changes tmux layout while running
COPY entry.sh /bin
RUN echo 'set-option -g status off' >> ~/.tmux.conf

# add iRODS iCommands to user profile as JSON
RUN mkdir /home/jovyan/.irods 

# activate base Python environment using mamba
COPY environment.yml /home/jovyan/ 
RUN mamba env create -f /home/jovyan/environment.yml

# using ~/.bash_profile instead of ~/.bashrc for non-interactive tty (-it) containers
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/jovyan/.bash_profile && \
    echo "conda activate geospatial" >> /home/jovyan/.bash_profile

# Ensure that gocmd is up to date.
RUN echo $'\n# upgrade GoCommands\nsudo gocmd upgrade > /dev/null' >> /home/jovyan/.bashrc

RUN sudo groupadd --gid 1000 jovyan

ENTRYPOINT ["bash", "/bin/entry.sh"]

CMD ["ttyd", "bash"]
