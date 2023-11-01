FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
	apt-get install -y wget curl git unzip && \
    git clone https://github.com/flutter/flutter.git -b stable --depth 1

ENV PATH "$PATH:/flutter/bin"

RUN flutter config --no-analytics --enable-web && \
    flutter precache && \
	flutter doctor