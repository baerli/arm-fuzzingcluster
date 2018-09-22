---
title: "Prerequisites"
permalink: /
excerpt: "Prerequisites when building an ARM based fuzzing cluster"
toc: true
---


Welcome to my tutorial about building an ARM based fuzzing cluster. A little disclaimier in the beginning: this is an ongoing little side project with lots and lots of things to improve. My main goal was to get a cheap little fuzzing setup which runs mostly by itself, doesn't consume too much energy and doesn't make too much noise. It was mainly build for me to have a good time, test some setups and get some crashes on the side.
Also, if you're expecting too much special setups for the ARM environment, I probably have bad news for you - a big aspect of the configuration could also be easily applied to a classical fuzzing cluster using x86 hosted somewhere in the cloud. When it comes to the specialities of the ARM environment and how this would effect a smart fuzzing environment, these might be things that I learn while using and tweaking it.


## Thinks to consider

In the following chapter I will describe my current setup and the reasons why I picked same configuration. Quite often, you will notice that I did it rather cheap and fast and sometimes doesn't even make to much sense - in fact, things could be improvised on a lot of levels. I tried to highlight this aspect whereever I see it and where I plan to change it in the future. Feel free to improve the setup wherever you think it fits your requirements or style better. For me, the entire thing is work in progress, meaning I will probably change my setup on every other fuzzing job I run anyways.
Also, I am by far not the first run to setup a fuzzing environment on ARM architecture. The first time I heard about it was by @fl0yd

### Why an ARM based fuzzing cluster?

The short answer is: why not? The hardware is affordable and easy on power consumption. ARM powers such a broad range of devices these days, ranging from mobile devices of all kinds, over the entire so called internet of things ending in a lot of network peripherals such as routers. You probably see the big attack surface in there. While we can analyze and also fuzz software compiled for ARM on x86 architectures using emulators or something comparable, why not run it natively on the according hardware.


### Does it make sense to build one myself?

Think about it - in my personal setup, the entire hardware including network peripherals costs something between 250 to 350 $. If you are planing to do a single fuzzing job and need the performance, I would rather go for renting some cloud ressources on EC2 or something comparable. Same goes for fuzzing on Windows, since I guess that in my current setup, there won't be a chance to run a Windows 10 for ARM on that hardware (by the way, somebody should probably do that).
But, if you are looking for a cheap and easy way to fuzz ARM software, which you can find all over the place, have a good time fiddling with the hardware and the setup and operate the entire cluster in your bedroom (like I do), go for it. The investment is not too high and you can't probably do too much wrong. 

If you dont't want to build one by yourself, there are other options, like renting the ressources, since ARM is in the cloud as well (e.g. EC2, Scaleway).    

