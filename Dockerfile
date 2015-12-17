FROM centos:7

MAINTAINER Peter Schiffer <pschiffe@redhat.com>

ENV container=docker

RUN yum -y --setopt=tsflags=nodocs upgrade \
    && yum -y --setopt=tsflags=nodocs install pcs which \
    && yum -y clean all

LABEL RUN /usr/bin/docker run -d \$OPT1 --privileged --net=host -p 2224:2224 -v /sys/fs/cgroup:/sys/fs/cgroup -v /etc/localtime:/etc/localtime:ro -v /run/docker.sock:/run/docker.sock -v /usr/bin/docker:/usr/bin/docker:ro --name \$NAME \$IMAGE \$OPT2 \$OPT3

RUN mkdir -p /etc/systemd/system-preset/
RUN echo 'enable pcsd.service' > /etc/systemd/system-preset/00-pcsd.preset
RUN systemctl enable pcsd

EXPOSE 2224

CMD ["/usr/lib/systemd/systemd", "--system"]

