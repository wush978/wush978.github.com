---
layout: post
title: "Benchmark of Saving and Loading R Objects"
date: 2012-08-30 12:48
comments: true
categories: R MongoDB
---

# Introduction

To compare the speed of saving and loading R objects to and from MongoDB
with or without serialization.

# Environment

- OpenVZ with Ubuntu 12.04, i7-2600 CPU @ 3.4GHz, 2 processors, 4G RAM
- Local MongoDB
- Local PostgreSQL
- R 1.14.1
- rmongodb 1.0.3
- RPostgreSQL 0.3-2

# Initialize

```sh
sudo apt-get install mongodb
```

## R

```sh install libpq-dev
sudo apt-get install libpq-dev
```

```r install R packages
install.packages("rmongodb")
install.packages("RPostgreSQL")
```

# Benchmark

```r Test saving object serialized or not
{ # loading package
  library(rmongodb)
  mongo <- mongo.create()
  if (!mongo.is.connected(mongo)) {
    stop("disconnected")
  }
}

save1 <- function(a) {
  for(i in 1:repeat.time) {
    b <- mongo.bson.from.list(list(Rdata = a))  
    mongo.insert(mongo, "test.save1", b)
  }
}

load1 <- function() {
  result <- list()
  length(result) <- repeat.time
  cursor <- mongo.find(mongo, "test.save1")
  index <- 1
  while(mongo.cursor.next(cursor)) {
    result[[index]] <- mongo.bson.to.list(mongo.cursor.value(cursor))
    index <- index + 1
  }
  result
}

save2 <- function(a) {
  for(i in 1:repeat.time) {
    buf <- mongo.bson.buffer.create()
    mongo.bson.buffer.append(buf, "Rdata", serialize(a, NULL, FALSE))
    mongo.insert(mongo, "test.save2", mongo.bson.from.buffer(buf))
  }
}

load2 <- function() {
  result <- list()
  length(result) <- repeat.time
  cursor <- mongo.find(mongo, "test.save2")
  index <- 1
  while(mongo.cursor.next(cursor)) {
    result[[index]] <- unserialize(mongo.bson.value(mongo.cursor.value(cursor), "Rdata"))
    index <- index + 1
  }
  result
}

repeat.time <- 1000
mongo.drop.database(mongo, "test")
a <- matrix(rnorm(100^2), 100, 100)
system.time({ #direct way
  print("directly save and load")
  save1(a)
  a.result <- load1()
})
system.time({ #serialized way
  print("serialized before save and load")
  save2(a)
  a.result2 <- load2()
})
```

I tested many times and notice that the results are very unstable, and
I guess that the serialized way is faster a little bit.

I paste some results here:

```
rmongodb package (mongo-r-driver) loaded
Use 'help("mongo")' to get started.

[1] TRUE
[1] "directly save and load"
   user  system elapsed 
  1.226   0.083   4.221 
[1] "serialized before save and load"
   user  system elapsed 
  0.746   0.095   3.578 
rmongodb package (mongo-r-driver) loaded
Use 'help("mongo")' to get started.

[1] TRUE
[1] "directly save and load"
   user  system elapsed 
  1.227   0.090   3.981 
[1] "serialized before save and load"
   user  system elapsed 
  0.771   0.106   3.327 
rmongodb package (mongo-r-driver) loaded
Use 'help("mongo")' to get started.

[1] TRUE
[1] "directly save and load"
   user  system elapsed 
  1.232   0.104   3.808 
[1] "serialized before save and load"
   user  system elapsed 
  0.760   0.110   3.289 
rmongodb package (mongo-r-driver) loaded
Use 'help("mongo")' to get started.

[1] TRUE
[1] "directly save and load"
   user  system elapsed 
  1.303   0.078   3.827 
[1] "serialized before save and load"
   user  system elapsed 
  0.763   0.109   3.413 
rmongodb package (mongo-r-driver) loaded
Use 'help("mongo")' to get started.

[1] TRUE
[1] "directly save and load"
   user  system elapsed 
  1.237   0.089   3.834 
[1] "serialized before save and load"
   user  system elapsed 
  0.773   0.091   3.458 
rmongodb package (mongo-r-driver) loaded
Use 'help("mongo")' to get started.

[1] TRUE
[1] "directly save and load"
   user  system elapsed 
  1.247   0.114   3.970 
[1] "serialized before save and load"
   user  system elapsed 
  0.781   0.110   3.738 
rmongodb package (mongo-r-driver) loaded
Use 'help("mongo")' to get started.

[1] TRUE
[1] "directly save and load"
   user  system elapsed 
  1.331   0.142   4.329 
[1] "serialized before save and load"
   user  system elapsed 
  0.753   0.098   3.202 
rmongodb package (mongo-r-driver) loaded
Use 'help("mongo")' to get started.

[1] TRUE
[1] "directly save and load"
   user  system elapsed 
  1.217   0.090   3.766 
[1] "serialized before save and load"
   user  system elapsed 
  0.737   0.097   5.339 
rmongodb package (mongo-r-driver) loaded
Use 'help("mongo")' to get started.

[1] TRUE
[1] "directly save and load"
   user  system elapsed 
  1.231   0.103   3.875 
[1] "serialized before save and load"
   user  system elapsed 
  0.751   0.105   3.377 
rmongodb package (mongo-r-driver) loaded
Use 'help("mongo")' to get started.

[1] TRUE
[1] "directly save and load"
   user  system elapsed 
  1.202   0.085   6.935 
[1] "serialized before save and load"
   user  system elapsed 
  0.752   0.082   3.996 
```

