---
title: "Compile and Deploy"
permalink: /docs/compile-and-deploy/
excerpt: "Compile and deploy a simple fuzzing job."
toc: true
---

The following chapters describe how we can deploy a simple fuzzing job. We are using @lcamtufs [American Fuzzy Lop, short AFL](http://lcamtuf.coredump.cx/afl/). If highly advise you to go and check out the manuals and explanations which are being shipped with AFL. Even if I would go into greater detail about AFL, I could not explain it to you in a way that @lcamtuf did it. If you would ask me what to read first to get a good picture about the implementation as well as about the idea of behinden these fuzzing approaches, I would tell you to read @lcamtufs [ReadMe](http://lcamtuf.coredump.cx/afl/README.txt), [Technical Details](http://lcamtuf.coredump.cx/afl/technical_details.txt) as well as the [historical notes](http://lcamtuf.coredump.cx/afl/historical_notes.txt).

As an examplaric target, I am picking the markup language YAML and fuzz an open source implementations. I was using [libyaml](https://github.com/yaml/libyaml) as an initial target, a very widely used library, the library itself has been fuzzed quite often by different people as well as in [Googles OSS-Fuzz project](https://github.com/google/oss-fuzz). But, as an example, I consider it a good starting point.

## Compile

To use AFL to fuzz software, we have to use the modified compilers that are shipped with it. You can use afl-gcc, afl-clang as well as afl-clang-fast. During compilation, instrumenations are being injected into the binary which makes it possible for AFl to track code coverage and decide which input it generates will actually be kept and considered interesting. Once again, read @lcamtufs detailed explanations if you want to know more about that. 
I am using ```afl-clang-fast``` to compile the target:
```bash
git clone https://github.com/yaml/libyaml
export AFL_HARDEN=1 CC=afl-clang-fast && export CXX=afl-g++ && ./configure --disable-shared && make clean && emake
```

## Input corpus and dictionary

When fuzzing a specific file format, it makes sense to use give AFL a set of input file that represents a correct file syntax. This should actually be thought through well, since a file input that is chosen to big needs significant more time in the fuzzing process, especially in mutation of the input. On the other side, a input that is chosen to small might take an unnecessary long time to create an actual valid input - even though AFl is capable of creating valid input that reaches significant code coverage.

I did pick some yaml input from various sources online. Testing frameworks for different file format are one example to get a set of valid input files. 

AFL ships with some tools that makes it easy for you to minimize your input corpus without checking every single file about how similar they are and therefore might cause performance overhead. ```afl-cmin``` takes a folder of input files and checks which input files reach different code paths and omit the ones that seem to be redundant. 

The following command lets afl-cmin know where your input corpus folder is, where the minimized input corpus will be outputted as well as where the target binary is.
```bash
afl-cmin -i input -o input_min -- build/util/parse @@
```

While we are still on minimizing input, AFL ships with a second tool that we should use before we start. ```afl-tmin``` is a simple test case minimizer, which is used to take a single input file and find out what kind of data of that file can be removed while still reaching the same state inside of the instrumented binary. Be default, you can only minimize one file at a time. Go and write yourself a script or check out [FoxGlove Securitys script](https://foxglovesecurity.com/2016/03/15/fuzzing-workflows-a-fuzz-job-from-start-to-finish/).

After minimizing my entire corpus as well as every single input file, I still have something around a 100 input files. AFL will tell you that this is considered too much. It is up to you if you want to go with the bigger input corpus or minimize it again, by selecting a manual subset of your input. 


## Optimizations

Before starting your fuzzing, apply the performance optimization settings AFL needs. 
```bash
#AFL Settings
echo core >/proc/sys/kernel/core_pattern

cd /sys/devices/system/cpu
echo performance | tee cpu*/cpufreq/scaling_governor
```

@floyd applied some more [optimization settings](https://github.com/floyd-fuh/afl-fuzzing-scripts/blob/master/1_installation/odroid-optimizations.sh) for his odroid boards which might apply to our Pine64 boards as well.

## Deploy and start your fuzzing job

On your master instance where you compiled your project, take a tarball of the project and copy it to every node:

```bash
tar czvf fuzzproject.tar.gz
```

After we compiled and instrumented our target project and copied our project to every node, its time start the actual fuzzing job. Our plan is to start one fuzzing job per core. Having 10 nodes with 4 cores on each, that makes a total of 40 cluster instances at least. If you studied AFls manual, you might have noticed that we should use one AFl master instance only, which is performing deterministic checks, while all other slave instances will perform random mutations. 
It is also possible to parallelize the deterministic checks of the master instance. AFLs manual describes it to use it that way:
```bash
$ ./afl-fuzz -i testcase_dir -o sync_dir -M masterA:1/3 [...]
$ ./afl-fuzz -i testcase_dir -o sync_dir -M masterB:2/3 [...]
$ ./afl-fuzz -i testcase_dir -o sync_dir -M masterC:3/3 [...]
```

It is up to you which way you want to go. When having 40 cores, I would go for splitting up the master instance into 4 instances. 
As an example, we just use one master instance only without parallization.
I am also putting every fuzzing instance inside of a screen session, so I can easily attach and detach from it whenever I feel like. Since we cannot use ASAN on our ARM boards since its not supported on Linux on ARM, we use @lcamtufs libdislocator that ships with AFL. Libdisclocator is a replacement for the libc allocator which helps you in finding heap related bugs. A lot of memory corruption issues on the heap might not crash your program and therefore go unseen during the fuzzing process. Go check out the manual that is included inside of the libdislocator folder.

```bash
mkdir output
screen -dmS master bash -c 'AFL_PRELOAD=/home/fuzzing/afl-2.52b/libdislocator/libdislocator.so afl-fuzz -M pine64_0_0 -x yaml_dict.txt -i- -o output ./tests/run-parser @@'
# Check out if our instance is running
screen -R master
# If it is running fine, detach from screen using ctrl+a+d

```

After our master instance is running without a problem, we start to spin up some more instances over the additional cpu cores (3 in my case). Check out how much CPU power you got left using ```afl-gotcpu```, which is also being shipped with AFL. It might be the case that you can acutally spin up more instances that you got CPU cores. 
We are also naming our instance uniquely, so we can address them later when synchronizing our fuzzing instances.

```bash
for i in {1..3} ; do screen -dmS `hostname`_$i bash -c "AFL_PRELOAD=/home/fuzzing/afl-2.52b/libdislocator/libdislocator.so afl-fuzz -S `hostname`_$i -x yaml_dict.txt -i input -o output ./tests/run-parser @@" ; done
```

Allright. If we did no mistake, one master instance as well as three slave instances should be running on one node by now.

Now we go one and start our fuzzing job on every single node. We use a little script for that which copies our fuzzing project onto our zramdisk under ```/fuzzing```.

```bash
# Resume or start our examplaric fuzzing job
# If you reuse that, change the according folder names

tar xzvf fuzzproject.tar.gz.bak -C /fuzzing
cd /fuzzing/libyaml
for i in {0..3} ; do screen -dmS `hostname`_$i bash -c "AFL_PRELOAD=/home/fuzzing/afl-2.52b/libdislocator/libdislocator.so afl-fuzz -S `hostname`_$i -x yaml_dict.txt -i- -o output ./tests/run-parser @@" ; done
```

Allright, allright. Now go checkout some of your nodes and see if everything worked out fine!
Next, we are going to take care about how we are going to synchronize our fuzzing instances.