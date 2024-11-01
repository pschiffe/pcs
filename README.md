# pcs

![Docker Image Size (tag)](https://img.shields.io/docker/image-size/pschiffe/pcs/latest?label=latest) ![Docker Pulls](https://img.shields.io/docker/pulls/pschiffe/pcs)

This is a [Docker](https://www.docker.com/) image that includes [Pacemaker](http://clusterlabs.org/) and [Corosync](https://corosync.github.io/corosync/), both managed by [pcs](https://github.com/feist/pcs).

To get this image, pull it from [docker hub](https://hub.docker.com/r/pschiffe/pcs/):
```
docker pull pschiffe/pcs
```

If you want to build this image yourself, clone the [GitHub repository](https://github.com/pschiffe/pcs) and run the following command in the directory containing the Dockerfile:
```
docker build -t pcs .
```

To run the image:
```
docker run -dt --privileged --net=host -v /etc/localtime:/etc/localtime:ro -v /run/docker.sock:/var/docker.sock:ro -v /usr/bin/docker:/usr/bin/docker:ro --name pcs pschiffe/pcs
```

The Pacemaker in this image can manage Docker containers on the host. This is why the Docker socket and binary are exposed to the image (do not expose these if not necessary). Privileged mode is required by the systemd in the container and `--net=host` is required so the pacemaker is able to manage virtual IP.

The pcs web UI will be available at https://localhost:2224/. To log in, you need to set a password for the `hacluster` Linux user inside the image:
```
docker exec -it pcs bash
passwd hacluster
```

Then you can use `hacluster` as the login name and your password in the web ui.

#### Example usage

You can create a cluster using the web UI or via the CLI. Every node in the cluster must be running the pcs Docker container and must have a set password for the `hacluster` user. Then, on one of the nodes in the cluster run (modify pieces in []):
```
docker exec -it pcs bash
pcs host auth -u hacluster -p [hapass] [master1 master2 master3]  # master[1-3] are hostnames of nodes in your cluster
pcs cluster setup [cluster_name] [master1 master2 master3] --start --enable
pcs status
```

Create virtual ip:
```
pcs resource create virtual-ip IPaddr2 ip=[192.168.92.3] --group [master-group]
```

Define docker resource image:
```
pcs resource create [docker-master] ocf:heartbeat:docker image=[docker-master] reuse=1 run_opts='[-p 8080]' --group [master-group]
```

Disable stonith (this will start the cluster):
```
pcs property set stonith-enabled=false
```

You can view and modify your cluster in the web UI even if you created it using the CLI. However, you need to add it to the web UI first (select 'Add existing').
