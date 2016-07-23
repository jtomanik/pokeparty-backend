#!/bin/sh
PAYLOAD='{"id":"U2147483697","username":"xyz"}'

curl -v -H "Content-Type: application/json" -X POST -d $PAYLOAD 'http://127.0.0.1:8090/api/v1/signup/setup'
