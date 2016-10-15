#!/bin/bash

if [ $# != 5 ]
then
	echo -e This requires 5 parameters to run: AMI ID, key-name, security-group, launch-configuration, and count. Please enter these in that order. '\n'
else

echo "Starting environment creation..."

echo -e "The AMI ID is: $1" 

echo -e "The key-name is: $2" 

echo -e "The security group number is: $3" 

echo -e "The launch configuration name is: $4"  

echo -e "The count desired is currently a dormant value:" 

echo -e Creating launch configuration...'\n'

aws autoscaling create-launch-configuration --launch-configuration-name $4 --image-id $1 --key-name $2 --instance-type t2.micro --security-groups $3 --user-data file://installenv.sh

echo -e Creating load balancer...'\n'

aws elb create-load-balancer --load-balancer-name balancer-1 --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --subnets subnet-1fb2917b --security-groups $3

echo -e Creating auto-scaling group...'\n'

aws autoscaling create-auto-scaling-group --auto-scaling-group-name scaling-group-1 --launch-configuration $4 --availability-zone us-west-2b --load-balancer-names balancer-1 --max-size 5 --min-size 2 --desired-capacity 3

echo -e Waiting on instance to be created...'\n'

aws ec2 wait instance-running --filters --query 'Reservations[].Instances[].InstanceId'

echo -e Done!'\n'

echo -e Here are your instance IDs: '\n'

aws ec2 describe-instances --filters  "Name=instance-state-name,Values=pending,running,stopped,stopping" --query "Reservations[].Instances[].[InstanceId]" --output text | tr '\n' ' '

fi
