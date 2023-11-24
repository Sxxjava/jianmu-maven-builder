FROM alpine:3.18.4

LABEL author=Songxx

ENV JAVA_HOME=/usr/local/java \
    MAVEN_HOME=/usr/local/maven

RUN mkdir -p /workspace

WORKDIR /workspace

# Dockerfile 中修改源,并修改时区为上海, 安装git命令
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
    apk update && apk add --no-cache git git-lfs openssh tzdata ttf-dejavu fontconfig curl && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    rm -rf /var/cache/apk/* && rm -rf /root/.cache && rm -rf /tmp/*

# 添加JDK和Maven
ADD ./files/jdk8 /usr/local/java
ADD ./files/maven /usr/local/maven

# 添加glibc兼容库
COPY ./files/glibc-i18n-2.35-r1.apk ./glibc-i18n-2.35-r1.apk
COPY ./files/glibc-bin-2.35-r1.apk ./glibc-bin-2.35-r1.apk
COPY ./files/glibc-2.35-r1.apk ./glibc-2.35-r1.apk
COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

RUN apk add --allow-untrusted glibc-i18n-2.35-r1.apk glibc-bin-2.35-r1.apk glibc-2.35-r1.apk && \
    rm -rf ./glibc-i18n-2.35-r1.apk ./glibc-bin-2.35-r1.apk ./glibc-2.35-r1.apk && \
    rm -rf /lib64/ld-linux-x86-64.so.2 && \
    ln -s "/usr/glibc-compat/lib/ld-linux-x86-64.so.2" "/lib64/ld-linux-x86-64.so.2" && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
    ln -s "$JAVA_HOME/bin/"* "/usr/local/bin/" && \
    ln -s "$MAVEN_HOME/bin/"* "/usr/local/bin/" && \
    echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile && \
    echo "export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar:$MAVEN_HOME/lib" >> /etc/profile && \
    echo "export MAVEN_HOME=/usr/local/maven" >> /etc/profile && \
    echo "export PATH=/usr/local/java/bin:/usr/local/maven/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> /etc/profile && \
    source /etc/profile

ENTRYPOINT [ "entrypoint.sh" ]