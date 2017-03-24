#!/bin/bash


function clean_pre {

  # Fail on errors
  set -e
  dockerd-entrypoint.sh --storage-driver=aufs 2>/dev/null & 
  	while [ ! -S /var/run/docker.sock ]; do sleep 1; done
  for id in `docker ps -a -q`; do docker rm -f $id; done
  for id in `docker images -f "dangling=true" | tail -n +2 | awk "{print \\$3}"`; do docker rmi -f $id; done

}

function clean_post {
	for id in `docker ps -a -q`; do docker rm -f $id; done
	for id in `docker images -f "dangling=true" | tail -n +2 | awk "{print \\$3}"`; do docker rmi -f $id; done
	adduser -u $UID -D hive
	chown -R hive /var/lib/docker
	chown -R hive workspace
}

function testclient {
  client=$1
  WWWROOT=/hive-www
  NOW=$(date +"%Y%m%d_%H%M%S")
  LOG_OUT="./tmp/$NOW-$client/output.log"
  JSN_OUT="./tmp/$NOW-$client.json"
  LISTING="listing.json"
  HERE=`pwd`
  
  mkdir -p ./tmp/$NOW-$client
  ls -la ./tmp/

  echo "Starting hive, check progress at $LOG_OUT"
  
  clean_pre

#  ./hive --docker-noshell -sim ethereum/consensus -test none -client $client 2> $LOGDIR/output.log | \
  echo "Sleeping for 300 seconds"
  sleep 300
  echo "Testing https://index.docker.io/v1/repositories/library/alpine/images"
  curl https://index.docker.io/v1/repositories/library/alpine/images
  echo "Testing http://www.swende.se/xss.html"
  curl http://www.swende.se/xss.html

  hive --docker-noshell -sim ethereum/consensus -test none -client $client 2> $LOG_OUT | \
    grep -v -e "^[\.]+$"        | \
    grep -v -e "^[a-f0-9]{12}$" | \
    grep -v "^Deleted: sha256:" > $JSN_OUT
    
  clean_post

  mkdir -p $WWWROOT/artefacts/$NOW-$client
  echo "Hive done, copying logs..."       && \

  cp $LOG_OUT $WWWROOT/artefacts/$NOW-$client/output.log
  cp $JSN_OUT $WWWROOT/artefacts/$NOW-$client.json

  # Copy the client logs
  cp workspace/logs/simulations/ethereum\:consensus\[$client\]/* $WWWROOT/artefacts/$NOW-$client/ && \
  echo "Updating file listing" && \
  # Update the listing
  cd $WWWROOT
  echo "Currently at `pwd`"
  echo "Calling python $HERE/create_listing.py artefacts/$NOW-$client.json $LISTING"
  python $HERE/create_listing.py $WWWROOT/artefacts/$NOW-$client.json $LISTING
  cd $HERE
}


testclient $CLIENT



