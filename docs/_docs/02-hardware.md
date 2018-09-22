---
title: "Hardware"
permalink: /docs/hardware/
excerpt: "Pick the hardware, peripherals and the network components"
toc: true
---

Below, you find the hardware I am currently using. After having my first small prototype running, I tried to incorporate my "lessons learned", mainly what I would do different by now. I am listing what I bought to build it - that is by now means a recommendation to buy and absolutly no guarantee that it is the right coice for you.

## The ARM board

In my current setup, I am using 10 Pine A64+ Boards with 1 GB of RAM. 
[You can find the reference to the shop right here.](https://www.pine64.org/?product=pine-a64-board-1gb)
I picked the board because it gives me a fine kick for the buck, 19$ for an ARM Coretex with 4 cores is a quite good deal.
First thing what I would probably do different the next time is investing 10$ more and get 2 GB of RAM. It might get a bit of a hustle to get along with 1 GB of RAM, since I am running my fuzzing jobs inside of a ramdisk and forced me to compress my ramdisk (which works fine as well). On the other side, I am staying cheap. 

**Side note:** If you are thinking about doing this thing a bit more professional, think about buying an actual clusterboard. There are quite a lot availabe on the market, [just like this one here.](https://www.pine64.org/?product=clusterboard-with-7-sopine-compute-module-slots) It might cost you a bit more, but they are probably make you save quite some money on some peripherals, since these clusterboards include a Ethernet port exposing a switch that makes connecting to the individual boards easy. Also, you won't have to worry about power supply for each and every board anymore, since thats brought by the clusterboard.
{: .notice--info}
Right now, I am stacking the boards onto another, [using M3 standard standoff screws](https://www.amazon.com/gp/product/B07411J312/ref=oh_aui_detailpage_o00_s00?ie=UTF8&psc=1).

You can find a picture of my current tower below:
![ARM tower]({{ "/assets/images/tower.jpg" | absolute_url }})

## Cooling

Right now, I am using a standart heatsink, also sold by Pine64 in their [store](https://www.pine64.org/?product=rock64pine-a64-heatsink). Lets put it like this - they are better then nothing. But for fuzzing purposes, which means running all CPUs on a 100% for a longer time, thats not enough. Right now, I am thinking about adjusting two 120mm fans on the side of my tower. They are close to silent and should bring down the temperature from currently 80 to 90 degress Celsius to a more reasonable level. If noise is not an issue for you, just go for active cooling for your boards.

## Storage

Once again, I went cheap and bought standard SD cards from [amazon](https://www.amazon.com/gp/product/B0162YQEIE/ref=oh_aui_detailpage_o03_s03?ie=UTF8&psc=1). During fuzzing, I try to keep interaction with the SD card to a minimum, since these cards are not very well suited for load intensive operations. Fuzzing can be very disk i/o intensive, that's why I am using a dedicated fuzzing ramdisk.
Once again, if you want to do it a bit more professional, think about buying a board that supports EMMC natively or buy an [adapter](https://www.pine64.org/?product=usb-adapter-for-emmc-module) and an EMMC module of your choice, for example [this one](https://www.pine64.org/?product=16gb-emmc).  

## Power supply

These boards need 5V on 2 Amps over MicroUSB. Make sure that your power supply actually delivers that. There are supposed to be a lot of USB hubs out there which will not deliver that - especially when you are using a multi port USB hub with a board connected to every port. Read the specification of your USB power supply. I am using [this one here](https://www.amazon.com/gp/product/B076J6T7J5/ref=oh_aui_detailpage_o03_s02?ie=UTF8&psc=1) in combination with very short USB cables, so that it doesn't get to messy (0,3 meters).

## Network peripherals

You probably want to connect them to the network, so you are going to need some sort of standard switch. Since synchronisation between the nodes won't be that I/O intensive, I decided to go save some more money by just buying cheap Fast Ethernet swiches (100 Mbit/s). I am using [this one here](https://www.amazon.de/gp/product/B0034CL3MA/ref=oh_aui_detailpage_o03_s02?ie=UTF8&psc=1).
You will still need cables to connect the boards as well as an uplink to your home network. Once again, I bought cables that are really small (0.5 meters).

## Overall cost

If you are taking all peripherals into consideration, the cost for the 10 node cluster with overall 40 ARM cortex A53 cores with 1.2 Ghz and a total of 10 GB RAM was something around 350$ (310 Euro). As I said in the beginning, think about if that is the right choice for you, since you can rent quite a good numer of EC2 instances for that money. Also, my guess is that an actuall clusterboard would not be that much more expensive, since its saving you a lot of the peripherals and is actually a bit more professional to operate.





