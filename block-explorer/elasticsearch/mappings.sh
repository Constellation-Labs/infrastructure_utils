#!/bin/bash

curl -XPUT "$URL/snapshots" -H 'Content-Type: application/json' -d '@./mappings/snapshot.json'

curl -XGET "$URL/_cat/indices"
