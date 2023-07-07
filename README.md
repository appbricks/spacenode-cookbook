# MyCS SpaceNode Cookbook

[![Build Status](https://github.com/appbricks/spacenode-cookbook/actions/workflows/build-dev-release.yml/badge.svg)](https://github.com/appbricks/spacenode-cookbook/actions/workflows/build-dev-release.yml)
[![Build Status](https://github.com/appbricks/spacenode-cookbook/actions/workflows/build-prod-release.yml/badge.svg)](https://github.com/appbricks/spacenode-cookbook/actions/workflows/build-prod-release.yml)


This repository contains scripts and templates that allow you to launch and manage MYCS Space nodes in your personal public cloud account. The nodes are built using a cloud appliance which can configure itself to run OpenVPN or IPSec/IKEv2 VPN services. The `bin\snb` CLI can be used to launch the service in any one of Amazon Web Services, Microsoft Azure or Google Cloud Platform public cloud environments.

> Disclaimer: We believe in the right to privacy, not piracy or hiding illegal activity on the internet. While this tool is targeted for users wishing to maintain their privacy from ISPs and web sites that track activity on the internet, we do not endorse or condone any inappropriate use of this service including but not limited to: hacking, cracking, sharing, downloading copyrighted materials, or conducting illegal activity.

## Overview

The SpaceNode Builder utility scripts orchestrate the creation of Space nodes and personal cloud spaces in the public cloud by means of the [Terraform](https://terraform.io) templates. Space nodes with the following two VPN protocol types can be built.

* [OpenVPN](https://openvpn.net/)
* [IPSEC/IKev2](https://www.strongswan.org/)

OpenVPN traffic can be masked via a tunnel that obfuscates OpenVPN traffic to enable bypassing deep packet inspection at the service provider. This will, however, impact performance.

The appliance can manage basic routing to internal Virtual Private Cloud (VPC) networks and can also peer nodes across regions. Additionally each appliance has built in automation to launch additional services within the VPC if instructed to do so. These are advance features of the appliance which are not enabled in the basic VPN appliance. The templates to launch the appliance in the various clouds are available as [Terraform modules](https://github.com/appbricks/cloud-inceptor) and are used by the scripts in this repository to manage the deployment of the VPN service to various cloud regions.

> These templates may also be configured to setup a [WireGuard](https://www.wireguard.com/) VPN. This feature is only available via the [Cloud-Builder](https://github.com/appbricks/cloud-builder-cli) CLI.

## Installation

On the [releases page](https://github.com/appbricks/spacenode-cookbook/releases), you can find install scripts to install the CLI to you personal workstation from where you can launch, run and manage the Space nodes.

### Executing the scripts directly

The scripts in this repository can be run directly if you have a workstation that has `bash` installed along with all the pre-requisite CLIs. The following CLIs are required by the scripts.

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Google SDK](https://cloud.google.com/sdk/docs)
* [Terraform CLI](https://www.terraform.io/downloads.html)
* [JQ CLI](https://stedolan.github.io/jq/)

Also note that if you wish connect via an obfuscation tunnel then the tunnel clients will need to be built and available locally. Details can be found in the VPN config downloaded from the VPN server running the obfuscation tunnel services.

Steps to run the scripts directly.

1) Install the CLIs and ensure they are available in the system path.
2) Clone this repository.
3) Add the path `<Repository Home>/bin` to your system path.

### Running the scripts via a pre-built container

The scripts in this repository are also distributed as a [Docker](https://www.docker.com/) image. The install scripts provided on the [releases page](https://github.com/appbricks/spacenode-cookbook/releases), installs an alias to run the CLI via this container. This approach will allow you to run these scripts from within environments that do not have the `bash` shell installed such as Micrsoft Windows. To run the the CLI via the container add the following alias to your system if you are unable to use the scripts in the release page.

For this approach Docker is the only pre-requisite and it can be installed from [Docker Hub](https://www.docker.com/products/docker-desktop).

* In Mac OSX or Linux

  ```
  alias snb='docker run --privileged --rm -p 4495:4495 -p 4495:4495/udp -v $(pwd)/:/vpn -it appbricks/spacenode-cookbook:<VERSION>'
  ```

* In Windows create a batch file in `C:\Windows\System\snb.bat` or a path added to the `PATH` system environment variable with the following contents.

  ```
  docker run --privileged --rm -p "4495:4495" -p "4495:4495/udp" -v "%cd%:/vpn" -it "appbricks/spacenode-cookbook:<VERSION>" %*
  ```

## Usage

The `snb` CLI script provides the following options.

```
USAGE: snb <COMMAND> [options]

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

### Initializating a Workspace Folder

Before you can launch VPN nodes using the the CLI you need to initialize a workspace folder where the control files containing credentials and node configuration will be kept. Follow the steps below to initialize your workspace.

1) Create a folder where you will run the `init` command from. Change directory to that folder and from with a command shell run:

  ```
  snb init
  ```

  If you have not already done, accept the EULA and proceed to edit the control files which will be created in your workspace folder.

2) Create you public cloud accounts.

  Two control files were created when you initialized your workspace. The first control file should contain your public cloud account credentials and is named `cloud-creds.sh`. You will need to retrieve the credentials from you public cloud accounts and add them to the corresponding variable in the control file.

  ```
  # AWS IaaS credentials for Terraform
  export AWS_ACCESS_KEY=
  export AWS_SECRET_KEY=

  # GCP IaaS credentials for Terraform
  export GOOGLE_CREDENTIALS=
  export GOOGLE_PROJECT=

  # Azure IaaS credentials for Terraform
  export ARM_SUBSCRIPTION_ID=
  export ARM_TENANT_ID=
  export ARM_CLIENT_ID=
  export ARM_CLIENT_SECRET=
  ```

  The second file contains VPN node configuration settings required by the Terraform templates to launch the recipe in the cloud of you choosing. It has the following contents.

  ```
  # Deployment idenfifier or name
  export TF_VAR_name=

  # DNS Zone for all deployments
  export TF_VAR_attach_dns_zone=false

  # Uncomment only if attaching to a DNS zone
  # - AWS DNS configuration
  #export TF_VAR_aws_dns_zone=
  # - Azure DNS configuration
  #export TF_VAR_azure_dns_zone=
  #export TF_VAR_azure_dns_zone_resource_group=
  # - Google DNS configuration
  #export TF_VAR_google_dns_managed_zone_name=
  #export TF_VAR_google_dns_zone=

  # Values to used for creating self-signed X509 certs
  export TF_VAR_company_name="appbricks"
  export TF_VAR_organization_name="appbricks dev"
  export TF_VAR_locality="Boston"
  export TF_VAR_province="MA"
  export TF_VAR_country="US"

  export TF_VAR_vpn_users='[
    "user|password"
  ]'
  ```

  The `TF_VAR_name` variable gives your deployment a unique name. This name is used to create the cloud storage buckets where the state of a vpn node deployment to a particular region is saved. This name needs to be universally unique and it is possible the name you choose will clash. In such a case you will have to choose an alternate name that does not cause an error.

  The `TF_VAR_<cloud>_dns_zone` variable should be a domain name and is used to create a hosted zone in the target cloud account. If `TF_VAR_<cloud>_dns_zone` is not empty and `TF_VAR_attach_dns_zone=true` is explicitly set, then the template will attempt to locate the parent zone to update within the same cloud account. This can cause errors if the parent zone does not exist in the same clound account. If you would like to make you VPN nodes discoverable via DNS and have a domain that is hosted by a different provider, provide the zone name but do not set the `TF_VAR_attach_dns_zone` variable. You will then have to extract the created zone's nameservers and add them to the provider where the parent zone is hosted.

  > You do not need to set the domain name to be able to deploy and use the Cloud VPN nodes.

  You can use the `TF_VAR_vpn_users` variable to provide a list of users that VPN nodes will always be populated with. You can also create additional users on a node via the CLI, but they will not persist across to other nodes you have deployed.

### Deploying Externally Sourced Recipes

By default this cookook will only deploy recipes within this repo. The recipes available within this repo's cookbook can be found at `spacenode-cookbook/cloud/recipes/` folder. This recipe can be used to deploy a sandbox network to one of the three major public clouds AWS, Azure or Google. Once deployed additional recipes can be deployed to the sandbox cloud environment. To include recipes from an external repo export the following environment variable.

```
export COOKBOOK_REPO=<local PATH TO cookbook REPO>
```

### Developing Cookbook Recipes

You can also use this CLI to develop and test your own recipes to deploy apps and services to a space node's cloud environment. In order to use the container to develop and test an application cookbook set the following environment variable.

```
export COOKBOOK_REPO=<local PATH TO cookbook REPO being developed/tested>
```

> Only one cookbook repo can be developed and tested at a time.

To be able to deploy an externally sourced recipe, the recipe must exist in a repo folder with the templates in the path `<COOKBOOK_REPO>/cloud/recipes/`. The terraform templates within that folder can source outputs from the *sandbox* deployment via the following input variables.

> Retrieving remote state from the sandbox is not supported directly due to security concerns outlined in the documentation of the [remote-state-data](https://developer.hashicorp.com/terraform/language/state/remote-state-data) data source.

| Input Variable | Type | Description |
|:-------------- |:---- |:----------- |
|cb_node_description|string|
|cb_node_version|string|
|cb_root_ca_cert|string|
|cb_vpc_id|string|
|cb_vpc_name|string|
|cb_deployment_networks|list(string)|
|cb_deployment_security_group|string|
|cb_default_ssh_private_key|string|
|cb_default_ssh_key_pair|string|
|cb_dns_configured|boolean|
|cb_internal_domain|string|
|cb_internal_pdns_url|string|
|cb_internal_pdns_api_key|string|
|cb_vpn_type|string|
|cb_vpn_masking_available|boolean|
|cb_idle_action|string|

You can also debug changes to the CLI scripts by exporting the following environment variable.

```
export VPN_SERVER_REPO=<local PATH TO https://github.com/appbricks/spacenode-cookbook REPO>
```

These environment variables mount the local repo folders within the container allowing you to test changes to the scripts and templates without rebuilding the image.
