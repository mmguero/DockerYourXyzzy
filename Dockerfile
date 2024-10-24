FROM davidcaste/alpine-tomcat:jdk8tomcat7

# MAVEN
ENV MAVEN_VERSION 3.9.3
ENV USER_HOME_DIR /root
ENV SHA e1e13ac0c42f3b64d900c57ffc652ecef682b8255d7d354efbbb4f62519da4f1
ENV BASE_URL https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

RUN apk add --no-cache curl tar procps \
 && mkdir -p /usr/share/maven/ref \
 && curl -fsSL -o /tmp/apache-maven.tar.gz "${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
 && echo "${SHA} /tmp/apache-maven.tar.gz" | sha256sum -c - || true \
 && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
 && rm -f /tmp/apache-maven.tar.gz \
 && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

# PYX
ADD scripts/default.sh scripts/overrides.sh /
ENV GIT_BRANCH familyfriendly

RUN set -x \
  && apk add git --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted \
  && git clone -b $GIT_BRANCH https://github.com/mmguero/PretendYoureXyzzy.git /project \
  && apk del git \
  && chmod +x /default.sh /overrides.sh \
  && mkdir /overrides

ADD ./overrides/settings-docker.xml /usr/share/maven/ref/
VOLUME [ "/overrides" ]

WORKDIR /project
CMD [ "/default.sh" ]