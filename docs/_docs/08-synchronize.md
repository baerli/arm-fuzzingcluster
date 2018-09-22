---
title: "Synchronizing and corpus minimization"
permalink: /docs/synchronize/
excerpt: "Details Synchronizing and corpus minimization."
toc: true
---

In the following chapter, we discuss a way how to synchronize our fuzzing nodes so that the fuzzing corpus of one node is being distributed throughout the entire cluster.

## Synching queues

Syncing AFLs fuzzing states can be easy, since it is designed to be operated on multiple devices. One way is using a simple SSH script that fetches the ```queue``` folder inside of every single instance on every node and propagate that on every other node. An exemplaric script is being shipped with AFL. AFL detects new fuzzing instances queues when copied into the ```output``` directory and will add those queues into its own process.
Check out AFL sync script inside of the experimental directory and read AFLs manual concerning [parallel fuzzing](https://github.com/mirrorer/afl/blob/master/docs/parallel_fuzzing.txt).

## Synching it a bit more effective

When copying the entirety of all fuzzing instances queues to every other fuzzing instance at more or less the same time, it might lead to some computational overhead when every single AFL instance incorporates every single queue of every other instance into its own fuzzing process. Since we have time and don't have to have a totally synchronized state all the time, it is easily possible to use some sort of slow distribution of queues throughout the fuzzing cluster. I adjusted AFLs example SSH script to synchronize states from every node only to its left and right side - meaning that node number 4 only syncs its state to number 3 and 5. By using this way of chain synchronization, fuzzing states of lower number are being propagated to higher numbers some times later, but it is going to be there at some point. while giving each fuzzing process more time to incorporate the new queues. You can find this script inside of my repository (https://github.com/baerli/arm-fuzzingcluster/afl_sync_cmin.sh)

What I am doing as well is minimizing the corpus of every single instance before synchronizing it to the other nodes. I am not quite sure if it makes too much sense to do this during every single synchronization step. I have seen people doing this after a few days of fuzzing, using ```afl-cmin``` on every queue folder as well as afl-tmin on every single input file. I am not using afl-tmin right now, but I guess I will add this to my script and perform this every 48 to 96 hours.
In case you are terminating or pausing your fuzzing job at some point, that might be a good time to minimize your entire fuzzing corpus. 