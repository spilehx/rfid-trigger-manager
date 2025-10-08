#!/usr/bin/env bash

cd "$(dirname "$0")"
# hl RFIDTriggerServer.hl

hl RFIDTriggerServer.hl > /dev/null 2>&1 &

