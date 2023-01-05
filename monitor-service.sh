#!/bin/bash
#
# Description:
#      Runs a curl check every 3 seconds and adds the latency metrics to an influxdb.
#      Easy to connect with grafana.
#
#      + Assuming you have an influxdb running on localhost:8086
#      + Assuming you have created a database "mydb" with "CREATE DATABASE mydb;"
#
# Query the database like this:
# influx -database mydb
# SELECT * FROM "latency" ORDER BY time DESC LIMIT 10


_endpoint=${1}

while true; do
  OUT=`curl -w '@curl-format.txt' -o /dev/null --show-error --insecure -m 2 -s https://${_endpoint} -X POST -H "Content-Type: application/json" -H 'Connection: keep-alive' -H 'Keep-Alive: timeout=5, max=20'  --data '{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}' `

  # Call the influx API to add a datapoint
  curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary "latency,endpoint=${_endpoint},method=eth_blockNumber $OUT"

  sleep 3

done;

