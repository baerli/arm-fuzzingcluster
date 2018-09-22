---
title: "Operating System"
permalink: /docs/operating-system/
excerpt: "Instructions for installing the theme for new and existing Jekyll based sites."
last_modified_at: 2018-03-20T15:59:00-04:00
toc: true
---

In the following chapter, I will highlight some details about which operation systems I chose. Also, I want to discuss what other options exist and why you should think about them.

## Choice of operating system

There is quite a number of operating systems [available](http://wiki.pine64.org/index.php/Pine_A64_Software_Release) for this board. For my prototype, I chose a standard Ubuntu Xenial, since that seemed to be the easiest way to get it running. In the beginning, I didn't even thought about it too much, but right now I am think about getting an Android image running (version 7 is officially supported, Android 8 build instructions for Pine64 are floating around). Why you may asking? Reading [Googles AddressSanitizers manual](https://github.com/google/sanitizers/wiki/AddressSanitizer), it looks like Android is the only operating system on ARM which is officially supported by ASAN (!!). I didn't tried it out yet, but I guess I am giving it a shot in the near future. 

If you don't know about the memory error detector AddressSanitizer (ASAN), go check out the documentation provided by Google. @lcamtufs [remarks about using ASAN](https://github.com/mirrorer/afl/blob/master/docs/notes_for_asan.txt) in a fuzzing process is worth a read, since he describes a lot about the potential caveats in using ASAN as well as other possibilties to find non-crashing bugs. 

Besides that, I couldn't think about too much constraints in the choice of operation system for my fuzzing purposes, as long as all the software I want to use in my process is compatible with the operating system.  