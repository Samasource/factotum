#! /bin/bash

REGISTRY_ID=000000000000
REPO_NAME=factotum
export REGION=us-east-1
export DOCKER_IMAGE=$REGISTRY_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME

# This queries ECR for the latest version of the factotum image
export DOCKER_TAG=$(aws ecr list-images --repository-name $REPO_NAME --registry-id $REGISTRY_ID --region $REGION --filter tagStatus=TAGGED \
  | grep "imageTag" \
  | tr ',' '\n' \
  | cut -d \" -f 4 \
  | sort -n -r \
  | head -1)

docker run --rm -e DOCKER_IMAGE -e DOCKER_TAG $DOCKER_IMAGE:$DOCKER_TAG -c "gomplate -f /templates/install.gotmpl" | bash -s
