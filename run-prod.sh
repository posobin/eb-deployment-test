#!/bin/sh

set -e

echo "Running run-prod.sh"
ls -lah .
python3.7 -c 'print("hello, world!")'
java -jar eb-deployment-test.jar
