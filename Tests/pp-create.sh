#!/bin/sh
source ./pp-signup-step1.sh
source ./pp-signup-step2.sh
source ./pp-signup-user2-step1.sh
source ./pp-signup-user2-step2.sh

export PARTYNAME=dupaparty
export EVENTNAME=dupaevent

curl -v "http://127.0.0.1:8090/api/v1/party/create?name=$PARTYNAME&owner=$USER1"
curl -v "http://127.0.0.1:8090/api/v1/event/create?name=$EVENTNAME&owner=$USER1"