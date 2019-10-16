#!/bin/bash

 docker build . -t packer-build \
    && docker run -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
    -v ~/.aws/credentials:/root/.aws/credentials \
    -e AWS_PROFILE=$AWS_PROFILE -e INPUT_VALIDATE_ONLY=$INPUT_VALIDATE_ONLY \
    -e INPUT_TEMPLATE=ubuntu -e INPUT_WORKING_DIR=test \
    -v $(pwd)/test:/work/test  packer-build