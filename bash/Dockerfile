FROM quay.io/jupyter/minimal-notebook:latest

LABEL org.label-schema.name="CyVerse VICE Cloud Shell" \
      org.label-schema.description="Built from Ubuntu 24.04 w/ MiniConda3" \
      org.label-schema.url="https://cyverse.org" \
      org.label-schema.vcs-url="e.g. https://github.com/cyverse-vice/cli" \
      org.label-schema.vendor="CyVerse" \
      org.label-schema.schema-version="1.0.0"

USER root

# Add sudo to user
ARG LOCAL_USER=user

RUN apt-get update && \
    apt-get install -y sudo && \
    echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    apt-get clean && \
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
    tmux curl grep sed dpkg && \
    curl -L "https://github.com/krallin/tini/releases/download/v0.19.0/tini_0.19.0-amd64.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget -q -c https://dl.google.com/go/go1.25.4.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local

# install ttyd
RUN curl -L "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64" > ttyd && \
    chmod a+x ttyd && \
    mv ttyd /usr/local/bin/ttyd

# Install remaining packages: locales, terminal tools, s3fs, Node/NPM
RUN apt-get update && \
    apt-get install -y locales lolcat neofetch figlet w3m-img imagemagick s3fs fuse nodejs npm && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install GoCommands
# https://learning.cyverse.org/ds/gocommands/
RUN cd /usr/local/bin && \
    GOCMD_VER=$(curl -L -s https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt); \
    curl -L -s https://github.com/cyverse/gocommands/releases/download/${GOCMD_VER}/gocmd-${GOCMD_VER}-linux-amd64.tar.gz | tar zxvf -

# update terminal message
ENV PATH=${PATH}:/usr/games
COPY 01-custom /etc/motd
RUN chmod +x /etc/motd

# install git-credential-manager
RUN wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.6.1/gcm-linux_amd64.2.6.1.deb && \
    # Use 'apt-get install' with the local file path to handle dependencies automatically
    apt-get install -y ./gcm-linux_amd64.2.6.1.deb && \
    # Clean up the downloaded file
    rm gcm-linux_amd64.2.6.1.deb

# install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update && \
    rm -rf awscliv2.zip

# Configure FUSE for non-root users and create OSN directory
RUN echo "user_allow_other" >> /etc/fuse.conf && \
    chmod 644 /etc/fuse.conf && \
    mkdir -p /osn && \
    chmod 755 /osn && \
    chown 1000:100 /osn

# set the ENV for the credential type
ENV GCM_CREDENTIAL_STORE=cache

# Copy scripts while still root and set permissions
COPY entry.sh /bin
COPY osn-mount.sh /usr/local/bin/
RUN chmod +x /bin/entry.sh && \
    chmod +x /usr/local/bin/osn-mount.sh

USER jovyan

# Install Claude Code, OpenAI Codex, and Google Gemini CLI
RUN npm config set prefix /home/jovyan/.npm-global && \
    export PATH=/home/jovyan/.npm-global/bin:$PATH && \
    npm install -g @anthropic-ai/claude-code @openai/codex @google/gemini-cli

# Configure bashrc
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo '[ ! -z "$TERM" -a -r /etc/motd ] && /etc/motd' >> ~/.bashrc && \
    echo $'\n# upgrade GoCommands\nsudo gocmd upgrade > /dev/null' >> ~/.bashrc

# set path for Go and NPM
ENV PATH=$PATH:/usr/local/go/bin:/home/jovyan/.npm-global/bin

# set shell as bash and terminal as linux
ENV SHELL=bash
ENV TERM=xterm

# open port 7681 for ttyd
EXPOSE 7681

#set working directory
WORKDIR /home/jovyan/data-store

# Configure tmux and create iRODS directory
RUN echo 'set-option -g status off' >> ~/.tmux.conf && \
    mkdir /home/jovyan/.irods

# activate base Python environment using mamba
COPY environment.yml /home/jovyan/
RUN mamba env create -f /home/jovyan/environment.yml

# Configure bash_profile for non-interactive tty containers
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/jovyan/.bash_profile && \
    echo "conda activate geospatial" >> /home/jovyan/.bash_profile

ENTRYPOINT ["bash", "/bin/entry.sh"]

CMD ["ttyd", "bash"]
