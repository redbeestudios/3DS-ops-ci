#!/usr/bin/env bash
set -exvo pipefail

./gradlew --no-daemon jacocoTestReport sonarqube \
  -Dsonar.host.url=http:localhost:9000 \
  -Dsonar.login=$1\
  -Dsonar.password=$2
