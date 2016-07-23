#!/bin/sh
export USER2=U2147481234

curl -v "http://127.0.0.1:8090/api/v1/signup/auth?id=$USER2"