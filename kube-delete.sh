#!/bin/bash

(set -x;

kubectl delete svc myappsql-svc
kubectl delete rc myappsql-rc
)
