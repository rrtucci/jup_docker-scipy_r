# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Set when building on Travis so that certain long-running build steps can
# be skipped to shorten build time.
ARG TEST_ONLY_BUILD

USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc && \
    rm -rf /var/lib/apt/lists/*

## Julia dependencies
## install Julia packages in /opt/julia instead of $HOME
#ENV JULIA_DEPOT_PATH=/opt/julia
#ENV JULIA_PKGDIR=/opt/julia
#ENV JULIA_VERSION=1.3.1
#
#RUN mkdir /opt/julia-${JULIA_VERSION} && \
#    cd /tmp && \
#    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
#    echo "faa707c8343780a6fe5eaf13490355e8190acf8e2c189b9e7ecbddb0fa2643ad *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
#    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
#    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
#RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia
#
## Show Julia where conda libraries are \
#RUN mkdir /etc/julia && \
#    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
#    # Create JULIA_PKGDIR \
#    mkdir $JULIA_PKGDIR && \
#    chown $NB_USER $JULIA_PKGDIR && \
#    fix-permissions $JULIA_PKGDIR

USER $NB_UID

# R packages including IRKernel which gets installed globally.
RUN conda install --quiet --yes \
    'r-base=3.6.2' \
    'r-caret=6.0*' \
    'r-crayon=1.3*' \
    'r-devtools=2.2*' \
    'r-forecast=8.10*' \
    'r-hexbin=1.28*' \
    'r-htmltools=0.4*' \
    'r-htmlwidgets=1.5*' \
    'r-irkernel=1.1*' \
    'r-nycflights13=1.0*' \
    'r-plyr=1.8*' \
    'r-randomforest=4.6*' \
    'r-rcurl=1.98*' \
    'r-reshape2=1.4*' \
    'r-rmarkdown=2.1*' \
    'r-rsqlite=2.1*' \
    'r-shiny=1.3*' \
    'r-tidyverse=1.3*' \
    'rpy2=3.1*' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

## Add Julia packages. Only add HDF5 if this is not a test-only build since
## it takes roughly half the entire build time of all of the images on Travis
## to add this one package and often causes Travis to timeout.
##
## Install IJulia as jovyan and then move the kernelspec out
## to the system share location. Avoids problems with runtime UID change not
## taking effect properly on the .local folder in the jovyan home dir.
#RUN julia -e 'import Pkg; Pkg.update()' && \
#    (test $TEST_ONLY_BUILD || julia -e 'import Pkg; Pkg.add("HDF5")') && \
#    julia -e "using Pkg; pkg\"add IJulia\"; pkg\"precompile\"" && \
#    # move kernelspec out of home \
#    mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ && \
#    chmod -R go+rx $CONDA_DIR/share/jupyter && \
#    rm -rf $HOME/.local && \
#    fix-permissions $JULIA_PKGDIR $CONDA_DIR/share/jupyter
