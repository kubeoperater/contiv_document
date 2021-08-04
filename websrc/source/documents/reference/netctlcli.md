---
layout: "documents"
page_title: "CLI Reference for netctl"
sidebar_current: "reference"
description: |-
  netctl
---

#Command-Line Interface
Contiv uses the netctl command-line interface (CLI) to configure networks, policies, and service load balancers.

**Note:** netctl directly talks to netmaster, bypassing Contiv authentication and authorization. If you want to use this utility, set it up on a separate cluster node.

* [netctl](/documents/reference/netctlcli.html#netctl)
  * [aci-gw](/documents/reference/netctlcli.html#acigw)
  * [app-profile](/documents/reference/netctlcli.html#approfile)
  * [bgp](/documents/reference/netctlcli.html#bgp)
  * [endpoint, ep](/documents/reference/netctlcli.html#endpoint)
  * [external-contracts](/documents/reference/netctlcli.html#externalcontracts)
  * [global](/documents/reference/netctlcli.html#global)
  * [group](/documents/reference/netctlcli.html#group)
  * [login](/documents/reference/netctlcli.html#login)
  * [netprofile](/documents/reference/netctlcli.html#netprofile)
  * [network, net](/documents/reference/netctlcli.html#network)
  * [policy](/documents/reference/netctlcli.html#policy)
  * [service](/documents/reference/netctlcli.html#service)
  * [tenant](/documents/reference/netctlcli.html#tenant)
  * [version](/documents/reference/netctlcli.html#version)
  * [help](/documents/reference/netctlcli.html#help)

##<a name="netctl"></a>netctl 

###NAME:
   `netctl` - A new cli application

###USAGE:
   ```
   ./netctl [global options] command [command options] [arguments...]
   ```
   
###COMMANDS: 
   `aci-gw`				ACI Gateway information<br>
   `app-profile`		Application Profile manipulation tools<br>
   `bgp`				Router capability configuration<br>
   `endpoint, ep`		Endpoint Inspection<br>
   `external-contracts`	External contracts<br>
   `global`				Global information<br>
   `group`				Endpoint Group manipulation tools<br>
   `login`				Authenticate to Contiv
   `netprofile`			Network profile manipulation tools<br>
   `network, net`		Network manipulation tools<br>
   `policy`				Policy manipulation tools <br>
   `service`			Service object creation <br>
   `tenant`				Tenant manipulation tools<br>
   `version`			Version Information<br>
   `help, h`			Shows a list of commands or help for one command<br>

##GLOBAL OPTIONS:
   `--help, -h`				Show help <br>
   `--insecure`				Disable strict certificate checking <br>
   `--netmaster "http://netmaster:9999"`	The hostname of the netmaster [$NETMASTER] <br>
   `--version, -v`			Print the version <br>

##<a name="group"></a>group

###NAME:
`group` - Endpoint Group  manipulation tools 
   
###USAGE:

   ``` 
   netctl group command [command options] [arguments...] 
   ```

###COMMANDS:
   `create`		Create an endpoint group<br>
   `inspect`	Inspect a EndpointGroup<br>
   `rm, delete`	Delete an endpoint group<br>
   `ls, list`	List endpoint groups<br>
   `help, h`	Shows a list of commands or help for one command<br>
   
#####OPTIONS:
   `--help, -h`	show help

##<a name="acigw"></a>aci-gw

###NAME:
   `netctl aci-gw` - ACI Gateway information

###USAGE:
   ```netctl aci-gw command [command options] [arguments...]```

###COMMANDS:
   `info`	Show ACI gateway information<br>
   `inspect`	Inspect aci gateway operational information<br>
   `set`		Set aci-gw parameters.<br>
   `help, h`	Shows a list of commands or help for one command<br>

###OPTIONS:
   `--help, -h`	show help

##<a name="approfile"></a>app-profile

###NAME:
   `netctl app-profile` - Application Profile manipulation tools

###USAGE:
   ```netctl app-profile command [command options] [arguments...]```

###COMMANDS:
   `create`		Create an application profile <br>
   `update`	Update an application profile <br>
   `rm, delete`		Delete an application profile <br>
   `ls, list`		List application profiles <br>
   `group-ls, group-list`	List groups in an app-profile <br>
   `help, h`	Shows a list of commands or help for one command <br>
   
###OPTIONS:
   `--help, -h`	show help

##<a name="bgp"></a>bgp

###NAME:
   `netctl bgp` - Router capability configuration

###USAGE:
   ```netctl bgp command [command options] [arguments...]```

###COMMANDS:
   `ls, list`	List BGP configuration<br>
   `rm, delete`	Delete BGP configuration<br>
   `create`		Add BGP configuration.<br>
   `inspect`	Inspect BGP<br>
   `help, h`	Shows a list of commands or help for one command<br>
   
###OPTIONS:
   `--help, -h`	show help

##<a name="endpoint"></a>endpoint

###NAME:
`endpoint, ep` - Endpoint Inspection<br>

###USAGE:
   ```netctl endpoint command [command options] [arguments...]```

###COMMANDS:
   `inspect`	Inspect an Endpoint<br>
   `help, h`	Shows a list of commands or help for one command<br>

##<a name="externalcontracts"></a>external-contracts

###NAME:
   `netctl external-contracts` - External contracts

###USAGE:
   ```netctl external-contracts command [command options] [arguments...]```

###COMMANDS:
   `ls, list`	List external contracts<br>
   `rm, delete`	Delete external contracts<br>
   `create`		Create external contracts<br>
   `help, h`	Shows a list of commands or help for one command<br>
   
###OPTIONS:
   `--help, -h`	show help

##<a name="global"></a>global

###NAME:
   `netctl global` - Global information

###USAGE:
   ```netctl global command [command options] [arguments...]```

###COMMANDS:
   `info`		Show global information<br>
   `inspect`	Inspect global operational information<br>
   `set`		Set global parameters<br>
   `help, h`	Shows a list of commands or help for one command<br>
   
###OPTIONS:
   `--help, -h`	show help

##<a name="login"></a>login

Contiv comes with a proxy called [auth\_proxy](https://github.com/contiv/auth\_proxy) which transparently sits in front of netmaster and provides authentication (Active Directory, LDAP, local users) and authorization (RBAC).  netctl can send requests to auth_proxy as if it were sending requests directly to netmaster.  For more details, please see [the auth\_proxy repo](https://github.com/contiv/auth\_proxy).

You must login before you can send any netctl requests to auth_proxy.  Any requests destined for auth\_proxy must include the global `--netmaster` flag with the full HTTPS auth\_proxy URL as the value.

If the target auth\_proxy is using an expired, invalid, or untrusted certificate, you will additionally need to specify the global `--insecure` flag.

netctl stores its auth\_proxy access token under `$HOME/.netctl/config.json`.  To "logout", simply delete this file.

###NAME:
   `netctl login` - Authenticate to Contiv

###USAGE:

In these examples, set `$AUTH_PROXY_URL` to the full HTTPS auth_proxy URL.  This will look something like: `https://1.2.3.4:10000`

#### Login (you will be prompted for your username and password)
   ```netctl --netmaster=$AUTH_PROXY_URL login```

#### Send authenticated request (token is automatically sent)
   ```netctl --netmaster=$AUTH_PROXY_URL network ls```

#### Send request to auth_proxy with untrusted certificate
   ```netctl --insecure --netmaster=$AUTH_PROXY_URL network ls```

##OPTIONS:
   `--help, -h	show help`

##<a name="netprofile"></a>netprofile

###NAME:
   `netctl netprofile` - Network profile manipulation tools

###USAGE:
   `netctl netprofile command [command options] [arguments...]`

###COMMANDS:
   `create`		Create a network profile<br>
   `rm, delete`	Delete a network profile<br>
   `ls, list`	List network profile<br>
   `inspect`	Inspect network profile <br>
   `help, h`	Shows a list of commands or help for one command<br>

##OPTIONS:
   `--help, -h	show help`

##<a name="network"></a>network 

###NAME:
   `netctl network` - Network manipulation tools

###USAGE:
   ```netctl network command [command options] [arguments...]```

###COMMANDS:
   `ls, list`	List networks <br>
   `inspect`	Inspect a network <br>
   `rm, delete`	Delete a network<br>
   `create`		Create a network<br>
   `help, h`	Shows a list of commands or help for one command<br>
   
###OPTIONS:
   `--help, -h	show help`

##<a name="policy"></a>policy

###NAME:
  `netctl policy` - Policy manipulation tools

###USAGE:
   ```netctl policy command [command options] [arguments...]```

###COMMANDS:
   `create`		Create a new policy<br>
   `rm, delete`	Delete a policy<br>
   `ls, list`	List policies<br>
   `inspect`	Inspect a policy<br>
   `rule-ls`	List rules for a given tenant, policy<br>
   `rule-rm`	Delete a rule from the policy<br>
   `rule-add`	Add a new rule to the policy<br>
   `help, h`	Shows a list of commands or help for one command<br>
   
###OPTIONS:
   `--help, -h`	show help

##<a name="service"></a>service

###NAME:
   `netctl service` - Service object creation

###USAGE:
   ```netctl service command [command options] [arguments...]```

###COMMANDS:
   `ls, list`	List service objects <br>
   `inspect`	Inspect a Network<br>
   `rm, delete`	Delete service object<br>
   `create`	Create Service object.<br>
   `help, h`	Shows a list of commands or help for one command<br>
   
###OPTIONS:
   `--help, -h`	show help

##<a name="tenant"></a>tenant

###NAME:
   `tenant` Tenant manipulation tools <br>

###USAGE:
   ``` netctl tenant command [command options] [arguments...]```

###COMMANDS:
   `ls, list`	List tenants <br>
   `rm, delete`	Delete a tenant<br>
   `create`		Create a tenant<br>
   `inspect`	Inspect a tenant<br>
   `help, h`	Shows a list of commands or help for one command<br>

###OPTIONS:
   `--help, -h`	show help

##<a name="version"></a>version
   
`netctl version`  Version Information for netctl client and sever, git commit hash, and build time.

##<a name="help">help

`netctl help` Shows help information

   

