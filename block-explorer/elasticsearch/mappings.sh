#!/bin/bash

URL=$1

curl -XPUT "$URL/snapshots" -H 'Content-Type: application/json' -d '@./mappings/snapshots.json'
curl -XPUT "$URL/blocks" -H 'Content-Type: application/json' -d '@./mappings/blocks.json'
curl -XPUT "$URL/transactions" -H 'Content-Type: application/json' -d '@./mappings/transactions.json'
curl -XPUT "$URL/balances" -H 'Content-Type: application/json' -d '@./mappings/balances.json'

curl -XGET "$URL/_cat/indices"
