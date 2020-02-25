#!/bin/bash

curl -XPUT "http://vpc-cl-block-explorer-test-mkp3xvroe7nba2mmddwr3xmyn4.us-west-1.es.amazonaws.com:80/snapshots" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "dynamic": false,
    "_source": {
      "enabled": true
    },
    "properties": {
      "hash": {
        "type": "keyword"
      },
      "checkpointBlocks": {
        "type": "keyword"
      }
    }
  }
}'

curl -XPUT "http://vpc-cl-block-explorer-test-mkp3xvroe7nba2mmddwr3xmyn4.us-west-1.es.amazonaws.com:80/checkpoint-blocks" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "dynamic": false,
    "_source": {
      "enabled": true
    },
    "properties": {
      "hash": {
        "type": "keyword"
      },
      "messages": {
        "type": "keyword"
      },
      "notifications": {
        "type": "keyword"
      },
      "observations": {
        "type": "keyword"
      },
      "children": {
        "type": "long"
      },
      "height": {
        "dynamic": false,
        "properties": {
          "min": {
            "type": "long"
          },
          "max": {
            "type": "long"
          }
        }
      },
      "snapshotHash": {
        "type": "keyword"
      }
    }
  }
}'

curl -XPUT "http://vpc-cl-block-explorer-test-mkp3xvroe7nba2mmddwr3xmyn4.us-west-1.es.amazonaws.com:80/transactions" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "dynamic": false,
    "_source": {
      "enabled": true
    },
    "properties": {
      "hash": {
        "type": "keyword"
      },
      "amount": {
        "type": "long"
      },
      "receiver": {
        "type": "keyword"
      },
      "sender": {
        "type": "keyword"
      },
      "lastTransactionRef": {
        "properties": {
          "hash": {
            "type": "keyword"
          },
          "ordinal": {
            "type": "long"
          }
        }
      },
      "snapshotHash": {
        "type": "keyword"
      },
      "checkpointBlockHash": {
        "type": "keyword"
      }
    }
  }
}'

curl -XGET "http://vpc-cl-block-explorer-test-mkp3xvroe7nba2mmddwr3xmyn4.us-west-1.es.amazonaws.com:80/_cat/indices"
