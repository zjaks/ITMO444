#!/bin/bash

echo -e Starting environment creation...'\n'

echo -e Creating launch configuration...'\n'

aws autoscaling create-launch-configuration --launch-configuration-name launch-config-1 --image-id ami-06b94666 --key-name week3 --instance-type t2.micro --user-data file://installenv.sh

echo -e Creating load balancer...'\n'

aws elb create-load-balancer --load-balancer-name balancer-1 --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --subnets subnet-1fb2917b --security-groups sg-ae6ba2d7

echo -e Creating auto-scaling group...'\n'

aws autoscaling create-auto-scaling-group --auto-scaling-group-name scaling-group-1 --launch-configuration launch-config-1 --availability-zone us-west-2b --load-balancer-names balancer-1 --max-size 5 --min-size 2 --desired-capacity 3

echo -e Waiting on instances to be created and running...'\n'

aws ec2 wait instance-running --filters --query 'Reservations[].Instances[].InstanceId'

echo -e Complete!'\n'

echo -e Here are your instance IDs: '\n'

aws ec2 describe-instances --filters  "Name=instance-state-name,Values=pending,running,stopped,stopping" --query "Reservations[].Instances[].[InstanceId]" --output text | tr '\n' ' '
