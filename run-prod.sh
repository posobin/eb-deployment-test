#!/bin/sh

echo "Running run-prod.sh"
ls -lah .
source virtualenv/bin/activate
python -c 'print("hello, world!")'
java -jar eb-deployment-test.jar
