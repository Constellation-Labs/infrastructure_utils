#!/bin/bash

curl -XPUT "$URL/snapshots" -H 'Content-Type: application/json' -d'
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
      "height": {
        "type": "long"
      },
      "checkpointBlocks": {
        "type": "keyword"
      }
    }
  }
}'

curl -XPUT "$URL/checkpoint-blocks" -H 'Content-Type: application/json' -d'
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

curl -XPUT "$URL/transactions" -H 'Content-Type: application/json' -d'
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
      },
      "transactionOriginal": {
        "properties": {
          "edge": {
            "properties": {
              "observationEdge": {
                "properties": {
                  "parents": {
                    "type": "nested",
                    "properties": {
                      "hash": {
                        "type": "keyword"
                      },
                      "hashType": {
                        "type": "keyword"
                      }
                    }
                  },
                  "data": {
                    "properties": {
                      "hash": {
                        "type": "keyword"
                      },
                      "hashType": {
                        "type": "keyword"
                      }
                    }
                  }
                }
              },
              "signedObservationEdge": {
                "properties": {
                  "signatureBatch": {
                    "properties": {
                      "hash": {
                        "type": "keyword"
                      },
                      "signatures": {
                        "type": "nested",
                        "properties": {
                          "signature": {
                            "type": "keyword"
                          },
                          "id": {
                            "properties": {
                              "hex": {
                                "type": "keyword"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "data": {
                "properties": {
                  "amount": {
                    "type": "long"
                  },
                  "lastTxRef": {
                    "properties": {
                      "hash": {
                        "type": "keyword"
                      },
                      "ordinal": {
                        "type": "long"
                      }
                    }
                  },
                  "salt": {
                    "type": "long"
                  }
                }
              }
            }
          },
          "lastTxRef": {
            "properties": {
              "hash": {
                "type": "keyword"
              },
              "ordinal": {
                "type": "long"
              }
            }
          },
          "isDummy": {
            "type": "boolean"
          },
          "isTest": {
            "type": "boolean"
          }
        }
      }
    }
  }
}'

curl -XGET "$URL/_cat/indices"
