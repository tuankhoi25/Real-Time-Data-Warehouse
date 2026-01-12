FROM python:3.12.11-bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-17-jdk curl wget && \
    apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY docker/apache_flink/flink-*.prod.tgz /tmp/

RUN mkdir -p /opt/flink && \
    tar -xzf /tmp/flink-*.prod.tgz -C /opt/flink --strip-components=1 && \
    rm -rf /tmp/flink-*.prod.tgz

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
ENV FLINK_HOME=/opt/flink
ENV PATH=$JAVA_HOME/bin:$FLINK_HOME/bin:$PATH

RUN pip install apache-flink