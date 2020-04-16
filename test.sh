#!/bin/bash

#
# This is a little test-script, that can be used for a some trial runs of clients. 
#


HIVEHOME="./"

# Store results in temp
RESULTS="/tmp/TestResults"

#FLAGS="--docker-noshell --docker-nocache ."
FLAGS="--docker-noshell"

function testconsensus {
  client=$1
  cd $HIVEHOME;

  echo "$(date) Starting hive consensus simulation [$client], check progress at output.log"

  hive --sim ethereum/consensus \
  --loglevel 6 \
  --client $client \
  --results-root $RESULTS \
  --sim-parallelism 1 --sim-rootcontext --simloglevel 6 \
  $FLAGS

}

function testsync {
  client1=$1
  client2=$2
  cd $HIVEHOME;

  echo "$(date) Starting hive sync simulation [$client<->$client2], check progress at output.log"

  hive --sim ethereum/sync \
  --loglevel 6 \
  --client "$client1,$client2" \
  --results-root $RESULTS \
  --sim-parallelism 1 --simloglevel 6 --sim-rootcontext \
  $FLAGS

}

function testdevp2p {
  client=$1
  cd $HIVEHOME;

  echo "$(date) Starting p2p simulation [$client], check progress at output.log"

  hive --sim devp2p \
  --loglevel 6 \
  --client $client \
  --results-root $RESULTS \
  --sim-parallelism 1 --sim-rootcontext \
  $FLAGS
}


function testgraphql {
  client=$1
  cd $HIVEHOME;

  echo "$(date) Starting graphql simulation [$client], check progress at output.log"

  hive --sim ethereum/graphql \
  --loglevel 6 \
  --client $client \
  --results-root $RESULTS \
  --sim-parallelism 1 --sim-rootcontext --simloglevel 6\
  $FLAGS
}

mkdir $RESULTS

# Sync are quick tests
#
#testsync go-ethereum_latest parity_latest
#testsync go-ethereum_latest aleth_nightly
#testsync go-ethereum_latest nethermind_latest
#testsync go-ethereum_latest besu_latest

# GraphQL implemented only in besu and geth
#

#testgraphql go-ethereum_latest
#testgraphql besu_latest


# The devp2p tests are pretty quick -- a few minutes
#testdevp2p go-ethereum_latest
#testdevp2p nethermind_latest
#testdevp2p besu_latest
testdevp2p parity_latest


# These take an extremely long time to run
#testconsensus aleth_nightly
#testconsensus go-ethereum_latest
#testconsensus parity_latest
#testconsensus nethermind_latest
#testconsensus besu_latest



