#!/usr/bin/env bash
sudo ./auto-image-builder.sh build \
  --target qemu \
  --export qcow2 \
  --distro f41 \
  --mode package \
  summit.aib.yml \
  minimal.qcow2
