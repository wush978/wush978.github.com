---
layout: post
title: "Proxmox &amp; R cluster"
date: 2012-08-16 11:57
comments: true
categories: R Proxmox Parallel-Computing snow mpi
---

Here I'll show how to set up my parallel computing environment of R.

# Introduction

As far as I know, the virtualization for linux with [OpenVZ](http://wiki.openvz.org/Main_Page) does not loss too many computation efficiency.
Moreover, it provides a simple way to _copy_ whole computation environment from one machine to another.
The consistency of the environment reduces the difficulty of setting MPI between machines, so I decide
to build my R cluster under Proxmox, which is an easy to use open source virtualization platform.

# Environment

OS: 

- Host OS: [Proxmox](http://www.proxmox.com/)(Version 2.1-1/fb0f63a)
- Container OS: [Ubuntu Precise](http://www.ubuntu.com/)(Version 12.04)

Software(Installed in Container OS):

- [R](http://www.r-project.org/)(Version 2.14.1)
  - [Rmpi](http://www.stats.uwo.ca/faculty/yu/Rmpi/)(Version 0.5-9) 
  - [snow](http://cran.r-project.org/web/packages/snow/index.html)(Version 0.3-10)
- [Rstudio](http://rstudio.org/)(Version 0.96.316)
- [MPICH2](http://packages.ubuntu.com/precise/mpich2)(Version 1.4.1)

# Set up Proxmox Cluster

## Install Proxmox

Please see [Proxmox Installation](http://pve.proxmox.com/wiki/Installation)

## Set up Proxmox Cluster

Please see [Create a Proxmox VE Cluster](http://pve.proxmox.com/wiki/Proxmox_VE_Cluster#Create_a_Proxmox_VE_Cluster)

## Create a container

An easy way is to create the container under the management console of Proxmox.

Please download the container template from [http://wiki.openvz.org/Download/template/precreated] and put it under `/var/lib/vz/template/cache/`.

Here, I write small shell script (modified from [Here](https://raw.github.com/drivard/openvz-create-container-script/master/createvz.sh)) 
to create the virtual container with 6 CPUs, 2G memory and 32G disk:


``` sh create_vz.sh
#! /bin/bash
VZUID="$1" 
VZHOSTNAME="$2" 
VZIP="$3" 
VZTEMPLATE="$4" 
if [[ $1 != "" && $2 != "" && $3 != "" && $4 != "" ]]; then
  /usr/bin/pvectl create $VZUID $VZTEMPLATE --cpus 6 --disk 32 --hostname $VZHOSTNAME --memory 2048 --swap 2048 --nameserver 8.8.8.8 --password initpasswd --pool Rslaves --netif ifname=eth0,mac=$(./macgen.py),host_ifname=veth103.0,host_mac=<host_mac>,bridge=vmbr0
  /usr/bin/pvectl set $VZUID --ip_address $VZIP
else
  /bin/echo ""
  /bin/echo "./create_vz.sh <UID> <HOSTNAME> <IP> <TEMPLATE>"
  /bin/echo ""
  /bin/echo ""
  /usr/bin/pvectl list
fi
```

Note that the initial root password is _initpasswd_ and the user need to fill <host_mac> according to the mac address of the host.(run `ifconfig` in host machine or check the setting of the container created in management console).

The mac address is initialized according to the following python scripts:

``` py macgen.py
#! /usr/bin/python
# Filename: macgen.py
# Usage: It's intended to generate MAC addresses for virtualized
#        systems that created by Xen, OpenVZ, Vserver etc.

import random

# The first line is defined for specified vendor
mac = [ 0x00, 0x24, 0x81,
random.randint(0x00, 0x7f),
random.randint(0x00, 0xff),
random.randint(0x00, 0xff) ]

print ':'.join(map(lambda x: "%02x" % x, mac))
```

After creating _create_vz.sh_ and _macgen.py_ and put them into the same directory, 
run the shell command `./create_vz.sh 200 Rmaster 192.168.0.100 /var/lib/vz/template/cache/ubuntu-12.04-x86_64.tar.gz`

	Creating container private area (/var/lib/vz/template/cache/ubuntu-12.04-x86_64.tar.gz)
	Performing postcreate actions
	CT configuration saved to /etc/pve/openvz/200.conf
	Container private area was created
	CT configuration saved to /etc/pve/openvz/200.conf
	
# Set up the prototype of container

I will set up everything in one container and copy it to other machines in Proxmox Cluster.

Note that the following commands are executed in the container under root privilege.

## Initialize

Login the virtual machine via ssh(`ssh root@192.168.0.100`) with the initial root password.

``` sh
locale-gen --lang en_US en_US.UTF-8
apt-get update
apt-get upgrade -y
apt-get install build-essential -y
```

## Install R

``` sh
apt-get install r-base -y
```

## Set _/etc/hosts_

Here I'll set up a clusters with 3 machines:

``` text /etc/hosts
192.168.0.100 Rmaster
192.168.0.101 Rslave1
192.168.0.102 Rslave2
```

## Set SSH

Enable ssh public key authentication.

``` text
adduser ruser
su ruser
ssh-keygen -t dsa -N "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
exit
```

Test

``` text
sudo -u ruser ssh ruser@localhost
```

We should directly login without prompt of password.

## Install MPICH2

``` sh
apt-get install mpich2 -y
```

Check Install Result

Run `mpich2version`

	MPICH2 Version:         1.4.1
	MPICH2 Release date:    Wed Aug 24 14:40:04 CDT 2011
	MPICH2 Device:          ch3:nemesis
	MPICH2 configure:       --build=x86_64-linux-gnu --prefix=/usr --includedir=${prefix}/include --mandir=${prefix}/share/man --infodir=${prefix}/share/info --sysconfdir=/etc --localstatedir=/var --libexecdir=${prefix}/lib/mpich2 --srcdir=. --disable-maintainer-mode --disable-dependency-tracking --disable-silent-rules --enable-shared --prefix=/usr --enable-fc --disable-rpath --sysconfdir=/etc/mpich2 --includedir=/usr/include/mpich2 --docdir=/usr/share/doc/mpich2 --with-hwloc-prefix=system --enable-checkpointing --with-hydra-ckpointlib=blcr
	MPICH2 CC:      gcc  -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Wformat-security -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Wformat-security -Werror=format-security -Wall  -O2
	MPICH2 CXX:     c++  -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Wformat-security -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Wformat-security -Werror=format-security -Wall -O2
	MPICH2 F77:     gfortran  -g -O2 -O2
	MPICH2 FC:      gfortran   -O2


## Install Rmpi with MPICH2

Comment out origin setting of `CC` and `SHLIB_LD`.
Add:

``` text
#CC = ...
CC = mpicc
...
#SHLIB_LD = ...
SHLIB_LD=mpicc
```

Open _R_ console and execute following commands to install _Rmpi_ with _MPICH2_:

``` r install Rmpi
install.packages('Rmpi',configure.args="--with-Rmpi-type=MPICH2 --with-Rmpi-include=/usr/lib/mpich2/include --with-Rmpi-libpath=/usr/lib/mpich2/lib/ --with-mpi=/usr/include/mpich2/")
```

Recover _/etc/R/Makeconf_:

``` text
CC = ...
#CC = mpicc
...
SHLIB_LD = ...
#SHLIB_LD=mpicc
```

Modify _/usr/local/lib/R/site-library/Rmpi/Rslaves.sh_ line 17:

``` text /usr/local/lib/R/site-library/Rmpi/Rslaves.sh
...
        $R_HOME/bin/R --no-init-file --slave --no-save < $1 > /tmp/$hn.$2.$$.log 2>&1
...
```

Note that without modification of _/usr/local/lib/R/site-library/Rmpi/Rslaves.sh_ will produce _Permission denied_ during `mpi.spawn.Rslaves`.

## Install snow

Install _snow_

``` r insatll snow
install.packages("snow")
```

# Spread Prototype

In this section, the commands are executed in host OS (Proxmox) if there is no further explanation.

## Shutdown the prototype of container

Before deploying the prototype of container to other machines, I suggest
to shutdown the prototype.

``` sh Under container
init 0
```

## Backup the Snapshot of the container

run `vzdump -dumpdir . 200`

```
INFO: starting new backup job: vzdump 200 --dumpdir .
INFO: Starting Backup of VM 200 (openvz)
INFO: CTID 200 exist unmounted down
INFO: status = stopped
INFO: backup mode: stop
INFO: ionice priority: 7
INFO: creating archive './vzdump-openvz-200-2012_08_16-13_53_23.tar'
INFO: Total bytes written: 960901120 (917MiB, 716MiB/s)
INFO: archive file size: 916MB
INFO: delete old backup './vzdump-openvz-200-2012_08_16-13_33_40.tar'
INFO: Finished Backup of VM 200 (00:00:02)
INFO: Backup job finished successfully
```

The Proxmox will dump the environment of the prototype container to one file whose size is about 1G.
Note that _200_ is the _uid_ of the prototype.

## Copy the prototype

I spread the prototype with the following shell scripts.

Please remember to modify the <host_mac> or other settings to fit your own environment.

``` sh spread_vz.sh
#! /bin/bash
VZUID="$1" 
VZHOSTNAME="$2" 
VZIP="$3" 
VZDUMP="$4"
if [[ $1 != "" && $2 != "" && $3 != "" && $4 != "" ]]; then
  vzrestore $VZDUMP $VZUID
  pvectl set $VZUID --ip_address $VZIP --netif ifname=eth0,mac=$(./macgen.py),host_ifname=veth$VZUID.0,host_mac=<host_mac>,bridge=vmbr0 --hostname $VZHOSTNAME
else
  /bin/echo ""
  /bin/echo "./spread_vz.sh <UID> <HOSTNAME> <IP> <VZDUMP>"
  /bin/echo ""
  /bin/echo ""
  /usr/bin/pvectl list
fi
```

run `./spread_vz.sh 201 Rslave1 192.168.0.101 vzdump-openvz-200-2012_08_16-13_53_23.tar`

``` text
extracting archive '/root/dump/vzdump-openvz-200-2012_08_16-13_53_23.tar'
Total bytes read: 960901120 (917MiB, 470MiB/s)
restore configuration to '/etc/pve/nodes/<cluster1>/openvz/201.conf'
CT configuration saved to /etc/pve/openvz/201.conf
```

run `./spread_vz.sh 202 Rslave2 192.168.0.102 vzdump-openvz-200-2012_08_16-13_53_23.tar` for second slave.

## Deploy the slave

Just open the management console of Proxmox to migrate these new containers to other machines in Proxmox Cluster.

## Validate Environment

- Start all containers.
- Login to Rmaster as ruser.
- Try ssh to Rslave1 and Rslave2 as ruser. It should not require password.
- Check the content of _/etc/hosts_ on all machines.
- Create Rmpi.conf as
``` text
Rmaster
Rslave1
Rslave2
```
- Create Rmpi.test.R as
``` r Rmpi.test.R
library(Rmpi)
cl <- mpi.spawn.Rslaves(nslaves=6)
mpi.close.Rslaves()
mpi.quit()
```
- execute `mpiexec -np 1 -f Rmpi.conf R --vanilla < Rmpi.test.R`
``` text
R version 2.14.1 (2011-12-22)
Copyright (C) 2011 The R Foundation for Statistical Computing
ISBN 3-900051-07-0
Platform: x86_64-pc-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

> library(Rmpi)
> cl <- mpi.spawn.Rslaves(nslaves=6)
        6 slaves are spawned successfully. 0 failed.
master (rank 0, comm 1) of size 7 is running on: Rmaster 
slave1 (rank 1, comm 1) of size 7 is running on: Rslave1
slave2 (rank 2, comm 1) of size 7 is running on: Rslave2
slave3 (rank 3, comm 1) of size 7 is running on: Rmaster
slave4 (rank 4, comm 1) of size 7 is running on: Rslave1
slave5 (rank 5, comm 1) of size 7 is running on: Rslave2
slave6 (rank 6, comm 1) of size 7 is running on: Rmaster
> mpi.close.Rslaves()
[1] 1
> mpi.quit()
```

## Install Rstudio Server

``` sh
apt-get install libssl0.9.8 libapparmor1 apparmor-utils -y
wget http://download2.rstudio.org/rstudio-server-0.96.330-amd64.deb
dpkg -i rstudio-server-0.96.330-amd64.deb
```

See [Download RStudio Server](http://rstudio.org/download/server) for details.

## Set Rmpi in Rstudio Server

### Configuration

Create _/etc/Rmpi.conf_

``` text /etc/Rmpi.conf
Rmaster
Rslave1
Rslave2
```

Create _/usr/lib/rstudio-server/bin/rsession-mpiexec.sh_:

``` sh /usr/lib/rstudio-server/bin/rsession-mpiexec.sh
#! /bin/bash

mpiexec -np 1 -f /etc/Rmpi.conf -errfile-pattern /tmp/mpiexec.error.log /usr/lib/rstudio-server/bin/rsession "$@"
```

Modify the privilege:

``` sh
chmod u+x /usr/lib/rstudio-server/bin/rsession-mpiexec.sh
chmod g+x /usr/lib/rstudio-server/bin/rsession-mpiexec.sh
chmod o+x /usr/lib/rstudio-server/bin/rsession-mpiexec.sh
```

Create or modify _/etc/rstudio/rserver.conf_:

``` text
rsession-path=/usr/lib/rstudio-server/bin/rsession-mpiexec.sh
#rsession-path=/usr/lib/rstudio-server/bin/rsession
```

Modify _/etc/apparmor.d/rstudio-server_:

``` text rstudio-server
  #/usr/lib/rstudio-server/bin/rsession ux,
  /usr/lib/rstudio-server/bin/rsession-mpiexec.sh ux,
```

Restart Rstudio Server or restart the Rmaster

``` sh
rstudio-server restart
```

### Testing with _Rmpi_

Login into web interface of Rstudio and execute

``` r 
library(Rmpi)
cl <- mpi.spawn.Rslaves(nslaves=6)
mpi.close.Rslaves()
mpi.quit()
```

You should see the slaves are spawned in different container/machines.

### Testing with _snow_

Login into web interface of Rstudio and execute

``` r
library(snow)
cl <- makeMPIcluster(count = 18)
unlist(clusterEvalQ(cl, system('hostname',intern=TRUE)))
stopCluster(cl)
```

You should see the hostname of slaves.

# Trouble Shooting:

- Check the network environment
  - Is the _/etc/hosts_ correct?
  - Can _ruser_ ssh to slaves and masters without password prompt?
- Check logs:
  - the system log (/var/log/syslog)
  - mpiexec error log (/tmp/mpiexec.error.log) which is set in _/usr/lib/rstudio-server/bin/rsession-mpiexec.sh_

Good Luck!

# Reference

- [海豹雜記: 使用 Ubuntu Linux 12.04 與 OpenMPI 架設 Cluster](http://sealmemory.blogspot.tw/2012/05/ubuntu-1204-openmpi-cluster.html)
- [Web Application: Install Rmpi with MPICH2 environment](http://webappl.blogspot.tw/2012/01/install-rmpi-with-mpich2-environment.html)
