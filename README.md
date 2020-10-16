# factotum

> fac·to·tum /fakˈtōdəm/ _noun_: an employee who does all kinds of work. From medieval latin _fac!_ (do!) and _totum_ (the whole thing)

A kubernetes-oriented general purpose docker container for devs/devops and custom CI/CD pipelines.

# Motivation

It is a non-trivial endeavour for all developers and devops to maintain their local environment with a cohesive set of tools within and across teams, with proper versions and configurations, including different kubernetes contexts. Not only all engineers eventually end up having their environments and tool versions drifting from each others, but their CI/CD pipelines often also diverge significantly from the environments they use locally.

We settled to address that issue by engineering a unique multiple-purpose docker container that can be shared within and across teams, as well as reused directly within CI/CD pipelines, allowing everyone to rely on a cohesive and well-known environment and set of tools.

However, using a docker container in such a way comes with its own challenges, such as installing, upgrading and running the container, automatically mounting local files and folders as volumes, passing different sets of environment variables for each execution context or kubernetes cluster, etc.

Factotum strives to address all those challenges and more, while making it fun and easy to use! :)

# Features

- Easy installation and upgrade
- Easy configuration of multiple contexts/kubernetes clusters/sets of env vars via a single YAML config file
- Running multiple sessions in parallel using different contexts
- Support for different cloud providers (currently AWS and GCP)
  - Automatically authenticate with cloud provider
  - Automatically retrieve kubectl cluster contexts
- Configurable mounted volumes to simplify interfacing container with host machine (ie: your local home folder, ~/.ssh...)
- Automatic injection of local files into specific locations in container (ie: to persist outside container all your important config files across sessions/installs)
- ZSH shell with nice prompt showing current kubectl context/namespace and git status, as well as tab-completion for multiple CLIs

# Getting started

Even if factotum is intended to be forked and customized to your own needs, you can still install and run it as is, to get more familiar with it first. See section entitled "How to create your own customized version of factotum" below when you're ready to step up to the next level! :)

## Prerequisites

- [Docker Desktop for Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac)
- [iTerm2](https://www.iterm2.com/) (recommended)
- [Droid Sans Mono Nerd Font Complete.otf](https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf) (recommended to display prompt correctly)

## Install factotum

```bash
$ curl -sfL https://raw.githubusercontent.com/Samasource/factotum/master/bootstrap.sh | bash -
```

### Installing to different name

To install factotum to a different name (ie: to install multiple versions in parallel), simply export the following variable before invoking the above command:

```bash
$ export APP_NAME=factotum2
```

## Customize factotum config

You should now customize your `~/.factotum/config.yaml` file. It will initially have example values like this:

```yaml
contexts:
  - name: cluster1
    env:
      KUBE_CONTEXT: cluster1
      # REGION: us-east-2
  - name: cluster2
    env:
      KUBE_CONTEXT: cluster2

env:
  CLOUD: aws # supported clouds: aws, gcp
  REGION: us-east-1

volumes:
#  $HOME/.ssh: /root/.ssh
#  $HOME/.gitconfig: /root/.gitconfig
#  $HOME/.aws: /root/.aws
#  $HOME/.config/gh: /root/.config/gh
#  $HOME/.cfconfig: /root/.cfconfig
```

The `contexts` section defines environment variables specific to each context/cluster (only exported when you use that context).

The `env` section defines environments variables common to all contexts (always exported, no matter the context, but can be overriden at context-level).

The `volumes` section defines volumes to mount in docker, as "{host_path}: {container_path}" key/value pairs.

## Launch factotum

To display help and the list of available contexts (that you defined in your `config.yaml` file):

```bash
$ factotum
```

To start factotum using a given context:

```bash
$ factotum use CONTEXT
```

## Authenticate with cloud provider

Upon first start, you may be prompted to authenticate with AWS or GCP, if you were not already authenticated. Your credentials will be persisted outside the container and reused on future factotum startups.

# Upgrading to latest version

```bash
$ factotum upgrade
```

Note: You must stop currently running containers (see below) and restart them in order to take advantage of latest version.

# Stopping containers

To stop all containers associated with a given context:

```bash
$ factotum stop CONTEXT
```

# Understanding important directories and files

## On your local machine

Upon install — but only if they didn't already exist — the following directories will be automatically created under your local home directory (because they are automatically mounted at container startup):

### ~/.factotum

All local factotum configs and other files.

### ~/.factotum/config.yaml

Configuration of environment variables for different contexts or kubernetes clusters.

### ~/.factotum/inject

Files to be copied into container upon fresh startup (see "Injecting files" section).

### ~/.factotum/bin

Local scripts that you want to make available within the container.

## Within factotum container

### /root

Your home folder within factotum (`root` is the default user).

### /local

A volume mounted from your local `~` directory, useful for sharing files between factotum and your local machine.

# Injecting files

You might want some of the files that you create and customize within the image to persist, even when you do a fresh startup, upgrade or reinstall factotum. Unless those files are stored in one of the special mounted directories, they are usually discarded in such cases. However, factotum provides a mechanism called injection allowing to save those precious internal files outside of the container and have them automatically copied back to their respective locations at every fresh startup.

Every time you start a fresh container, factotum automatically copies whatever files you placed in your local machine's `$HOME/.factotum/inject` directory into the container's locations matching the directory hierarchy within the `inject` directory.

A different "fresh" container is created for each combination of factotum version and context that you start. That means that different contexts each run in their own independent container and that upgrading factotum also results in new containers being created afterwards.

## Exporting files for injection

The easiest way to setup injection when you already have a file or directory in your container that you want to persist via injection is to use the `copy-to-inject` factotum script:

```bash
$ copy-to-inject PATH
```

Where PATH is the relative or absolute path to the file or folder to save for injection.

At the next fresh startup, that directory will automatically be copied back to its original location.

## Forcing injection

Injection normally only occurs upon a fresh start of the container, but you can force an immediate re-injection like this:

```bash
$ inject
```

NOTE: This command does a synchronization of the files, so you never risk overwriting more recent changes.

# Pre-installed command line tools

- aws cli
- curl
- envsubst - expand env variables in stream
- gh - github cli
- git \*
- golang - go build tools
- gcc - c build tools
- gcloud cli \*
- helm 3
- hub - github cli \*
- ip - ([iproute2](https://en.wikipedia.org/wiki/Iproute2))
- jq - json query tool
- [k9s](https://github.com/derailed/k9s) - terminal UI to manage Kubernetes clusters
- kubectl \*
- ksd - k8s secret decoder
- manpages
- node
- [oh-my-zsh](https://ohmyz.sh/) - plugin/theme manager for zsh
- ping
- terraform cli \*
- [tldr](https://tldr.sh/) - unix command quick reference
- unzip
- uuid-runtime
- vim
- wget
- yq - yaml query tool (version by Mike Farah)
- yq2 - yaml query tool (python version, wrapper around jq)
- [zsh](https://www.zsh.org) - an alternative to bash

( \* Tab auto-completion is currently configured for those CLIs )

# How to create your own customized version of factotum

## Fork this git repo

Forking this git repo will allow you to fully customize your own version of factotum, while retaining the capability to merge in improvements made to the mainstream repo and contribute your own improvements back to it.

## Set up container repo

You can host your factotum images on any container registry, such as Docker Hub, AWS ECR or Google GCR.

### Note on secrets and private repos

Just be wary — especially if you use a publicly exposed repository — never to leak any secrets into your images. Because it is very difficult to guaranty such leaks never happen, we highly recommend using a private container repo.

## Customize files

### /Dockerfile

We have already configured the Dockerfile with all the tools that we use in our own development process, but feel free to review and customize it as you see fit, adding the tools you need and removing those you don't. This will be a daily working environment, make it feel like home! :)

### /bootstrap.sh

This script will be curled and sourced by users to install factotum from scratch, as explained in "Install factotum" section, so it should be readily accessible via https, either directly via your git repo in raw mode (as we are doing here) or by hosting it somewhere (ie: an S3 bucket).

That script's role is to determine the latest factotum image available in container repo and use that factotum image to render and run the install script. In other words, factotum is used to install itself!

Make sure to configure that script to point to your own container registry and repo. Also update the `curl` URL in the "Install factotum" section above to make it point to wherever you are hosting your `bootstrap.sh` script.

See section "How factotum bootstrapping, installation and launching works" below for more details about the installation process.

### /filesystem/templates/install/config.yaml

This file is used to create a default `~/.factotum/config.yaml` file on user's machine at install-time. If you want your users to have a sensible config file to start with, possibly configured with your specific kubernetes clusters and other custom environment variables, you can customize that file here. Just avoid putting in any secrets!

### /filesystem/root/.\*rc

Optionally, customize all the `.*rc` files to your own needs.

### /README.md

Update present document to reflect your modifications to factotum.

## Set up an automated build pipeline (recommended)

You will constantly be making improvements to your factotum image, so make sure to make it as seamless as possible to build and push new revisions.

### How we do it

In our case, we have set up a Codefresh pipeline that triggers upon any commit, builds the new image and pushes it to our ECR repo, while tagging it using the base version specified in `/release.yaml` and appending the number of seconds elapsed since unix epoch (ie: `0.0.3-1601391422`) which can be generated by the `date +%s` unix command. Having such sequentially incrementing image tags allows us to automatically figure latest available factotum image in the `bootstrap.sh` script, without ever having to resort to the `latest` docker tag (which should be avoided as much as possible).

# Using ECR with factotum

You can host your factotum images on any container registry (Docker Hub, ECR, GCR), but as we are using ECR, we have added built-in support for it.

## Check your AWS CLI version

Ensure that you have at least version 2.xx.x of [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html) installed by typing:

```bash
$ aws --version
aws-cli/2.0.52 Python/3.7.3 Linux/4.19.76-linuxkit exe/x86_64.ubuntu.18
```

## Login to ECR without factotum

```bash
$ aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REPO_OWNER_ID}.dkr.ecr.us-east-1.amazonaws.com
```

## Login to ECR using factotum

After factotum has been installed you can use this alternate and simpler syntax, which is equivalent to above command:

```bash
$ factotum login ecr
```

That is very handy, especially as the ECR authentication automatically expires every 24 hours.

# How factotum bootstrapping, installation and launching works

## Bootstrap script

The `/bootstrap.sh` script must be accessible to your users in some way, either by making this repo public or by manually copying
that file to some public S3 bucket.

As described in the installation instructions, that script is intended to be sourced directly by users from their host machine
in order to kick-off the installation of factotum.

That script must be customized to your specific container registry and repo.

The bootstrap script's job is to:

- determine the latest factotum image version/tag available in container repo
- pull that image from repo
- render the `/templates/install/install.gotmpl` go template to a temporary `install` script and execute it locally (detailed next)

## Install script

The install script's job is to:

- Ensure pre-requisites are already installed locally
- Create special folders locally and the default `~/.factotum/config.yaml` file based on `/templates/install/config.yaml`, if not already present
- Render the `/templates/install/factotum.gotmpl` go template to generate the `/usr/local/bin/factotum` launch script locally

## Launch script

The `factotum` launch script's job is to allow user to perform different operations on local machine, such as:

- launch the factotum docker container
- stop currently running container
- upgrade factotum to latest version

For more details, invoke `factotum` without any parameters.
