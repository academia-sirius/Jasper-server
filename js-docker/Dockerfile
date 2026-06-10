# Copyright (c) 2020. TIBCO Software Inc.
# Zero apt: openjdk + Tomcat local + ficheiros JRS.

ARG JAVA_BASE_IMAGE=openjdk@sha256:b577374a385b86572caad3050b122b6aa6dd911cf37421667d248e9d1c638e44

# Downloader stage
FROM alpine:latest AS downloader
RUN apk add --no-cache curl unzip tar ca-certificates

# Download and extract Tomcat
RUN mkdir -p /tmp/tomcat \
    && curl -L https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz -o /tmp/tomcat.tar.gz \
    && tar -xzf /tmp/tomcat.tar.gz -C /tmp/tomcat \
    && rm /tmp/tomcat.tar.gz

# Download and extract JasperReports CP
RUN mkdir -p /tmp/jasper \
    && curl -L https://sourceforge.net/projects/jr-community-installers/files/Server/TIB_js-jrs-cp_8.0.0_bin.zip/download -o /tmp/jasper.zip \
    && unzip -q /tmp/jasper.zip -d /tmp/jasper \
    && rm /tmp/jasper.zip \
    && cd /tmp/jasper/jasperreports-server-cp-8.0.0-bin \
    && unzip -q jasperserver.war -d jasperserver \
    && rm jasperserver.war

FROM ${JAVA_BASE_IMAGE}

ARG DN_HOSTNAME
ARG KS_PASSWORD
ARG HTTP_PORT
ARG HTTPS_PORT
ARG POSTGRES_JDBC_DRIVER_VERSION
ARG JASPERREPORTS_SERVER_VERSION

ENV DN_HOSTNAME ${DN_HOSTNAME:-localhost.localdomain}
ENV KS_PASSWORD ${KS_PASSWORD:-changeit}
ENV HTTP_PORT ${HTTP_PORT:-8080}
ENV HTTPS_PORT ${HTTPS_PORT:-8443}
ENV POSTGRES_JDBC_DRIVER_VERSION ${POSTGRES_JDBC_DRIVER_VERSION:-42.2.14}
ENV JASPERREPORTS_SERVER_VERSION ${JASPERREPORTS_SERVER_VERSION:-8.0.0}
ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=${CATALINA_HOME}/bin:${PATH}

RUN mkdir -p /usr/src/jasperreports-server ${CATALINA_HOME}

COPY --from=downloader /tmp/tomcat/apache-tomcat-9.0.85/ ${CATALINA_HOME}/
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/jasperserver ${CATALINA_HOME}/webapps/jasperserver/
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/TIB* /usr/src/jasperreports-server/
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/apache-ant /usr/src/jasperreports-server/apache-ant/
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/buildomatic/js-ant /usr/src/jasperreports-server/buildomatic/
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/buildomatic/build.xml /usr/src/jasperreports-server/buildomatic/
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/buildomatic/bin/*.xml /usr/src/jasperreports-server/buildomatic/bin/
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/buildomatic/bin/app-server /usr/src/jasperreports-server/buildomatic/bin/app-server/
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/buildomatic/bin/groovy /usr/src/jasperreports-server/buildomatic/bin/groovy/
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/buildomatic/conf_source /usr/src/jasperreports-server/buildomatic/conf_source/
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/buildomatic/lib /usr/src/jasperreports-server/buildomatic/lib/
RUN mkdir -p /usr/src/jasperreports-server/buildomatic/target

COPY scripts /
COPY assets/libs/ ${CATALINA_HOME}/webapps/jasperserver/WEB-INF/lib/
COPY assets/jdbc/postgresql-${POSTGRES_JDBC_DRIVER_VERSION}.jar \
    /usr/src/jasperreports-server/buildomatic/conf_source/db/postgresql/jdbc/

RUN sed -i 's/\r$//' /*.sh && \
    chmod +x /*.sh && \
    rm -rf ${CATALINA_HOME}/webapps/ROOT \
           ${CATALINA_HOME}/webapps/docs \
           ${CATALINA_HOME}/webapps/examples \
           ${CATALINA_HOME}/webapps/host-manager \
           ${CATALINA_HOME}/webapps/manager && \
    mkdir ${CATALINA_HOME}/webapps/ROOT && \
    mv /index.jsp ${CATALINA_HOME}/webapps/ROOT/ && \
    cp -R /buildomatic /usr/src/jasperreports-server/buildomatic && \
    rm -rf /buildomatic && \
    chmod +x /usr/src/jasperreports-server/buildomatic/js-* && \
    chmod +x /usr/src/jasperreports-server/apache-ant/bin/* && \
    chmod +x ${CATALINA_HOME}/bin/*.sh && \
    java -version

EXPOSE ${HTTP_PORT} ${HTTPS_PORT}

ENTRYPOINT ["/entrypoint-ce.sh"]
CMD ["run"]
