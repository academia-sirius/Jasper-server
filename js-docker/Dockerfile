# Copyright (c) 2020. TIBCO Software Inc.
# Zero apt: openjdk + Tomcat local + ficheiros JRS.

ARG JAVA_BASE_IMAGE=openjdk@sha256:b577374a385b86572caad3050b122b6aa6dd911cf37421667d248e9d1c638e44
FROM ${JAVA_BASE_IMAGE}

ARG DN_HOSTNAME
ARG KS_PASSWORD
ARG HTTP_PORT
ARG HTTPS_PORT
ARG POSTGRES_JDBC_DRIVER_VERSION
ARG JASPERREPORTS_SERVER_VERSION
ARG EXPLODED_INSTALLER_DIRECTORY
ARG TOMCAT_DIRECTORY

ENV DN_HOSTNAME ${DN_HOSTNAME:-localhost.localdomain}
ENV KS_PASSWORD ${KS_PASSWORD:-changeit}
ENV HTTP_PORT ${HTTP_PORT:-8080}
ENV HTTPS_PORT ${HTTPS_PORT:-8443}
ENV POSTGRES_JDBC_DRIVER_VERSION ${POSTGRES_JDBC_DRIVER_VERSION:-42.2.14}
ENV JASPERREPORTS_SERVER_VERSION ${JASPERREPORTS_SERVER_VERSION:-8.0.0}
ENV EXPLODED_INSTALLER_DIRECTORY ${EXPLODED_INSTALLER_DIRECTORY:-resources/jasperreports-server-cp-$JASPERREPORTS_SERVER_VERSION-bin}
ENV TOMCAT_DIRECTORY ${TOMCAT_DIRECTORY:-resources/runtime/apache-tomcat-9.0.85}
ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=${CATALINA_HOME}/bin:${PATH}

RUN mkdir -p /usr/src/jasperreports-server ${CATALINA_HOME}

COPY ${TOMCAT_DIRECTORY}/ ${CATALINA_HOME}/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/jasperserver ${CATALINA_HOME}/webapps/jasperserver/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/TIB* /usr/src/jasperreports-server/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/apache-ant /usr/src/jasperreports-server/apache-ant/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/js-ant /usr/src/jasperreports-server/buildomatic/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/build.xml /usr/src/jasperreports-server/buildomatic/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/bin/*.xml /usr/src/jasperreports-server/buildomatic/bin/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/bin/app-server /usr/src/jasperreports-server/buildomatic/bin/app-server/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/bin/groovy /usr/src/jasperreports-server/buildomatic/bin/groovy/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/conf_source /usr/src/jasperreports-server/buildomatic/conf_source/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/lib /usr/src/jasperreports-server/buildomatic/lib/
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
