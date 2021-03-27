FROM tswetnam/xpra:20.04

USER root

ENV TZ=US/Phoenix

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -u -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s -f /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc
RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

# install gcc
RUN apt-get install gcc -y
COPY . /root/
RUN conda update -n base -c defaults conda && \
    cd && \
    conda env update -n base -f environment.yml

# install ttyd
#ARG TARGETARCH
#COPY ./dist/${TARGETARCH}/ttyd /usr/bin/ttyd
#RUN apt-get update && apt-get install -y --no-install-recommends tini && rm -rf /var/lib/apt/lists/*
RUN apt-get install -y build-essential cmake git libjson-c-dev libwebsockets-dev && \
    git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && mkdir build && cd build && \
    cmake .. && \
    make && make install

EXPOSE 8080

WORKDIR /root

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD xpra start :10 --video-encoders=nvenc --bind-tcp=0.0.0.0:8080 --html=on --exit-with-children=no --daemon=no --xvfb="/usr/bin/Xvfb +extension Composite -screen 0 1920x1080x24+32 -nolisten tcp -noreset" --pulseaudio=no --notifications=no --bell=no
