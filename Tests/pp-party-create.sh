#!/bin/sh
sh ./pp-signup-step1.sh
sh ./pp-signup-step2.sh
sh ./pp-signup-user2-step1.sh
sh ./pp-signup-user2-step2.sh

curl -i 'http://127.0.0.1:8090/api/v1/party/create?name=dupa&owner=U2147483697'