#!/usr/bin/env bash

# Check requirements
hash qrencode 2> /dev/null || {
  echo >&2 "Aborting: qrencode not installed"
  exit 1
}

# Check argument
if [ $# -ne 2 ]; then
  echo "Usage: $0 <input> <output>"
  exit 1
fi

input=$1
output=$2

if [ ! -f ${input} ]; then
  echo "Error: ${input} not found"
  exit 1
fi

# Settings
gif_delay=100
qrcode_size=1732
qrcode_version=30

# Split the file
rm -f ${input}.split*
split -b ${qrcode_size} ${input} ${input}.split

# Generate png
for f in ${input}.split*; do
  qrencode -v ${qrcode_version} -o $f.png < $f
  rm $f
done

if hash zbarimg 2> /dev/null; then
  # Check png
  > ${input}.scanned
  for f in ${input}.split*; do
    printf %s "$(zbarimg --raw -q $f)" >> ${input}.scanned
  done
  printf %s "$(cat ${input})" | diff ${input}.scanned -
  rm ${input}.scanned
else
  echo "Skip testing: zbarimg not installed"
fi

# Convert to gif
convert -delay ${gif_delay} ${input}.split* ${output}
echo "Generated: ${output}"

# Clean up png
rm ${input}.split*
