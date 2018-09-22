---
title: "Basic configuration"
permalink: /docs/basic-configuration/
excerpt: "Information about the basic configuration"
toc: true
---


The configuration of the operating system is fairly basic as well. In the first step, we are going to prepare a single node, configure it and use that configuration on all the other nodes.

## Creating a template image

```bash
# Basic network configuration according to your network setup
# Give yourself a static IP adress, set that up in /etc/network/interfaces

# Hostname configuration
hostname YOURNAME

# Install all the software you need, below are some basics we are going to need to perform fuzzing

apt-get update
apt-get upgrade
apt-get install zsh
apt-get install git
apt-get install screen
apt-get install macchanger
apt-get install clang
apt-get install gcc
apt-get install autoconf
apt-get install libtool


# Create a fuzzing user and give him a home dir

sudo useradd -m -s $(which zsh) fuzzing

# Switch to user, create a keypair and use that for authentication over SSH
su fuzzing
ssh-keygen -t rsa -b 4096
cd 
cat .ssh/id_rsa.pub > .ssh/authorized_keys
# I gave this user sudo rights (of course in the most insecure configuration possible)
# Add this entry to /etc/sudoers
fuzzing	ALL=(ALL) NOPASSWD:ALL
```
## Populate the prepared image
The initial configuration was perfomed on a single node. After it's done, eject the SD card and dd it.

```bash
dd if=/dev/sdb of=ubuntu_prepared.iso bs=64K conv=noerror,sync status=progress
```
Now go on and flash that image to all your SD cards
```bash
dd if=ubuntu_prepared.iso of=/dev/sdb bs=64K conv=noerror,sync status=progres
```

Keep in mind that you have to change the IP adress of every single newly booted node. You can avoid that by using a DHCP server with long living leases or fixed IP adresses for your nodes. 

After that initial configuration, check if you can reach all your nodes using SSH and the same ssh key. For automatically using the right SSH key when connecting to your nodes, I am using the following configuration:

```bash
~ » cat ~/.ssh/config
Host 192.168.150.2??
   IdentityFile ~/.ssh/fuzzing_ssh_key
``` 
Adjust the host parameter according to your network configuration. The question marks in the SSH client config file can actually be used as a wildcard.


