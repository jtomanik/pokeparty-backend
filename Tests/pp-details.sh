#!/bin/sh
source ./pp-create.sh

curl -v "http://127.0.0.1:8090/api/v1/party/details?id=$PARTYNAME:$USER1"
curl -v "http://127.0.0.1:8090/api/v1/event/details?id=$EVENTNAME:$USER1"