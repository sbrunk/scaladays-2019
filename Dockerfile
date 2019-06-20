# Using a Dockerfile instead of repo2docker because we need a specific version of libopenjfx-java
FROM jupyter/minimal-notebook:d4cbf2f80a2a

USER root
RUN apt-get update && apt-get install -y curl graphviz libopenjfx-java=8u161-b12-1ubuntu2 openjfx=8u161-b12-1ubuntu2

USER $NB_USER
COPY . $HOME
RUN scripts/coursier.sh
RUN scripts/jupyter.sh