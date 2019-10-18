#!/bin/bash -ex

env
pushd $INPUT_WORKING_DIR


ADDITIONAL_INFO_FILE=${INPUT_ADDITIONAL_INFO_FILE:-/build-info.tpl.json}
TEMPLATE_FILE=${INPUT_TEMPLATE_FILE:-$INPUT_TEMPLATE.json}
dockerize -template $ADDITIONAL_INFO_FILE:/build-info.json
cat /build-info.json

# Yeah it's chintzy.  
# But we need to a json merge of two sections.  I honestly
# can't explain why this merges in both the builders and post-processors
# section, but it seems to work so ¯\_(ツ)_/¯ 



jq --argfile f1 $TEMPLATE_FILE  \
   --argfile f2 /build-info.json \
   -n '$f1 * ($f1."builders"[]? * $f2."builders"[]? | { "builders": [.] } )' \
   > packer-build-0.json

jq -s '.[0] * .[1]' /build-info.json packer-build-0.json > packer-build-1.json

echo "using merged file:"
cat packer-build-1.json


if [ "$INPUT_VALIDATE_ONLY" == "true" ]; then
    packer validate packer-build-1.json
else
    if [ ! -z "$INPUT_VAR_FILE" ] && [ -f $INPUT_VAR_FILE ]; then
        PACKER_ARGS="$PACKER_ARGS -var-file $INPUT_VAR_FILE"
    fi
    packer build $PACKER_ARGS packer-build-1.json
    echo "manifest:"
    cat $INPUT_TEMPLATE-manifest.json
    # Extract the ami from the manifest.  manifest looks like

    image_id=$(cat $INPUT_TEMPLATE-manifest.json \
     | jq -r '.builds[0].artifact_id' \
     | cut -d ":" -f 2)
    
    # Need a newline from the previous output for some reason
    echo ""
    echo ::set-output name=image_id::$image_id

    if [ -n "$INPUT_IMAGE_ID_FILE" ]; then
        echo "Updating $INPUT_IMAGE_ID_FILE with image id"
        /update-image-id.sh $INPUT_IMAGE_ID_FILE $INPUT_IMAGE_ID_VARIABLE_NAME $image_id
    fi
fi