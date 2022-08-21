#!/usr/bin/env bash

set -eux

now=$(date -u +"%Y%m%d%H%M%S%z")

filename="pass-${now}.tar.gz"
local_path="/tmp/$filename"

(
  cd "$HOME"
  tar -cz --exclude=".git*" -f "$local_path" .password-store
)

aws --profile bcmyers s3 cp "$local_path" "s3://bcmyers/pass/$filename"

rm "$local_path"

echo "success"
