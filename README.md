# Private VPN Node Builder

This repository contains scripts and templates that allow you to launch and manage VPN nodes in your personal public cloud account. The nodes are built using a cloud appliance which can configure itself to run OpenVPN or IPSec/IKEv2 VPN services. The `bin\vs` CLI can be used to launch the service in any one of Amazon Web Services, Microsoft Azure or Google Cloud Platform public cloud environments.

> Disclaimer: We believe in the right to privacy, not piracy or hiding illegal activity on the internet. While this tool is targeted for users wishing to maintain their privacy from ISPs and web sites that track activity on the internet, we do not endorse or condone any inappropriate use of this VPN service including but not limited to: hacking, cracking, sharing, downloading copyrighted materials, or conducting illegal activity. 

## Overview

The VPN Node Builder utility scripts orchestrate the creation of VPN nodes and personal cloud spaces in the public cloud by means of the [Terraform](https://terraform.io) templates. Two main VPN server protocol types can be built.

* [IPSEC/IKev2](https://www.strongswan.org/)
* [OpenVPN](https://openvpn.net/)

The appliance can manage basic routing to internal Virtual Private Cloud (VPC) networks and can also peer nodes across regions. Additionally each appliance has built in automation to launch additional services within the VPC if instructed to do so. These are advance features of the appliance which are not enabled in the basic VPN appliance. The templates to launch the appliance in the various clouds are available as [Terraform modules](https://github.com/appbricks/cloud-inceptor) and are used by the scripts in this repository to manage the deployment of the VPN service to various cloud regions.

## Installation

### Executing the scripts directly

The scripts in this repository can be run directly if you have a workstation that has `bash` installed along with all the pre-requisite CLIs. The following CLIs are required by the scripts.

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Google SDK](https://cloud.google.com/sdk/docs)
* [Terraform CLI](https://www.terraform.io/downloads.html)
* [JQ CLI](https://stedolan.github.io/jq/)

Also note that if you wish connect via an obfuscation tunnel then the tunnel clients will need to be built locally. Details can be found in the VPN config downloaded from the VPN server running the obfuscation tunnel services.

Steps to run the scripts directly.

1) Install the CLIs and ensure they are available in the system path.
2) Clone this repository.
3) Add the path `<Repository Home>/bin` to your system path.

### Running the scripts via a pre-built container

The scripts in this repository are also distributed as a [Docker](https://www.docker.com/) container. This approach will allow you to run this scripts from environments that do not have the `bash` shell installed such as Micrsoft Windows. To run the the CLI via the container add the following alias to your system.

* In Mac OSX or Linux

  ```
  alias vs='docker run --privileged --rm -p 4495:4495 -p 4495:4495/udp -v $(pwd)/:/vpn -it appbricks/vpn-server'
  ```

## Usage

The `vs` CLI script provides the following options.

```
USAGE: vs <COMMAND> [options]

  This CLI manages personal cloud VPN nodes in multiple cloud regions.

  <COMMAND> should be one of the following:

    init                                    Initializes the current folder with the
                                            control files which contain the environment
                                            for running deployment scripts.

    show-regions <CLOUD>                    Show regions nodes can be created in.

    deploy-node <VPN_TYPE> <CLOUD>          Deploys or updates a personal VPN node.

    reinit-node <VPN_TYPE> <CLOUD>          Reinitializes a VPN node's remote state.

    destroy-node <VPN_TYPE> <CLOUD>         Destroys a VPN node.

    download-vpn-config <VPN_TYPE> <CLOUD>  Downloads the client VPN configuration.

    start-tunnel <CLOUD>                    Starts tunnel services which obfuscate VPN
                                            traffic to a node. This is available only for "ovpn-x"
                                            type VPNs.

    show-nodes                              Show all deployed nodes and their status.
```