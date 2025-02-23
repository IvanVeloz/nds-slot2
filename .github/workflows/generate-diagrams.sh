#!/bin/bash

# run from the repo root

WDCLI=./docker-wavedrom-cli/docker-wavedrom-cli.sh
mkdir -p diagrams
$WDCLI -f png *.json
$WDCLI -f svg *.json
mv *.png diagrams
mv *.svg diagrams
ls diagrams

