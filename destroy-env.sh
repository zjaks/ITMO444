#!/bin/bash

echo -e Starting the destruction of your environment. '\n' '\n'

echo -e Describing Instances… '\n' '\n'

aws ec2 describe-instances --filters  "Name=instance-state-name,Values=pending,running,stopped,stopping" --query "Reservations[].Instances[].[InstanceId]" --output text | tr '\n' ' '

echo -e Updating min size of auto-scaling group… '\n' '\n'

aws autoscaling update-auto-scaling-group --auto-scaling-group-name scaling-group-1 --min-size 0 

echo -e Setting the desired capacity to 0… '\n' '\n'

aws autoscaling set-desired-capacity --auto-scaling-group-name scaling-group-1 --desired-capacity 0 --honor-cooldown

echo -e Waiting for termination… '\n' '\n'

aws ec2 wait instance-terminated --filters --query 'Reservations[0].Instances[].InstanceId'

echo -e Terminating all Instances… '\n' '\n'

aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filters  "Name=instance-state-name,Values=pending,running,stopped,stopping" --query "Reservations[].Instances[].[InstanceId]" --output text | tr '\n' ' ')

echo -e Waiting for termination… '\n' '\n'

aws ec2 wait instance-terminated --filters --query 'Reservations[0].Instances[].InstanceId'

echo -e Deleting auto-scaling group… '\n' '\n'

aws autoscaling delete-auto-scaling-group --auto-scaling-group-name scaling-group-1

echo -e Deleting launch configuration... '\n' '\n'

aws autoscaling delete-launch-configuration --launch-configuration-name launch-config-1

echo -e Deregistering Instances from the load balancer… '\n' '\n'

aws elb deregister-instances-from-load-balancer --load-balancer-name balancer-1 --instances $(aws ec2 describe-instances --filters  "Name=instance-state-name,Values=pending,running,stopped,stopping" --query "Reservations[].Instances[].[InstanceId]" --output text | tr '\n' ' ')

echo -e Deleting load balancer listeners… '\n' '\n'

aws elb delete-load-balancer-listeners --load-balancer-name balancer-1 --load-balancer-ports 80

echo -e Deleting load balancer… '\n' '\n'

aws elb delete-load-balancer --load-balancer-name balancer-1

echo -e Done. '\n' '\n'
