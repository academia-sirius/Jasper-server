# JasperReports Server CE 8.0.0 on Tomcat 9.

ARG JAVA_BASE_IMAGE=eclipse-temurin:11-jdk-jammy
ARG TOMCAT_VERSION=9.0.85

FROM alpine:3.20 AS downloader

ARG TOMCAT_VERSION

RUN apk add --no-cache ca-certificates curl tar unzip

RUN mkdir -p /tmp/tomcat \
    && curl -fSL "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" -o /tmp/tomcat.tar.gz \
    && tar -xzf /tmp/tomcat.tar.gz -C /tmp/tomcat \
    && rm /tmp/tomcat.tar.gz

COPY TIB_js-jrs-cp_8.0.0_bin.zip /tmp/jasper.zip

RUN mkdir -p /tmp/jasper \
    && unzip -q /tmp/jasper.zip -d /tmp/jasper \
    && rm /tmp/jasper.zip \
    && cd /tmp/jasper/jasperreports-server-cp-8.0.0-bin \
    && unzip -q jasperserver.war -d jasperserver \
    && rm jasperserver.war

FROM ${JAVA_BASE_IMAGE}

ARG POSTGRES_JDBC_DRIVER_VERSION=42.2.14
ARG JASPERREPORTS_SERVER_VERSION=8.0.0
ARG TOMCAT_VERSION=9.0.85

ENV CATALINA_HOME=/usr/local/tomcat \
    BUILDOMATIC_HOME=/usr/src/jasperreports-server/buildomatic \
    MOUNTS_HOME=/usr/local/share/jasperserver \
    POSTGRES_JDBC_DRIVER_VERSION=${POSTGRES_JDBC_DRIVER_VERSION} \
    JASPERREPORTS_SERVER_VERSION=${JASPERREPORTS_SERVER_VERSION} \
    HTTP_PORT=8080 \
    HTTPS_PORT=8443

ENV PATH="${CATALINA_HOME}/bin:/usr/src/jasperreports-server/apache-ant/bin:${PATH}"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl git jq unzip xmlstarlet; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p "${CATALINA_HOME}" /usr/src/jasperreports-server "${MOUNTS_HOME}/keystore"

COPY --from=downloader "/tmp/tomcat/apache-tomcat-${TOMCAT_VERSION}/" "${CATALINA_HOME}/"
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/apache-ant/ /usr/src/jasperreports-server/apache-ant/
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/buildomatic/ /usr/src/jasperreports-server/buildomatic/
COPY --from=downloader /tmp/jasper/jasperreports-server-cp-8.0.0-bin/jasperserver/ "${CATALINA_HOME}/webapps/jasperserver/"

COPY assets/jdbc/postgresql-${POSTGRES_JDBC_DRIVER_VERSION}.jar /usr/src/jasperreports-server/buildomatic/conf_source/db/postgresql/jdbc/
COPY assets/libs/*.jar "${CATALINA_HOME}/webapps/jasperserver/WEB-INF/lib/"
COPY scripts /
COPY scripts/index.jsp "${CATALINA_HOME}/webapps/ROOT/index.jsp"

RUN set -eux; \
    sed -i 's/\r$//' /*.sh /usr/src/jasperreports-server/buildomatic/js-*.sh /usr/src/jasperreports-server/buildomatic/bin/*.sh; \
    chmod +x /*.sh /usr/src/jasperreports-server/buildomatic/js-* /usr/src/jasperreports-server/buildomatic/bin/*.sh /usr/src/jasperreports-server/apache-ant/bin/* "${CATALINA_HOME}/bin/"*.sh; \
    rm -rf "${CATALINA_HOME}/webapps/docs" "${CATALINA_HOME}/webapps/examples" "${CATALINA_HOME}/webapps/host-manager" "${CATALINA_HOME}/webapps/manager"; \
    java -version; \
    catalina.sh version

EXPOSE 8080

ENTRYPOINT ["/entrypoint-ce.sh"]
CMD ["run"]
