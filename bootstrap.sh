#! /bin/bash
# This script will be sourced (executed) locally from the user's
# machine in order to install factotum from scratch. It determines the
# latest factotum image in container repo and uses it to render and run
# the install script. In other words, factotum is used to install itself!
# See README.md for details, specifically section "How factotum
# bootstrapping, installation and launching works"

# Currently supported values for REGISTRY are "dockerhub" and "ecr"
REGISTRY=dockerhub

# Customize for your own repo
REPO_OWNER=samasource
REPO_NAME=factotum
  
# ECR-specific variables
ECR_REGISTRY_ID=000000000000
ECR_REGION=us-east-1

# Query container registry for latest version of factotum image
if [[ $REGISTRY == 'dockerhub' ]]; then
  export DOCKER_IMAGE=$REPO_OWNER/$REPO_NAME
  export DOCKER_TAG=$(curl -sfL https://registry.hub.docker.com/v1/repositories/$REPO_OWNER/$REPO_NAME/tags \
    | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' \
    | tr '}' '\n' \
    | awk -F: '{print $3}' \
    | sort -n -r \
    | head -1)
elif [[ $REGISTRY == 'ecr' ]]; then
  export DOCKER_IMAGE=$ECR_REGISTRY_ID.dkr.ecr.$ECR_REGION.amazonaws.com/$REPO_NAME
  export DOCKER_TAG=$(aws ecr list-images --repository-name $REPO_NAME --registry-id $ECR_REGISTRY_ID --region $ECR_REGION --filter tagStatus=TAGGED \
    | grep "imageTag" \
    | tr ',' '\n' \
    | cut -d \" -f 4 \
    | sort -n -r \
    | head -1)
else
  echo "Unsupported registry: $REGISTRY"
  exit 1
fi

echo "DOCKER_IMAGE=$DOCKER_IMAGE"
echo "DOCKER_TAG=$DOCKER_TAG"
docker run --rm -e DOCKER_IMAGE -e DOCKER_TAG $DOCKER_IMAGE:$DOCKER_TAG -c "gomplate -f /templates/install/install.gotmpl" | bash -s
