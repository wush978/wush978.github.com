---
layout: post
title: "Initialize PostgreSQL in Ubuntu 12.04"
date: 2012-08-30 13:41
comments: true
categories: PostgreSQL
---

# Install

```sh
sudo apt-get install postgresql
```

# Configure

```sh
sudo -u postgres createuser -D -P ruser
sudo -u postgres createdb -O ruser ruserdb
```

Edit `/etc/postgresql/9.1/main/pg_hba.conf`.

Change this line:
```
local   all             all                                     peer
```
to this:
```
local   all             all                                     md5
```

Restart service:

```
sudo service postgresql restart
```

# Reference

- [GET POSTGRES WORKING ON UBUNTU OR LINUX MINT](http://blog.deliciousrobots.com/2011/12/13/get-postgres-working-on-ubuntu-or-linux-mint/)
