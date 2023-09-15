#!/bin/bash

# PIPELINE
echo "Cleaning pipeline state files"
find ./pipeline/ -type f -name 'state_*.yaml' -delete
