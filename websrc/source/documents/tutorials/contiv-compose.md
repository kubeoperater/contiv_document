---
layout: "documents"
page_title: "Getting Started"
sidebar_current: "tutorials-contiv-compose"
description: |-
  Getting Started
---

## Networking Policies with Compose (**Deprecated**)

This tutorial shows how to use a modified *libcompose* utility to apply network policies on a Docker application composition.

### Prerequisites 
1. [Download Vagrant](https://www.vagrantup.com/downloads.html)
2. [Download Virtualbox](https://www.virtualbox.org/wiki/Downloads)
3. [Install git client](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
4. [Install docker for mac](https://docs.docker.com/docker-for-mac/install/)

**Note**:
- If you are using platform other than Mac, please install docker-engine, for that platform.


### Setup

#### Step 1: Get contiv installer code from github.
```
$ git clone git@github.com:contiv/install.git
$ cd install
```

#### Step 2: Run installer to install contiv + Docker Swarm using Vagrant on VMs created on VirtualBox

**Note**:
- Please make sure that you are NOT connected to VPN here.

```
make demo-legacy-swarm
```
This will create two VMs on VirtualBox. Using ansible, all the required services and software for contiv, will get installed at this step.
This might take some time (usually approx 15-20 mins) depending upon your internet connection.



#### Step 3: Download the Software

Get `libcompose` and log into a VM using the following commands:

```
$ mkdir -p $GOPATH/src/github.com/docker
$ cd $GOPATH/src/github.com/docker
$ git clone https://github.com/jainvipin/libcompose
$ cd $GOPATH/src/github.com/contiv/netplugin
$ make ssh
```

#### Step 4: Compile the Software
While logged into the VM, do the following to compile *libcompose*:

```
$ cd $GOPATH/src/github.com/docker/libcompose
$ git checkout deploy
$ make binary
$ sudo cp $GOPATH/src/github.com/docker/libcompose/bundles/libcompose-cli /usr/bin/contiv-compose
```
**Note:** These commands work only on a Linux host. 

#### Step 5: Build or Get Container Images
You can either build your own container images or download pre-built standard Docker images. 

You need two images, the *web* image and the *database* or *DB* image.

To build the web image, use the following commands:

```
$ cd $GOPATH/src/github.com/docker/libcompose/deploy/example/app
$ docker build -t web .
```

To use the pre-built web images from the Docker repository, do the following instead:

```
$ docker pull jainvipin/web
$ docker tag jainvipin/web web
```

Next, build or download the database image.

To build the database image:

```
$ cd $GOPATH/src/github.com/docker/libcompose/deploy/example/db
$ docker build -t redis -f Dockerfile.redis .
```

To download the database image:

```
$ docker pull jainvipin/redis
$ docker tag jainvipin/redis redis
```
**Note:** In the next step we'll use the command-line to create sample networks and policies. If you want to set up authentication and authorization, you can use contiv-ui instead.

### Build Networks and Create Policies
To demo the policies, first create a network:

```
netctl net create -s 10.11.1.0/24 dev
```

Run `contiv-compose` to create a policy:

```
$ cd $GOPATH/src/github.com/docker/libcompose/deploy/example
$ contiv-compose up -d
```

You should see system notifications similar to the following example:

```
WARN[0000] Note: This is an experimental alternate implementation of the Compose CLI (https://github.com/docker/compose)
INFO[0000] Creating policy contract from 'web' -> 'redis'
INFO[0000] Using default policy 'TrustApp'...           
INFO[0000] User 'vagrant': applying 'TrustApp' to service 'redis'
INFO[0000]   Fetched port/protocol) = tcp/5001 from image
INFO[0000]   Fetched port/protocol) = tcp/6379 from image
INFO[0000] Project [example]: Starting project          
INFO[0000] [0/2] [web]: Starting                        
INFO[0000] [0/2] [redis]: Starting                      
INFO[0000] [1/2] [redis]: Started                       
INFO[0001] [2/2] [web]: Started        
```

**Note:**

- For the `vagrant` user, `contiv-compose` assigned the default policy, named `TrustApp`. The `TrustApp` policy can be found in the `ops.json` file, which is a modifiable ops policy in the example directory where you ran the `contiv-compose` command.
- As defined in `ops.json`, the TrustApp policy permits all ports allowed by the application. The notification messages show that `contiv-compose` tries to fetch the port information from the redis image and applies an inbound set of rules to it.

Now, verify that the isolation policy is working as expected:

```
$ docker exec -it example_web_1 /bin/bash
< ** inside container ** >
# nc -zvw 1 example-redis 6375-6380
example_redis.dev.default [10.11.1.21] 6380 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6379 (?) open
example_redis.dev.default [10.11.1.21] 6378 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6377 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6376 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6375 (?) : Connection timed out

# exit
< ** back to linux prompt ** >
```

### Stop the Composition
Stop the composition and associated policies with the following commands:

```
$ cd $GOPATH/src/github.com/docker/libcompose/deploy/example
$ contiv-compose stop
```

## Going Further
Below are some more cases that you can demo using this Vagrant setup.

### 1. Scaling an Application Tier

You can scale any application tier. A policy belonging to a tier, service, or group is applied correctly as you scale the tier.

1\. Start the previous example, then use the following commands to scale the web tier:

```
$ contiv-compose up -d
$ contiv-compose scale web=5
```

2\. Log into any container in the web tier and verify the policy is being enforced. For example:

```
$ docker exec -it example_web_3 /bin/bash
< ** inside container ** >
# nc -zvw 1 example-redis 6375-6380
example_redis.dev.default [10.11.1.21] 6380 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6379 (?) open
example_redis.dev.default [10.11.1.21] 6378 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6377 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6376 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6375 (?) : Connection timed out

# exit

$ contiv-compose stop
$ contiv-compose rm -f
```

### 2. Changing the Default Network
You can change the default network. The default policy is still applied.

1\. Create a new network called `test`:

```
netctl net create -s 10.22.1.0/24 test
```

2\. Start a composition in the new network. To do so, edit the `docker-compose.yml` file to look like the following:

```
web:
  image: web
  ports:
   - "5000:5000"
  links:
   - redis
  net: test
redis:
  image: redis
  net: test
```

3\. Start the composition:

**Note:** The yaml file is sensitve to the extra whitespaces, and can fail with improper alignment. Make sure the yaml file has the exact same alignment as the code shown above.

```
$ contiv-compose up -d
```

The new composition runs in the `test` network as specified in the config file, while
policies are instantiated between the containers in test network

4\. Verify the policy between the containers as before:

```
$ docker exec -it example_web_1 /bin/bash
< ** inside container ** >
# nc -zvw 1 example-redis 6375-6380
example_redis.test.default [10.22.1.21] 6380 (?) : Connection timed out
example_redis.test.default [10.22.1.21] 6379 (?) open
example_redis.test.default [10.22.1.21] 6378 (?) : Connection timed out
example_redis.test.default [10.22.1.21] 6377 (?) : Connection timed out
example_redis.test.default [10.22.1.21] 6376 (?) : Connection timed out
example_redis.test.default [10.22.1.21] 6375 (?) : Connection timed out
# exit
$
```

To quit, stop the composition:

```
$ contiv-compose stop
```

### 3. Specfying an Override Policy
You can override the default policy.

1\. Use a *policy label* to specify an override policy for a service tier.

The following composition file has been modified to override the default policy:

```
web:
  image: web
  ports:        
   - "5000:5000"
  links:
   - redis
  net: test
redis:
  image: redis  
  net: test       
  labels:         
   io.contiv.policy: "RedisDefault"
```

Override policies for various users are specified outside the application composition in an 
operational policy file (ops.json), which states that vagrant user is allowed to use the policies *TrustApp*,
*RedisDefault*, and *WebDefault*:

```
                { "User":"vagrant",
                  "DefaultTenant": "default",
                  "Networks": "test,dev",
                  "DefaultNetwork": "dev",
                  "NetworkPolicies" : "TrustApp,RedisDefault,WebDefault",
                  "DefaultNetworkPolicy": "TrustApp" }
```

The override policy called `RedisDefault` is defined later in the file as:

```
                { "Name":"RedisDefault",
                  "Rules": ["permit tcp/6379", "permit tcp/6378", "permit tcp/6377"] },
```

2\. Start the composition and verify that appropriate ports are open:`

```
$ contiv-compose up -d

$ docker exec -it example_web_1 /bin/bash
< ** inside container ** >
# nc -zvw 1 example-redis 6375-6380
example_redis.test.default [10.22.1.26] 6380 (?) : Connection timed out
example_redis.test.default [10.22.1.26] 6379 (?) open
example_redis.test.default [10.22.1.26] 6376 (?) : Connection timed out
example_redis.test.default [10.22.1.26] 6375 (?) : Connection timed out
# exit
$
```

Note that ports 6377-6379 are not `timing out`, which means that network is
not dropping packets sent to the target `example_redis` service. The reason
only `6379` shows open is because redis container is listening on the port.

3\. Stop and clean up the demo environment:

```
$ contiv-compose stop
```

### 4. Verifying Role Based Access to Disallow Network Access

If a composition attempts to specify a network forbidden to it, contiv-compose produces an error.

1\. Create a "production" network:

```
$ netctl net create -s 10.33.1.0/24 production

$ cat docker-compose.yml
web:
  image: web
  ports:
   - "5000:5000"
  links:
   - redis
  net: production
redis:
  image: redis
  net: production
```

2\. Start the composition and note the error message produced because of the unauthorized network:

```
$ contiv-compose up -d
WARN[0000] Note: This is an experimental alternate implementation of the Compose CLI (https://github.com/docker/compose)
ERRO[0000] User 'vagrant' not allowed on network 'production'
```

### 5. Verifying Role Based Access to Disallow a Network Policy

If a composition attempts to specify a disallowed policy, contiv-compose produces an error.

1\. Specify an `AllPriviliges` policy for the vagrant user. The expected error results:

```
$ cat docker-compose.yml
web:
  image: web
  ports:
   - "5000:5000"
  links:
   - redis
redis:
  image: redis
  labels:
   io.contiv.policy: "AllPriviliges"

$ contiv-compose up -d
WARN[0000] Note: This is an experimental alternate implementation of the Compose CLI (https://github.com/docker/compose)
INFO[0000] Creating policy contract from 'web' -> 'redis'
ERRO[0000] User 'vagrant' not allowed to use policy 'AllPriviliges'
ERRO[0000] Error obtaining policy : Deny disallowed policy  
ERRO[0000] Failed to apply in-policy for service 'redis': Deny disallowed policy
FATA[0000] Failed to Create Network Config: Deny disallowed policy
```

### 6. Specifying an Override Tenant for applications to run in

You can use contiv-compose to run the applications in a non-default tenant.

**Note:** This example is for the demo. The tenant identity is typically retrieved from the user's context, users are not allowed to specify the tenant.

1\. Create a new tenant called `blue` and specify a network called `dev` in the `blue` tenant:

```
netctl tenant create blue
netctl net create -t blue -s 10.11.2.0/24 dev
```

2\. Create a composition that states the tenancy as:

```
$ cat docker-compose.yml
web:
  image: web
  ports:
   - "5000:5000"
  links:
   - redis
  labels:
   io.contiv.tenant: "blue"
redis:
  image: redis
  labels:
   io.contiv.tenant: "blue"

$ contiv-compose up -d
```

3\. Examine the compositions:

```
$ docker inspect example_web_1 | grep \"IPAddress\"
        "IPAddress": "",
                "IPAddress": "10.11.2.6",

$ docker inspect example_redis_1 | grep \"IPAddress\"
        "IPAddress": "",
                "IPAddress": "10.11.2.5",

```

**Note:** The allocated an IP address from the `blue` tenant's IP pool.

3\. Clean up the composition for the tenant:

```
$ contiv-compose stop
$ contiv-compose rm -f
```

### 7. Trying all this in a cluster of nodes

The cluster of nodes were already brought up during initiatization when we did `make demo`.
Now we start to issue the application bringup at cluster level.

1\. Enable docker-client to use swarm cluster by setting DOCKER_HOST to point to swarm master:

```
$ export DOCKER_HOST=tcp://netplugin-node1:2375
$ docker info
Containers: 8
 Running: 8
 Paused: 0
 Stopped: 0
Images: 11
Server Version: swarm/1.2.0
Role: primary
Strategy: spread
Filters: health, port, dependency, affinity, constraint
Nodes: 3
 netplugin-node1: 192.168.2.10:2385
  └ Status: Healthy
  └ Containers: 4
  └ Reserved CPUs: 0 / 4
  └ Reserved Memory: 0 B / 1.886 GiB
  └ Labels: executiondriver=, kernelversion=3.10.0-327.22.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=overlay
  └ Error: (none)
  └ UpdatedAt: 2016-08-23T21:45:27Z
  └ ServerVersion: 1.11.1
 netplugin-node2: 192.168.2.11:2385
  └ Status: Healthy
  └ Containers: 2
  └ Reserved CPUs: 0 / 4
  └ Reserved Memory: 0 B / 1.886 GiB
  └ Labels: executiondriver=, kernelversion=3.10.0-327.22.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=overlay
  └ Error: (none)
  └ UpdatedAt: 2016-08-23T21:45:18Z
  └ ServerVersion: 1.11.1
 netplugin-node3: 192.168.2.12:2385
  └ Status: Healthy
  └ Containers: 2
  └ Reserved CPUs: 0 / 4
  └ Reserved Memory: 0 B / 1.886 GiB
  └ Labels: executiondriver=, kernelversion=3.10.0-327.22.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=overlay
  └ Error: (none)
  └ UpdatedAt: 2016-08-23T21:45:24Z
  └ ServerVersion: 1.11.1
Plugins: 
 Volume: 
 Network: 
Kernel Version: 3.10.0-327.22.2.el7.x86_64
Operating System: linux
Architecture: amd64
CPUs: 12
Total Memory: 5.659 GiB
Name: 036770dba1db
Docker Root Dir: 
Debug mode (client): false
Debug mode (server): false
WARNING: No kernel memory limit support
```

Note above that we see three nodes with their respective IP addresses and status. If the status
is `healthy` we can proceed with running containers in the clusters.

2\. Start a composition within a cluster and scale web tier:

```
$ cd $GOPATH/src/github.com/docker/libcompose/deploy/example
$ contiv-compose up -d
WARN[0000] Note: This is an experimental alternate implementation of the Compose CLI (https://github.com/docker/compose) 
INFO[0003] Creating policy contract from 'web' -> 'redis' 
INFO[0003] Using default policy 'TrustApp'...           
INFO[0003] User 'vagrant': applying 'TrustApp' to service 'redis' 
INFO[0003]   Fetched port/protocol) = tcp/5001 from image 
INFO[0003]   Fetched port/protocol) = tcp/6379 from image 
INFO[0004] [0/2] [web]: Starting                        
INFO[0004] [0/2] [redis]: Starting                      
INFO[0012] [1/2] [web]: Started         

$ contiv-compose scale web=5
WARN[0000] Note: This is an experimental alternate implementation of the Compose CLI (https://github.com/docker/compose) 
INFO[0000] Applying labels based policies               
INFO[0000] Setting scale web=5...      

$ docker ps
CONTAINER ID        IMAGE                          COMMAND                  CREATED              STATUS                  PORTS               NAMES
c85185333297        web                            "/bin/sh -c 'python a"   8 seconds ago        Up Less than a second                       netplugin-node1/example_web_5
3e6a763d3397        web                            "/bin/sh -c 'python a"   15 seconds ago       Up 4 seconds                                netplugin-node1/example_web_4
9f3cb9d250a0        web                            "/bin/sh -c 'python a"   18 seconds ago       Up Less than a second                       netplugin-node1/example_web_3
b35131e3c9cc        web                            "/bin/sh -c 'python a"   22 seconds ago       Up Less than a second                       netplugin-node1/example_web_2
cffe972e91ec        redis                          "docker-entrypoint.sh"   27 seconds ago       Up 23 seconds           6379/tcp            netplugin-node3/example_redis_1
785ae44298a2        web                            "/bin/sh -c 'python a"   About a minute ago   Up About a minute                           netplugin-node1/example_web_1
28e0a339db96        skynetservices/skydns:latest   "/skydns"                13 minutes ago       Up 13 minutes           53/tcp, 53/udp      netplugin-node1/bluedns
4a5269013f09        skynetservices/skydns:latest   "/skydns"                3 hours ago          Up 3 hours              53/tcp, 53/udp      netplugin-node1/defaultdns
```

3\. Verify that policies work between containers running on different hosts:

```
$ docker exec -it example_web_1 /bin/bash
< ** inside container ** >
# nc -zvw 1 example-redis 6375-6380                                                                                                                   
Warning: inverse host lookup failed for 10.11.2.3: Unknown host
example-redis.blue [10.11.2.3] 6380 (?) : Connection timed out
example-redis.blue [10.11.2.3] 6379 (?) open
example-redis.blue [10.11.2.3] 6378 (?) : Connection timed out
example-redis.blue [10.11.2.3] 6377 (?) : Connection timed out
example-redis.blue [10.11.2.3] 6376 (?) : Connection timed out
example-redis.blue [10.11.2.3] 6375 (?) : Connection timed out
# exit
```

**Note:** `example_redis_1` and `example_web_1`
are running on `node3` and `node` respectively.

4\. Start another composition as `test` project, using the same template but a different project:

```
$ contiv-compose -p test up -d
WARN[0000] Note: This is an experimental alternate implementation of the Compose CLI (https://github.com/docker/compose) 
INFO[0005] Creating policy contract from 'web' -> 'redis' 
INFO[0005] Using default policy 'TrustApp'...           
INFO[0005] User 'vagrant': applying 'TrustApp' to service 'redis' 
INFO[0005]   Fetched port/protocol) = tcp/5001 from image 
INFO[0005]   Fetched port/protocol) = tcp/6379 from image 
INFO[0006] [0/2] [web]: Starting                        
INFO[0006] [0/2] [redis]: Starting                      
INFO[0012] [1/2] [redis]: Started                       
INFO[0014] [2/2] [web]: Started          

$ docker ps
er ps
CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS               NAMES
805f7fefa1bc        web                            "/bin/sh -c 'python a"   40 seconds ago      Up 34 seconds                           netplugin-node1/test_web_1
65a5ee71ac03        redis                          "docker-entrypoint.sh"   42 seconds ago      Up 36 seconds       6379/tcp            netplugin-node2/test_redis_1
c85185333297        web                            "/bin/sh -c 'python a"   2 minutes ago       Up 2 minutes                            netplugin-node1/example_web_5
3e6a763d3397        web                            "/bin/sh -c 'python a"   2 minutes ago       Up 2 minutes                            netplugin-node1/example_web_4
9f3cb9d250a0        web                            "/bin/sh -c 'python a"   2 minutes ago       Up 2 minutes                            netplugin-node1/example_web_3
b35131e3c9cc        web                            "/bin/sh -c 'python a"   2 minutes ago       Up 2 minutes                            netplugin-node1/example_web_2
cffe972e91ec        redis                          "docker-entrypoint.sh"   2 minutes ago       Up 2 minutes        6379/tcp            netplugin-node3/example_redis_1
785ae44298a2        web                            "/bin/sh -c 'python a"   3 minutes ago       Up 3 minutes                            netplugin-node1/example_web_1
28e0a339db96        skynetservices/skydns:latest   "/skydns"                15 minutes ago      Up 15 minutes       53/tcp, 53/udp      netplugin-node1/bluedns
4a5269013f09        skynetservices/skydns:latest   "/skydns"                3 hours ago         Up 3 hours          53/tcp, 53/udp      netplugin-node1/defaultdns

$ docker exec -it test_web_1 /bin/bash
< ** inside container ** >
# nc -zvw 1 example-redis 6375-6380   
Warning: inverse host lookup failed for 10.11.2.3: Unknown host
example-redis.blue [10.11.2.3] 6380 (?) : Connection timed out
example-redis.blue [10.11.2.3] 6379 (?) : Connection timed out
example-redis.blue [10.11.2.3] 6378 (?) : Connection timed out
example-redis.blue [10.11.2.3] 6377 (?) : Connection timed out
example-redis.blue [10.11.2.3] 6376 (?) : Connection timed out
example-redis.blue [10.11.2.3] 6375 (?) : Connection timed out
```

**Note:** Policies are enforced between respective compositions i.e. `test_web_1`
is unable to access `example_redis_1` database. However if we try to access `test_redis_1`
from it, that would be allowed on the specified ports.

```
# nc -zvw 1 teste-redis 6375-6380   
Warning: inverse host lookup failed for 10.11.2.8: Unknown host
test-redis.blue [10.11.2.8] 6380 (?) : Connection timed out
test-redis.blue [10.11.2.8] 6379 (?) open
test-redis.blue [10.11.2.8] 6378 (?) : Connection timed out
test-redis.blue [10.11.2.8] 6377 (?) : Connection timed out
test-redis.blue [10.11.2.8] 6376 (?) : Connection timed out
test-redis.blue [10.11.2.8] 6375 (?) : Connection timed out

# exit
```

This concludes the multi-host network isolation policy examples with Contiv.

### 8. Done playing with it all - Clean up
Exit the VM and use the following command to destroy the VMs crated for this tutorial

```
$ vagrant destroy -f
```


### Additional Information

- The demonstrations on this page use the Vagrant utility to set up a VM environment. This environment is for demonstrating automation and integration with Contiv Networking and is not meant to be used in production.
- User-based authentication uses the operational policy in `ops.json` as Docker's authorization
plugin, to permit only authenticated users to specify certain operations.
- Contributing to Contiv's *libcompose* variant is welcome! Run our provided unit and sanity tests before
submitting a pull request. Running `make test-deploy` and 'make test-unit` from the repository is sufficient. 

