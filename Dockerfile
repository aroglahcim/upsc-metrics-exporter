FROM ruby:3.3.5-slim-bookworm

RUN apt-get update && \
    apt-get install -y nut nut-client nut-server

RUN useradd -s /bin/bash exporter
RUN chown -R exporter:exporter /etc/nut /run/nut

WORKDIR /exporter

COPY ./metrics.rb ./

USER exporter

ENTRYPOINT [ "ruby", "metrics.rb" ]
