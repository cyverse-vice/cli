FROM kasmweb/terminal:1.15.0-rolling

LABEL org.label-schema.name="CyVerse VICE CloudShell" \
      org.label-schema.description="Built from KASM Terminal" \
      org.label-schema.url="https://de.cyverse.org/apps" \
      org.label-schema.vcs-url="e.g. https://github.com/cyverse-vice/cli" \
      org.label-schema.vendor="CyVerse" \
      org.label-schema.schema-version="1.0.0"

USER root
    
ARG LOCAL_USER=kasm-user

RUN apt-get update && \
    apt-get install -y sudo && \
    echo "${LOCAL_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    rm -rf /var/lib/apt/lists/*

# Install a few dependencies for goCommands, text editing, and monitoring instances
RUN apt update && \
    apt install -y apt-transport-https \
                apt-utils \
                curl \
                figlet \
                gcc \
                glances \
                htop \
                imagemagick \
                libfreetype6-dev \
                less \
                libx11-dev \
                lolcat   \ 
                neofetch \
                lsb-release \
                neofetch \
                pkg-config \
                software-properties-common \
                nano \
                w3m-img

# Install GoCommands
# https://learning.cyverse.org/ds/gocommands/
RUN cd /usr/local/bin && \
    GOCMD_VER=$(curl -L -s https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt); \
    curl -L -s https://github.com/cyverse/gocommands/releases/download/${GOCMD_VER}/gocmd-${GOCMD_VER}-linux-amd64.tar.gz | tar zxvf -

# install git-credential-manager 
RUN wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.5.0/gcm-linux_amd64.2.5.0.deb && \
    dpkg -i gcm-linux_amd64.2.5.0.deb && \
    rm gcm-linux_amd64.2.5.0.deb
# set the ENV for the credential type
ENV GCM_CREDENTIAL_STORE=cache

# update terminal message
ENV PATH=${PATH}:/usr/games
COPY 01-custom /etc/motd
RUN chmod +x /etc/motd

COPY kasmvnc_defaults.yaml /usr/share/kasmvnc/kasmvnc_defaults.yaml
COPY vnc_startup.sh /dockerstartup/vnc_startup.sh
RUN chmod +x /dockerstartup/vnc_startup.sh

# Install Globus Connect Server
RUN curl -LOs https://downloads.globus.org/globus-connect-server/stable/installers/repo/deb/globus-repo_latest_all.deb && \
    dpkg -i globus-repo_latest_all.deb && \
    apt-key add /usr/share/globus-repo/RPM-GPG-KEY-Globus && \
    apt update && \
    apt install globus-connect-server54 -y && \
    rm globus-repo_latest_all.deb

USER kasm-user

# add iRODS iCommands to user profile as JSON
RUN mkdir /home/kasm-user/.irods 
RUN echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | envsubst > /home/kasm-user/.irods/irods_environment.json

# Install Miniforge and Mamba
RUN cd && wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
    chmod +x Miniforge3-$(uname)-$(uname -m).sh && \ 
    ./Miniforge3-$(uname)-$(uname -m).sh -b -p "${HOME}/conda" && \
    rm Miniforge3-$(uname)-$(uname -m).sh

# set shell as bash and terminal as linux
ENV SHELL=/bin/bash
ENV PATH="${HOME}/conda/bin:${PATH}"

# Combine commands to reduce layers and use $HOME for consistency
RUN echo ". ${HOME}/conda/etc/profile.d/conda.sh" >> ${HOME}/.bashrc && \
    echo "export PS1='\u@cyverse \w $ '" >> ${HOME}/.bashrc && \
    git clone --depth=1 https://github.com/Bash-it/bash-it.git ${HOME}/.bash_it && \
    ${HOME}/.bash_it/install.sh --silent && \
    sed -i 's/BASH_IT_THEME=.*/BASH_IT_THEME="simple"/' ${HOME}/.bashrc && \
    echo "/etc/motd" >> ${HOME}/.bashrc  # message of the day

# fix error
RUN mkdir -p /home/kasm-user/Desktop
