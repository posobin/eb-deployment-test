#!/bin/sh

ls -lah .
source virtualenv/bin/activate
java -jar eb-deployment-test.jar
