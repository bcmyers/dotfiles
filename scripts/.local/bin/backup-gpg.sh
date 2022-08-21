#!/usr/bin/env bash

set -eux

key0=A65C0C4DE57884B8
keyE=82081CF07E9C1664
keyS=B86678B99457460F
keyA=9CB4683AD4C5EC7B

mkdir -p /tmp/gpg

gpg --export-secret-key -a $key0 > /tmp/gpg/key0.gpg
gpg --export-secret-key -a $keyE > /tmp/gpg/keyE.gpg
gpg --export-secret-key -a $keyS > /tmp/gpg/keyS.gpg
gpg --export-secret-key -a $keyA > /tmp/gpg/keyA.gpg

now=$(date -u +"%Y%m%d%H%M%S%z")
filename="gpg-${now}.tar.gz"
local_path="/tmp/$filename"

(
  cd /tmp
  tar -czv -f "$local_path" gpg
)

aws --profile bcmyers s3 cp "$local_path" "s3://bcmyers-encrypted/gpg/$filename"

rm -r /tmp/gpg
rm "$local_path"
