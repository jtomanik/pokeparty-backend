#!/bin/sh
PAYLOAD='{"id":"U2147481234","username":"dupauser"}'

curl -v -H "Content-Type: application/json" -X POST -d $PAYLOAD 'http://127.0.0.1:8090/api/v1/signup/setup'
