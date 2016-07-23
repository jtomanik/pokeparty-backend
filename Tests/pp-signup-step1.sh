#!/bin/sh
export USER1=U2147483697

curl -v "http://127.0.0.1:8090/api/v1/signup/auth?id=$USER1"