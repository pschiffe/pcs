# pcs

[Docker](https://www.docker.com/) image with [Pacemaker](http://clusterlabs.org/) and [Corosync](https://corosync.github.io/corosync/) managed by [pcs](https://github.com/feist/pcs).

To get this image, pull it from [docker hub](https://hub.docker.com/r/pschiffe/pcs/):
```
docker pull pschiffe/pcs
```

If you want to build this image yourself, clone the [github repo](https://github.com/pschiffe/pcs) and in directory with Dockerfile run:
```
docker build -t <username>/pcs .
```

To run the image:
```
docker run -d --privileged --net=host -p 2224:2224 -v /sys/fs/cgroup:/sys/fs/cgroup -v /etc/localtime:/etc/localtime:ro -v /run/docker.sock:/run/docker.sock -v /usr/bin/docker:/usr/bin/docker:ro --name pcs pcs
```

Pacemaker in this image is able to manage docker containers on the host - that's why I'm exposing docker socket and binary to the image (don't expose if not needed). Cgroup fs and privileged mode is required by the systemd in the container and `--net=host` is required so the pacemaker is able to manage virtual IP.

Pcs web ui will be available on the [https://localhost:2224/](https://localhost:2224/). To log in, you need to set password for the `hacluster` linux user inside of the image:
```
docker exec -it pcs bash
passwd hacluster
```

Then you can use `hacluster` as the login name and your password in the web ui.

#### Example usage

You can create cluster in the web ui, or via cli. Every node in the cluster must be running pcs docker container and must have setup password for the `hacluster` user. Then, on one of the nodes in the cluster run (modify pieces in []):
```
docker exec -it pcs bash
pcs cluster auth -u hacluster -p [hapass] [master1 master2 master3]  # master[1-3] are hostnames of nodes in your cluster
pcs cluster setup --name [master] [master1 master2 master3]
pcs cluster start --all
pcs cluster enable --all
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

You can view and modify your cluster in the web ui even when you created it in cli, but you need to add it there first (Add existing).

