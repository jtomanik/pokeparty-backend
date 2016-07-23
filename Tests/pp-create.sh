#!/bin/sh
source ./pp-signup.sh

export PARTYNAME=dupaparty
export EVENTNAME=dupaevent

curl -v "http://127.0.0.1:8090/api/v1/party/create?name=$PARTYNAME&owner=$USER1"
curl -v "http://127.0.0.1:8090/api/v1/event/create?name=$EVENTNAME&owner=$USER1&latitude=1.0&longitude=1.0&description=dupa"