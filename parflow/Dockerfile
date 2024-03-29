FROM harbor.cyverse.org/vice/cli/bash:latest as base

USER root

# Non interactive mode
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get install -y \
        build-essential \
	    wget \
        curl \
        libcurl4 \
        git \
        gfortran \
        libopenblas-dev \
        liblapack-dev \
        openmpi-bin \
        libopenmpi-dev \
	    libhdf5-openmpi-dev \
	    libhdf5-openmpi-103 \
        python3 \
        python3-pip \
        python3-venv \
        tcl-dev \
        tk-dev \
	    cmake \
	    libxml2 \
	    libxml2-dev

#-----------------------------------------------------------------------------
# Set environment vars
#-----------------------------------------------------------------------------
ENV PARFLOW_DIR /usr/opt/parflow
ENV PARFLOW_DEP_DIR /usr/opt/parflow
ENV PATH $PATH:$PARFLOW_DIR/bin

WORKDIR /home/parflow
run wget -q https://github.com/Unidata/netcdf-c/archive/v4.9.0.tar.gz && \ 
    tar -xf v4.9.0.tar.gz && \
    cd netcdf-c-4.9.0 && \
    CC=mpicc CPPFLAGS=-I/usr/include/hdf5/openmpi LDFLAGS=-L/usr/lib/x86_64-linux-gnu/hdf5/openmpi ./configure --prefix=${PARFLOW_DIR} && \
    make && \
    make install && \
    cd .. && \
    rm -fr netcdf-c-4.9.0 v4.9.0.tar.gz

#
# NetCDF Fortran
#
run wget -q https://github.com/Unidata/netcdf-fortran/archive/v4.5.4.tar.gz && \ 
    tar -xf v4.5.4.tar.gz && \
    cd netcdf-fortran-4.5.4 && \
    CC=mpicc FC=mpifort CPPFLAGS=-I${PARFLOW_DIR}/include LDFLAGS=-L${PARFLOW_DIR}/lib ./configure --prefix=${PARFLOW_DIR} && \
    make && \
    make install && \
    cd .. && \
    rm -fr netcdf-fortran-4.5.4 v4.5.4.tar.gz

#
# SILO
#
RUN wget -q https://github.com/LLNL/Silo/archive/refs/tags/4.10.2.tar.gz && \
    tar -xf 4.10.2.tar.gz && \
    cd Silo-4.10.2 && \
    ./configure  --prefix=$PARFLOW_DIR --disable-silex --disable-hzip --disable-fpzip && \
    make install && \
    cd .. && \
    rm -fr Silo-4.10.2 4.10.2.tar.gz

#
# Hypre
#
RUN  wget -q https://github.com/hypre-space/hypre/archive/v2.26.0.tar.gz && \
   tar xf v2.26.0.tar.gz && \
   cd hypre-2.26.0/src && \
   ./configure --prefix=$PARFLOW_DIR && \
   make install && \
   cd ../.. && \
   rm -fr hypre-2.18.2 v2.18.2.tar.gz

#-----------------------------------------------------------------------------
# Parflow configure and build
#-----------------------------------------------------------------------------

ENV PARFLOW_MPIEXEC_EXTRA_FLAGS "--mca mpi_yield_when_idle 1 --oversubscribe --allow-run-as-root"

# Disable HWLOC warnings from showing up, confusing messages, this has been fixed in later OpenMPI versions
ENV HWLOC_HIDE_ERRORS "2"

WORKDIR /home/jovayn/parflow

RUN git clone -b master --depth 1 --single-branch https://github.com/parflow/parflow.git parflow

RUN mkdir -p build && \
    cd build && \
    cmake ../parflow \
       -DPARFLOW_AMPS_LAYER=mpi1 \
       -DPARFLOW_AMPS_SEQUENTIAL_IO=TRUE \
       -DHYPRE_ROOT=$PARFLOW_DIR \
       -DSILO_ROOT=$PARFLOW_DIR \
       -DPARFLOW_ENABLE_HDF5=TRUE \
       -DPARFLOW_ENABLE_NETCDF=TRUE \
       -DPARFLOW_ENABLE_TIMING=TRUE \
       -DPARFLOW_HAVE_CLM=TRUE \
       -DPARFLOW_ENABLE_PYTHON=TRUE \
       -DPARFLOW_PYTHON_VIRTUAL_ENV=ON \
       -DCURL_LIBRARY=/usr/lib/x86_64-linux-gnu/libcurl.so.4 \
       -DCMAKE_INSTALL_PREFIX=$PARFLOW_DIR && \
     make install && \
     cd .. && \
     rm -fr parflow build

COPY 01-custom /etc/motd
RUN chmod +x /etc/motd

USER jovyan

ENTRYPOINT ["bash", "/bin/entry.sh"]

CMD ["ttyd", "bash"]