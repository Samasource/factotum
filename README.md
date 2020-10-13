# factotum

> fac·to·tum /fakˈtōdəm/ _noun_: an employee who does all kinds of work. From medieval latin _fac!_ (do!) and _totum_ (the whole thing)

A kubernetes-oriented general purpose docker container for devs/devops and custom CI/CD pipelines

It features:

- Easy installation and upgrade
- Easy configuration of multiple contexts/clusters/sets of env vars via a single YAML config file
- Support for running multiple sessions in parallel using different contexts/clusters/env vars
- Support for different cloud providers (currently AWS and GCP)
  - Automatic authentication with cloud provider
  - Automatic retrieval of kubectl cluster contexts
- Multiple automatically mounted volumes to simplify interfacing container with host machine (ie: your local home folder, ~/.ssh...)
- Automatic injection of local files into specific locations in container (ie: to persist important config files across sessions/installs)
- ZSH shell with nice prompt showing current kube context/namespace and git status, as well as tab-completion for multiple CLIs

Note that Factotum is not necessarily intended to be used as is, but rather forked and customized to your specific environment and
needs. We have already configured it with all the tools that we do use in our own development process, but feel free to review the
Dockerfile and customize it as you see fit.

# Getting started

## Prerequisites

### [Docker Desktop for Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac)

Note that you will need a DockerHub account in order to download it.

### Access to container registry

You will need read permissions to the container registry hosting your own version of the factotum image.

### [iTerm2](https://www.iterm2.com/)

A good terminal is optional - but highly recommended! :)

### Powerline compliant patched font

It is optional - but highly recommended - to install a Powerline compliant patched font in order to display the command prompt correctly.

- Download this file: [Droid Sans Mono Nerd Font Complete.otf](https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf)
- Double-click on file and press "Install". This will make the font available to all applications on your system.
- Configure your terminal to use this font:
  - **iTerm2**: Open _iTerm2 → Preferences → Profiles → Text_ and set _Font_.
  - **Visual Studio Code**: Open _File → Preferences → Settings_, enter `terminal.integrated.fontFamily` in the search box and set the value.

## Authenticate with container registry

You must first login to the container registry where you are hosting your factotum image.

### Using ECR

NOTE: This section only applies if you are using ECR to host your factotum image.

Ensure that you have at least version 2.xx.x of [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html) installed by typing:

```bash
$ aws --version
aws-cli/2.0.52 Python/3.7.3 Linux/4.19.76-linuxkit exe/x86_64.ubuntu.18
```

Then run:

```bash
$ aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 000000000000.dkr.ecr.us-east-1.amazonaws.com
```

NOTE: _After_ factotum is installed, you will be able to use this alternate and simpler syntax, which is equivalent to above command:

```bash
$ factotum login ecr
```

## Install factotum

NOTE: If you forked this repo to create your own version of factotum, update the URL below to reflect your repo's location.

```bash
$ curl -sfL https://raw.githubusercontent.com/Samasource/factotum/master/bootstrap.sh | bash -
```

Upon install, only if it doesn't already exist, the following folder structure will be automatically created under your local \$HOME directory:

- `.ssh`
- `.aws`
- `.factotum`
  - `inject`
  - `bin`

## Customize factotum config

Customize the `~/.factotum/config.yaml` configuration file to reflect your cloud provider and kubernetes clusters.

That file was created with placeholder values during first install, but it will never be overwritten afterwards, even if you reinstall factotum.

## Launch factotum

To display help and the list of available contexts (defined in your config.yaml file), type:

```bash
$ factotum
```

To start factotum using a given context, type:

```bash
$ factotum use CONTEXT
```

## Authenticate with cloud provider

Upon first start, you may be prompted to authenticate with AWS or GCP, if you were not already authenticated. Your credentials will be persisted outside the container and reused on future factotum startups.

## Authenticate Codefresh (optional)

Generate a Codefresh API key from your [user settings](https://g.codefresh.io/user/settings) page and use it to authenticate the Codefresh CLI:

```bash
$ codefresh auth create-context --api-key API_KEY
```

For more info, see [Authenticate Codefresh CLI](https://codefresh-io.github.io/cli/getting-started/#authenticate)

# Factotum directory structure

## /root

Your home folder within factotum (`root` is the default user).

## /root/.ssh

A volume mounted from your local `$HOME/.ssh` directory, allowing to reuse your local SSH keys within factotum.

## /root/.aws

A volume mounted from your local `$HOME/.aws` directory, allowing to reuse your AWS credentials and configurations within factotum.

## /root/.gitconfig (file)

A file mounted from your local `$HOME/.gitconfig` file, allowing to reuse your git configs within factotum.

## /local

A volume mounted from your local `$HOME` directory, useful for sharing files between factotum and your local machine.

# Upgrading to latest version

```bash
$ factotum upgrade
```

You must then stop currently running containers (see below) and restart them in order to take advantage of latest version.

# Stopping container

To stop all containers linked to a given context, type:

```bash
$ factotum stop CONTEXT
```

# Injecting files

You might want some of the files that you create and customize within the image to persist, even when you do a fresh startup, upgrade or reinstall
factotum. Unless those files are locally in the special mounted directories, they are usually discarded in such cases. However, factotum provides
a mechanism called injection allowing to save those precious internal files outside of the container and have them automatically copied back to
their respective locations at every fresh startup.

Every time you start a fresh container, factotum automatically copies whatever files you placed in your local machine's `$HOME/.factotum/inject` directory into the container's locations matching the directory hierarchy within the `inject` directory.

## Exporting files for injection

The easiest way to setup injection when you already have a file or directory in your container that you want to persist via injection is to use the `copy-to-inject` script:

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
- git
- golang - go build tools
- gcc - c build tools
- gcloud cli
- helm 3
- hub - github cli
- ip - ([iproute2](https://en.wikipedia.org/wiki/Iproute2))
- jq - json query tool
- [k9s](https://github.com/derailed/k9s) - terminal UI to manage Kubernetes clusters
- kubectl
- ksd - k8s secret decoder
- manpages
- node
- [oh-my-zsh](https://ohmyz.sh/) - plugin/theme manager for zsh
- ping
- terraform cli
- [tldr](https://tldr.sh/) - unix command quick reference
- unzip
- uuid-runtime
- vim
- wget
- yq - yaml query tool (version by Mike Farah)
- yq2 - yaml query tool (python version, wrapper around jq)
- [zsh](https://www.zsh.org) - an alternative to bash

## hub

CLI for GitHub project management.

For example, to delete a GitHub project **without confirmation**, use:

```bash
$ hub delete -y ORGANIZATION/REPO
```

# Auto-completion

Tab auto-completion is available for the following CLIs:

- gcloud
- git
- hub
- kubectl
- terraform

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
