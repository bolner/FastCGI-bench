FROM ubuntu:18.04
USER root

VOLUME ["/var/fcgibench"]

WORKDIR /var/fcgibench
COPY . /var/fcgibench

RUN /var/fcgibench/install.sh

EXPOSE 80

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

CMD ["docker/startup.sh"]
