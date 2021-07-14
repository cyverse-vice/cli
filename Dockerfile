FROM continuumio/miniconda3:4.9.2

LABEL org.label-schema.name="CyVerse VICE WebShell" \
      org.label-schema.description="Built from tiniconda" \
      org.label-schema.url="https://cyverse.org" \
      org.label-schema.vcs-url="e.g. https://github.com/tyson-swetnam/vice_bioinfo" \
      org.label-schema.vendor="CyVerse" \
      org.label-schema.schema-version="1.0.0"

USER root

ENV TZ=US/Phoenix
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone
    
# Install a few dependencies for iCommands, text editing, and monitoring instances
RUN apt-get update && apt-get install -y lsb-release wget apt-transport-https curl supervisor nginx gnupg2 libfuse2 nano htop gcc less nodejs software-properties-common apt-utils glances

RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add - && \
    echo "deb [arch=amd64] https://packages.irods.org/apt/ bionic main" > /etc/apt/sources.list.d/renci-irods.list && \
    apt-get update && \
    wget -c \
    http://security.ubuntu.com/ubuntu/pool/main/p/python-urllib3/python-urllib3_1.22-1ubuntu0.18.04.2_all.deb \
    http://security.ubuntu.com/ubuntu/pool/main/r/requests/python-requests_2.18.4-2ubuntu0.1_all.deb \
    http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.6_amd64.deb && \
    apt install -y \
    ./python-urllib3_1.22-1ubuntu0.18.04.2_all.deb \
    ./python-requests_2.18.4-2ubuntu0.1_all.deb \
    ./libssl1.0.0_1.0.2n-1ubuntu5.6_amd64.deb && \
    rm -rf \
    ./python-urllib3_1.22-1ubuntu0.18.04.2_all.deb \
    ./python-requests_2.18.4-2ubuntu0.1_all.deb \
    ./libssl1.0.0_1.0.2n-1ubuntu5.6_amd64.deb

RUN apt install -y irods-icommands

# Install CyberDuck CLI
RUN echo -e "deb https://s3.amazonaws.com/repo.deb.cyberduck.io stable main" | tee /etc/apt/sources.list.d/cyberduck.list > /dev/null && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FE7097963FEFBE72 && \
apt-get update && \
apt-get install duck

# install ttyd
RUN apt-get install -y build-essential cmake git libjson-c-dev libwebsockets-dev && \
    git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && mkdir build && cd build && \
    cmake .. && \
    make && make install

RUN apt-get update && apt-get install -y --no-install-recommends tini && rm -rf /var/lib/apt/lists/*

# RUN fix-permissions $CONDA_DIR $HOME
USER $NB_USER

EXPOSE 7681
WORKDIR /root

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["ttyd", "bash"]
