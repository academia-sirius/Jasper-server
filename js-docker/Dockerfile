# Copyright (c) 2020. TIBCO Software Inc.
# Zero apt: openjdk + Tomcat local + ficheiros JRS.

ARG JAVA_BASE_IMAGE=openjdk@sha256:b577374a385b86572caad3050b122b6aa6dd911cf37421667d248e9d1c638e44

# Downloader stage
FROM alpine:latest AS downloader
RUN apk add --no-cache curl unzip tar ca-certificates

# Download and extract Tomcat (Mantido pois o servidor Apache é rápido)
RUN mkdir -p /tmp/tomcat \
    && curl -L https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz -o /tmp/tomcat.tar.gz \
    && tar -xzf /tmp/tomcat.tar.gz -C /tmp/tomcat \
    && rm /tmp/tomcat.tar.gz

# NOVA ESTRUTURA: Usando o arquivo local vindo do Git LFS em vez do SourceForge
RUN mkdir -p /tmp/jasper
COPY TIB_js-jrs-cp_8.0.0_bin.zip /tmp/jasper.zip

RUN unzip -q /tmp/jasper.zip -d /tmp/jasper \
    && rm /tmp/jasper.zip \
    && cd /tmp/jasper/jasperreports-server-cp-8.0.0-bin \
    && unzip -q jasperserver.war -d jasperserver \
    && rm jasperserver.war

# Daqui para baixo o seu Dockerfile permanece exatamente igual...
FROM ${JAVA_BASE_IMAGE}
# ... mantém o resto do arquivo idêntico ao original