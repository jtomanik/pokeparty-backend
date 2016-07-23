#!/bin/sh
source ./pp-create.sh

curl -v "http://127.0.0.1:8090/api/v1/party/join?hash=$PARTYNAME:$USER1&user=$USER2"
curl -v "http://127.0.0.1:8090/api/v1/event/join?hash=$EVENTNAME:$USER1&user=$USER2"