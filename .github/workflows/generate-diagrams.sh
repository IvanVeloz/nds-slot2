#!/bin/bash

# run from the repo root

WDCLI=./docker-wavedrom-cli/docker-wavedrom-cli.sh
mkdir -p diagrams
$WDCLI -f png src/*.json
$WDCLI -f svg src/*.json
mv src/*.png diagrams
mv src/*.svg diagrams
echo "Diagrams generated:"
ls diagrams

CURRENT_USER=$(whoami)
CURRENT_GROUP=$(id -g -n)
echo "Current user: $CURRENT_USER"
echo "Current group: $CURRENT_GROUP"

pushd diagrams
for f in *.png; do
  echo "Fixing ownership for $f"
  sudo chown $CURRENT_USER:$CURRENT_GROUP $f
done
for f in *.svg; do
  echo "Fixing ownership for $f"
  sudo chown $CURRENT_USER:$CURRENT_GROUP $f
done
popd

echo "Done"
