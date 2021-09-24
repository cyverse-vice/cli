FROM ubuntu:20.04

LABEL org.label-schema.name="CyVerse VICE WebShell" \
      org.label-schema.description="Built from MiniConda3" \
      org.label-schema.url="https://cyverse.org" \
      org.label-schema.vcs-url="e.g. https://github.com/tyson-swetnam/vice_cli" \
      org.label-schema.vendor="CyVerse" \
      org.label-schema.schema-version="1.0.0"

USER root

# Add sudo to user
RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN adduser --disabled-password --gecos "VICE_User" --uid 1000 user  && \
    usermod -aG sudo user && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

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
    git mercurial subversion \
    tmux && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.zshrc && \
    echo "conda activate base" >> ~/.zshrc && \
    chown -R user:user /opt/conda

RUN apt-get update && \
    apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
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
    echo "deb [arch=amd64] https://packages.irods.org/apt/ bionic main" > /etc/apt/sources.list.d/renci-irods.list && \
    apt-get update && \
    wget -q -c \
    http://security.ubuntu.com/ubuntu/pool/main/p/python-urllib3/python-urllib3_1.22-1ubuntu0.18.04.2_all.deb \
    http://security.ubuntu.com/ubuntu/pool/main/r/requests/python-requests_2.18.4-2ubuntu0.1_all.deb \
    http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.7_amd64.deb && \
    apt install -y \
    ./python-urllib3_1.22-1ubuntu0.18.04.2_all.deb \
    ./python-requests_2.18.4-2ubuntu0.1_all.deb \
    ./libssl1.0.0_1.0.2n-1ubuntu5.7_amd64.deb && \
    rm -rf \
    ./python-urllib3_1.22-1ubuntu0.18.04.2_all.deb \
    ./python-requests_2.18.4-2ubuntu0.1_all.deb \
    ./libssl1.0.0_1.0.2n-1ubuntu5.7_amd64.deb && \
    apt install -y irods-icommands && \
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

# update terminal message
RUN apt-get update && apt install neofetch figlet lolcat cowsay fortune -y
ENV PATH=${PATH}:/usr/games
ENV LC_ALL=C
COPY 01-custom /etc/motd
RUN chmod +x /etc/motd

USER user

# Install OhMyZSH theme
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && /etc/motd' >> ~/.zshrc

# set path for Go
ENV PATH=$PATH:/usr/local/go/bin 

# set shell as zsh
ENV SHELL=zsh

# open port 7681 for ttyd
EXPOSE 7681

#set working directory
WORKDIR /home/user

COPY entry.sh /bin
RUN echo 'set-option -g status off' >> ~/.tmux.conf

# add iRODS iCommands to user profile as JSON
RUN mkdir /home/user/.irods 
ENTRYPOINT ["zsh", "/bin/entry.sh"]

CMD ["ttyd", "zsh"]
