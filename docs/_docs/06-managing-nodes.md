---
title: "Managing nodes"
permalink: /docs/managing-nodes/
excerpt: "just some information about how I control the nodes"
toc: true
---

For managing all the nodes as simultanious as possible and with a small management overhead, I decided to use the most simple approach I could come up with - SSH and bash scripts. I realize that there are much more sofisticated configuration management solutions out there, e.g. chef, puppet. Even using Docker and Docker swarm for the entire configuration and the deployment of fuzzing jobs is an option. But for my case, SSH and scripts are sufficient.

The following script expects a bash script as an argument and runs it on all hosts listed in `hostlist`.

```bash
HOSTLIST="node1
node2
node3
node4
node5"


for HOST in $HOSTLIST
do
     echo "Connecting to $HOST" && ssh fuzzing@$HOST 'bash -s' < $1 &
done
``` 

Now we are able to manage our nodes in one of the easiest ways possible. They should be set up and configured at this point and we are ready to deploy a first test run.