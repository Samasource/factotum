FROM ubuntu:bionic
SHELL ["/bin/bash", "-c"]

# make /bin/sh point to bash (instead of the default dash)
RUN ln -sf bash /bin/sh

# shell tools
RUN apt-get update && \
    apt-get upgrade -y
RUN apt-get install -y wget
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get install -y unzip
RUN apt-get install -y man-db
RUN apt-get install -y manpages
RUN apt-get install -y manpages-posix
RUN apt-get install -y groff
RUN apt-get install -y gcc
RUN apt-get install -y vim
RUN apt-get install -y uuid-runtime
RUN apt-get install -y iproute2
RUN apt-get install -y iputils-ping
RUN apt-get install -y dnsutils
RUN apt-get install -y gettext
RUN apt-get install -y bsdmainutils
RUN apt-get install -y netcat

# zsh + oh-my-zsh
RUN apt-get install -y zsh && \
    apt-get install -y powerline fonts-powerline && \
    sh -c $(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh) && \
    git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
    git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh-syntax-highlighting" --depth 1

# UTF-8 locale
RUN apt-get install -y locales && \
    locale-gen "en_US.UTF-8"

# golang
ARG GO_VERSION=1.14.3
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
ENV GO111MODULE=on
RUN curl -fsL https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz \
    | tar xzv -C /usr/local && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
    chmod -R 777 "$GOPATH"

# node
ARG NODE_VERSION=12
RUN curl -fsL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - && \
    apt-get install -y nodejs

# python
RUN apt-get install -y python-pip python3-pip python3-distutils

# gcloud
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get install -y apt-transport-https ca-certificates && \
    curl -fsL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk

# kubectl
RUN curl -fsLO https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl

# helm 3
ARG HELM_VERSION=3.2.4
RUN curl -fsL https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz \
    | tar xzv -C /usr/local/bin --strip=1 linux-amd64/helm

# helm-diff plugin
RUN helm plugin install https://github.com/databus23/helm-diff --version master

# helmfile
ARG HELMFILE_VERSION=0.123.0
RUN curl -fsL --output /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v$HELMFILE_VERSION/helmfile_linux_amd64 && \
    chmod +x /usr/local/bin/helmfile

# k9s
ARG K9S_VERSION=0.20.2
RUN curl -fsL https://github.com/derailed/k9s/releases/download/v$K9S_VERSION/k9s_Linux_x86_64.tar.gz \
    | tar xzv -C /usr/local/bin k9s

# jq
RUN apt-get install -y jq

# python-yq (install as yq2, side-by-side with yq by Mike Farah)
RUN pip install yq && \
    mv /usr/local/bin/yq{,2}

# yq (by Mike Farah)
RUN curl -fsL --output /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/3.3.0/yq_linux_amd64 && \
    chmod +x /usr/local/bin/yq

# ksd (kubernetes secret decoder)
RUN go get github.com/mfuentesg/ksd

# terraform
ARG TERRAFORM_VERSION=0.12.26
RUN TMP=$(mktemp) && \
    curl -fsL --output $TMP https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip -p $TMP terraform > /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform && \
    rm $TMP && \
    terraform -install-autocomplete

# istio
ARG ISTIO_VERSION=1.6.0
ENV ISTIO_HOME="/root/.istio"
ENV PATH $ISTIO_HOME/bin:$PATH
RUN curl -fsL https://git.io/getLatestIstio | sh - && \
    mv "istio-$ISTIO_VERSION" $ISTIO_HOME

# hub
RUN HUB_NAME="hub-linux-amd64-2.12.8" && \
    HUB_TAR="$HUB_NAME.tgz" && \
    HUB_TEMP="/tmp/hub" && \
    HUB_COMP_DIR=~/.zsh/completions && \
    wget -P /tmp https://github.com/github/hub/releases/download/v2.12.8/$HUB_TAR && \
    mkdir $HUB_TEMP && \
    tar -zxvf /tmp/$HUB_TAR -C $HUB_TEMP && \
    mv $HUB_TEMP/$HUB_NAME/bin/hub /usr/local/bin/hub && \
    mkdir -p $HUB_COMP_DIR && \
    mv $HUB_TEMP/$HUB_NAME/etc/hub.zsh_completion $HUB_COMP_DIR/_hub && \
    chown -R root:root $HUB_COMP_DIR/_hub && \
    rm /tmp/$HUB_TAR && \
    rm -rf $HUB_TEMP

# kail
RUN bash <( curl -sfL https://raw.githubusercontent.com/boz/kail/master/godownloader.sh) -b "$GOPATH/bin"

# eksctl
RUN curl -fsL "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin

# gomplate
ARG GOMPLATE_VERSION=3.7.0
RUN curl -fsL --output /usr/local/bin/gomplate -sSL https://github.com/hairyhenderson/gomplate/releases/download/v$GOMPLATE_VERSION/gomplate_linux-amd64 && \
    chmod +x /usr/local/bin/gomplate

# codefresh
ARG CODEFRESH_VERSION=0.64.6
RUN curl -fsL https://github.com/codefresh-io/cli/releases/download/v$CODEFRESH_VERSION/codefresh-v$CODEFRESH_VERSION-linux-x64.tar.gz \
    | tar xzv -C /usr/local/bin ./codefresh

# postgresql-client
RUN apt-get install -y postgresql-client

# gh (github client)
RUN APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 && \
    apt-get install -y software-properties-common && \
    apt-add-repository https://cli.github.com/packages && \
    apt-get update && \
    apt-get install gh

# tldr (alternative manpages for linux commands)
RUN npm install -g tldr

# aws-cli
ARG AWS_CLI_VERSION=2.0.52
RUN TMP=$(mktemp -d) && \
    cd $TMP && \
    curl -fsL -o "awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf $TMP

# figurine
RUN go get github.com/arsham/figurine

# finalize
COPY filesystem/ /
WORKDIR /local
ENTRYPOINT ["zsh"]