#!/bin/bash

error() {
  echo "ERROR: $1"
}

[ $(quakestat -nh -u -qws localhost:28501 | wc -l) -eq 0 ] && error "Server no longer active, please restart this container"

exit 0
