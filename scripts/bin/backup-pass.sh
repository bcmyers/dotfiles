#!/usr/bin/env bash

set -eux

now=$(date -u +"%Y%m%d%H%M%S%z")

filename="pass-${now}.tar.gz"

tar -cz --exclude=".git*" -f "$filename" --strip-components 3 "$HOME/.password-store"

aws --profile bcmyers s3 cp "$filename" "s3://bcmyers-pass/$filename"

echo "success"
