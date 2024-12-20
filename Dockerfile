FROM fedora:41

RUN echo 'install_weak_deps=False' >> /etc/dnf/dnf.conf \
  && echo 'assumeyes=True' >> /etc/dnf/dnf.conf \
  && sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-cisco-openh264.repo \
  && dnf --refresh upgrade \
  && dnf install \
    pcs \
    which \
    cracklib-dicts \
  && dnf clean all

RUN mkdir -p /etc/systemd/system-preset \
  && echo 'enable pcsd.service' > /etc/systemd/system-preset/00-pcsd.preset \
  && systemctl enable pcsd

ENV DOCKER_HOST="unix:///var/docker.sock"

EXPOSE 2224

CMD [ "/usr/lib/systemd/systemd", "--system" ]
