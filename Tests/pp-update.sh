#!/bin/sh
source ./pp-create.sh

PAYLOAD='{"id":"U2147481234","username":"dupauser"}'
PAYLOAD='{"id":"U2147481234","username":"dupauser"}'

curl -v "http://127.0.0.1:8090/api/v1/party/update?id=$PARTYNAME:$USER1"
curl -v "http://127.0.0.1:8090/api/v1/event/update?id=$EVENTNAME:$USER1"