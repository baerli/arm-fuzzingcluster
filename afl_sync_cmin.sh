#!/bin/bash
#
# american fuzzy lop - fuzzer synchronization tool
# ------------------------------------------------
#
# Written and maintained by Michal Zalewski <lcamtuf@google.com>
#
# Copyright 2014 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# To make this script work:
#
# - Edit FUZZ_HOSTS, FUZZ_DOMAIN, FUZZ_USER, and SYNC_DIR to reflect your
#   environment.
#
# - Make sure that the system you are running this on can log into FUZZ_HOSTS
#   without a password (authorized_keys or otherwise).
#
# - Make sure that every fuzzer is running with -o pointing to SYNC_DIR and -S
#   that consists of its local host name, followed by an underscore, and then
#   by some host-local fuzzer ID.
#

# Hosts to synchronize the data across.
FUZZ_HOSTS='pine64_0 pine64_1 pine64_2 pine64_3 pine64_4 pine64_5 pine64_6 pine64_7 pine64_8 pine64_9'

PROJECT_FOLDER="libyaml"

# Remote user for SSH
FUZZ_USER=fuzzing

# Directory to synchronize
SYNC_DIR="/fuzzing/$PROJECT_FOLDER/output"

# Interval (seconds) between sync attempts
SYNC_INTERVAL=$((30 * 60))

if [ "$AFL_ALLOW_TMP" = "" ]; then

  if [ "$PWD" = "/tmp" -o "$PWD" = "/var/tmp" ]; then
    echo "[-] Error: do not use shared /tmp or /var/tmp directories with this script." 1>&2
    exit 1
  fi

fi

rm -rf .sync_tmp 2>/dev/null
mkdir .sync_tmp || exit 1

while :; do

  # Pull data from every node and every fuzzing instance (4 in my case per node)


  for host in $FUZZ_HOSTS; do
    echo "[*] Retrieving data from ${host}..."
    for i in $(seq 0 3) ; do
      ssh -o 'passwordauthentication no' ${FUZZ_USER}@${host} \
        "cd '$SYNC_DIR' && tar -czf - ${host}_$i/queue/" >".sync_tmp/${host}_$i.tgz"
    done
  done

  #get master, nameingscheme is fucked up...
  echo "[*] Retrieving data from master..."
  ssh -o 'passwordauthentication no' ${FUZZ_USER}@pine64_0 \
      "cd '$SYNC_DIR' && tar -czf - pine64_0_0/queue/" > ".sync_tmp/pine64_0_0.tgz"


  # Distribute data. Keep a chain, so that only left and right instances get copied to target
  # effectifily reducing the analysis time of corpus an every single fuzzing instance
  # that way, sooner or later, the entire corpus is being broadcasted 

  for dst_host in $FUZZ_HOSTS; do

    echo "[*] Distribution process to ${dst_host} started..."

    # first lets minimise the corpus with afl-cmin
    cd .sync_tmp
    for i in $(seq 0 3) ; do
      echo "[*] Minimizing fuzzing corpus from ${dst_host}_$i..."
      
      # Create folders for cmin'ed corpus
      mkdir ${dst_host}_${i}_cmin && mkdir ${dst_host}_${i}_cmin/queue
      # Unpack queues, create new dirname before, since fuckup in naming
      mkdir ${dst_host}_${i}
      tar -xzf ${dst_host}_${i}.tgz -C ${dst_host}_${i} --strip-components 1
      # And Cmin the queue folder which contains the corpus
      afl-cmin -i ${dst_host}_${i}/queue -o ${dst_host}_${i}_cmin/queue -- /fuzzing/$PROJECT_FOLDER/tests/run-parser @@
      
      # Create a new tar ball of cmin'ed corpus, overwrite the old one
      tar -czf ${dst_host}_${i}.tgz ${dst_host}_${i}_cmin/queue

      # get left and right instance and copy queue over there
      left=${dst_host:7:8}
      let left=left-1
      # Check if not smaller then zero
      if [[ left -ge 0 ]]; then
        # Lets send corpus to left...
        lefthost="pine64_${left}"
        echo "Sending fuzzer data to left instance ${lefthost}..."
        
        ssh -o 'passwordauthentication no' ${FUZZ_USER}@$lefthost \
          "cd '$SYNC_DIR' && tar -xkzf -" <"${dst_host}_${i}.tgz"
      fi

      # Do the same thing for the right side
      right=${dst_host:7:8}
      let right=right+1
      # Check if not bigger then nine
      if [[ right -le 9 ]]; then
        # Lets send corpus to right...
        righthost="pine64_${right}"
        echo "Sending fuzzer data to right instance ${righthost}..."
        
        ssh -o 'passwordauthentication no' ${FUZZ_USER}@$righthost \
          "cd '$SYNC_DIR' && tar -xkzf -" <"${dst_host}_${i}.tgz"
      fi
    done

  done
  cd ..
  echo "[+] Done. Sleeping for $SYNC_INTERVAL seconds (Ctrl-C to quit)."

  sleep $SYNC_INTERVAL

done