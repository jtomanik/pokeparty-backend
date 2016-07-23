#!/bin/sh
curl -i -H "Content-Type: application/json" -X POST -d '{"id":"U2147483697","username":"xyz"}' 'http://127.0.0.1:8090/api/v1/signup/setup'
