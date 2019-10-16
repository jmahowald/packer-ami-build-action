#!/bin/bash -e

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


jq --argfile f1 /build-info.json \
   --argfile f2 $TEMPLATE_FILE \
   -n '$f1 * ($f1."builders"[]? * $f2."builders"[]? | { "builders": [.] } )' \
   > packer-build.json

echo "using merged file:"
cat packer-build.json

if [ "$INPUT_VALIDATE_ONLY" == "true" ]; then
    packer validate packer-build.json
else
    packer build packer-build.json
    echo "manifest:"
    cat $INPUT_TEMPLATE-manifest.json
    # Extract the ami from the manifest.  manifest looks like

    image_id=$(cat $INPUT_TEMPLATE-manifest.json \
     | jq -r '.builds[0].artifact_id' \
     | cut -d ":" -f 2)
    
    
    echo ""
    echo ::set-output name=image_id::$image_id

fi