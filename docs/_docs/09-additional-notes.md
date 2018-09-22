---
title: "Additional notes"
permalink: /docs/additional-notes/
excerpt: "Some notes."
toc: true
---

Allright, right now we should have our little fuzzing cluster up and running and the basics about using AFL are more or less clear, I guess. There are a lot of more options that you could consider when fuzzing.

## AFL persistent mode

Right now, we are using AFL in the most simple way. To gain performance, you should consider using AFLs [persistent mode](https://lcamtuf.blogspot.com/2015/06/new-in-afl-persistent-mode.html). When using AFL in the traditional way, AFl is using its own fork server optimization, which gives AFL a huge performance boost comparing to using a syscall to restart a program after every single run. But still, forking after every run can lead to some overhead. When using in-memory fuzzing in contrast, tests cases are generated during the execution of the process and the according functions which you want to fuzz are being called afterwards, handing over the fuzzing input. AFL supports this as well. We have to write a little fuzzing harness inside of our target, which lets AFL know where to start fuzzing and how often it should perform in-memory execution before restarting the process.

```c
while (__AFL_LOOP(1000)) {

	/* here be your function calls */

}
```

Go on and read AFLs manuals as well as some interesting examples that are being shiped with it.



## Read AFLs performance tips

When you are choosing your own fuzzing target, don't start fuzzing before you have read @lcamtufs [various performance tips](https://github.com/mirrorer/afl/blob/master/docs/perf_tips.txt). If you wonder how I pick my input files smartly as well as optimizing the target during compilation in different ways, go check it out.

## Monitoring

To be honest, I dont use any monitoring solution and do it more or less manual right now. Of course, you could always copy over AFL status data from every node and somehow analyse that (there are tools out there for that), but it didn't made too much sense for my comparably small number of nodes. I just run the following command on all hosts using my SSH script tools and see if something pops up.
```bash
ls -la /fuzzing/YOUR-PROJECT-FOLDER/output/*/crashes
```
Crash triaging of a big number of crashes is another story for itself.

## Visualize code coverage

In case you wonder what AFL has discovered so far and which areas of your test library has been touched using which testcases, take a look at the project [afl-cov](https://github.com/mrash/afl-cov). It also allows you to see which functions have never been touched and might give you some insights on what you should change it order to reach more interesting functions.

## LibFuzzer

When it comes to in-process fuzzing, I strongly advise you to have a look at [libFuzzer](https://llvm.org/docs/LibFuzzer.html). When using libFuzzer, you create a small fuzzing harness file which feeds fuzzing input to specific functions, which makes it easy to generate specific tests of various aspects of an API. I would go for libFuzzer if I do know a bit more about a library and therefore know which parts of it I want to fuzz.

## Blog style and layout

I am using [jekyll](https://jekyllrb.com/) as a blog engine combined with a super nice layout, called [minimal mistakes](https://mmistakes.github.io/minimal-mistakes/).