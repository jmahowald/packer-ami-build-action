#!/bin/bash
declare var_file=$1
declare var_name=$2
declare image_id=$3


tmp=$(mktemp)
jq ".$var_name =\"$image_id\"" $var_file \
> $tmp && mv $tmp $var_file
