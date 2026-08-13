FROM quay.io/jupyter/minimal-notebook:latest

LABEL org.label-schema.name="CyVerse VICE Cloud Shell" \
      org.label-schema.description="Built from Ubuntu 24.04 w/ MiniConda3" \
      org.label-schema.url="https://cyverse.org" \
      org.label-schema.vcs-url="https://github.com/cyverse-vice/cli" \
      org.label-schema.vendor="CyVerse" \
      org.label-schema.schema-version="1.0.0"

USER root

# Add sudo to user
ARG LOCAL_USER=jovyan

# Create group 1000 if it doesn't exist (CyVerse VICE may assign this GID)
RUN getent group 1000 || groupadd -g 1000 jovyan-group && \
    usermod -a -G 1000 jovyan

RUN apt-get update && \
    apt-get install -y sudo && \
    echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Tini
ENV TZ=America/Phoenix
ENV LANG=C.UTF-8 
ENV LC_ALL="en_US.UTF-8"
ENV PATH=/opt/conda/bin:$PATH
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
RUN wget -q -c https://dl.google.com/go/go1.25.5.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local

# install ttyd
RUN curl -L "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64" > ttyd && \
    chmod a+x ttyd && \
    mv ttyd /usr/local/bin/ttyd

# Install remaining packages: locales, terminal tools, s3fs, Node/NPM
RUN apt-get update && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y locales lolcat neofetch figlet w3m-img imagemagick s3fs fuse nodejs socat bubblewrap && \
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
RUN wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.7.3/gcm-linux-x64-2.7.3.deb && \
    apt-get update && \
    apt-get install -y ./gcm-linux-x64-2.7.3.deb && \
    rm gcm-linux-x64-2.7.3.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt update && apt install -y gh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update && \
    rm -rf awscliv2.zip aws

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
COPY install-harnesses /usr/local/bin/
RUN chmod +x /bin/entry.sh && \
    chmod +x /usr/local/bin/osn-mount.sh && \
    chmod +x /usr/local/bin/install-harnesses

USER jovyan

# Install OpenAI Codex via npm
RUN npm config set prefix /home/jovyan/.npm-global && \
    npm install -g @openai/codex && \
    npm cache clean --force

# Claude Code and the Antigravity CLI are closed source, so they are installed
# on demand rather than baked in. Shim their commands to the installer until the
# real binaries replace it.
RUN mkdir -p /home/jovyan/.local/bin && \
    ln -s /usr/local/bin/install-harnesses /home/jovyan/.local/bin/claude && \
    ln -s /usr/local/bin/install-harnesses /home/jovyan/.local/bin/agy

# Install OpenCode (https://opencode.ai/) — --no-modify-path avoids shell detection hang in Docker
RUN curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path

# Configure bashrc - sourced by every interactive shell, including each new
# tmux window (via ~/.bash_profile)
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo '[ ! -z "$TERM" -a -r /etc/motd ] && /etc/motd' >> ~/.bashrc && \
    echo '' >> ~/.bashrc && \
    echo '# upgrade GoCommands (once per container, not once per tmux window)' >> ~/.bashrc && \
    echo '[ -f /tmp/.gocmd-upgraded ] || { sudo gocmd upgrade > /dev/null 2>&1; touch /tmp/.gocmd-upgraded; }' >> ~/.bashrc

# set path for Go, NPM globals, OpenCode, and the on-demand harnesses
# (.local/bin must stay first: it holds the shims and is where the Claude Code
# and Antigravity installers place their binaries)
ENV PATH="/home/jovyan/.local/bin:/home/jovyan/.npm-global/bin:/home/jovyan/.opencode/bin:/usr/local/go/bin:${PATH}"

# set shell as bash and terminal as linux
# (absolute path required: tmux ignores a relative $SHELL for new windows)
ENV SHELL=/bin/bash
ENV TERM=xterm

# open port 7681 for ttyd
EXPOSE 7681

# Set the working directory to match the tool's setting in the DE, which has to
# stay at /home/jovyan/data-store: the DE mounts the analysis's persistent
# volume at the container's working directory, so pointing it at /home/jovyan
# would mount a volume over the home directory and hide .bashrc, .bash_profile
# and everything else this image installs. Landing users in $HOME is entry.sh's
# job instead -- it does `cd "$HOME"` before exec, and tmux takes the cwd of
# every window, including new ones (ctrl-b c), from the session it starts in.
WORKDIR /home/jovyan/data-store

# Configure tmux and create the iRODS directory
RUN echo 'set-option -g status off' >> ~/.tmux.conf && \
    mkdir -p /home/jovyan/.irods /home/jovyan/data-store

# The Jupyter base image ships a ~/work directory. Rename it to ~/scratch to
# make clear that it is temporary storage and is not backed by the data store.
RUN if [ -d /home/jovyan/work ]; then \
        mv /home/jovyan/work /home/jovyan/scratch; \
    else \
        mkdir -p /home/jovyan/scratch; \
    fi

# activate base Python environment using mamba
COPY environment.yml /home/jovyan/
RUN mamba env create -f /home/jovyan/environment.yml

# Activate the environment from ~/.bashrc, not ~/.bash_profile, so that it is
# picked up by every interactive shell rather than only login shells.
RUN echo "conda activate geospatial" >> /home/jovyan/.bashrc

# tmux starts a login shell for each new window (ctrl-b c), and bash reads
# ~/.bash_profile instead of ~/.bashrc for login shells. Sourcing ~/.bashrc here
# is what keeps every window configured identically. The activation is repeated
# below because ~/.bashrc returns early for non-interactive shells, which is
# what `bash -lc` in a script or job launcher gets.
RUN printf '%s\n' 'if [ -f ~/.bashrc ]; then' '    . ~/.bashrc' 'fi' \
    >> /home/jovyan/.bash_profile && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/jovyan/.bash_profile && \
    echo "conda activate geospatial" >> /home/jovyan/.bash_profile

# No CMD on purpose. entry.sh never reads "$@" -- it execs ttyd itself -- so a
# CMD is dead weight here. It also muddies argv: the DE replaces the args with
# the analysis's app parameters, so a `ttyd bash` CMD would leave "no parameter
# set" looking just like a parameter whose value happens to be "ttyd". With no
# CMD, argv is empty unless the DE supplied a parameter, which is what lets
# entry.sh accept a bare parameter value.
ENTRYPOINT ["bash", "/bin/entry.sh"]
