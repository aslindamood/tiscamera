FROM ubuntu:bionic-20200112

ENV APP_PATH=/tiscamera
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR $APP_PATH

COPY . .

RUN apt-get update && \
      apt-get install -y sudo apt-utils

RUN sudo ./scripts/install-dependencies.sh --yes --compilation --runtime

RUN mkdir build && \
    cd build && \
    cmake -DBUILD_ARAVIS=ON -DBUILD_TOOLS=ON .. && \
    make && \
    sudo make install

ENTRYPOINT ["/bin/bash"]
