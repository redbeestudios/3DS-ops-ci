#!/usr/bin/env bash
set -exvo pipefail
#mycommand="./gradlew --no-daemon test && ./gradlew --no-daemon build"
#bash -c "${mycommand}"
./gradlew --no-daemon test && ./gradlew --no-daemon build
