#!/bin/bash

echo "Check to see if jwt is up and running"

greymatter list route | grep jwt

curl loalhost:8001/clusters

curl localhost:8001/listeners