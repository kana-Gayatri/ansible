#!/bin/bash
 COUNT=$(aws ec2 describe-instances --filters  "Name=tag:Name,Values=$1" | jq ".Reservations[].Instances[].PrivateIpAddress" | grep -v null  | wc -l )

if [  $COUNT -eq 0 ] ; then
   #ami-0e4e4b2f188e91845  old image id
#   ami-0dc863062bc04e1de new image id

    aws ec2 run-instances --image-id ami-0855cab4944392d0a --instance-type t3.micro --security-group-ids  sg-017e24d5e5f10677e --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]" | jq &>/dev/null
     else
    echo -e "\e[1;33m$1 Instance already exists\e[0m"
  fi

 IP=$(aws ec2 describe-instances --filters  "Name=tag:Name,Values=$1" | jq ".Reservations[].Instances[].PrivateIpAddress" | grep -v null  | xargs )
  ## xargs is used to remove the double  quotes
  sed -e "s/DNSNAME/$1.roboshop.internal/" -e "s/IPADDRESS/${IP}/" record.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id Z021234083EL1N0CXFXW --change-batch file:///tmp/record.json | jq  &>/dev/null
#Z021234083EL1N0CXFXW


#CREATE() {
#   COUNT=$(aws ec2 describe-instances --filters  "Name=tag:Name,Values=$1" | jq ".Reservations[].Instances[].PrivateIpAddress" | grep -v null  | wc -l )
#
#  if [ $COUNT -eq 0 ]; then
#   aws ec2 run-instances --image-id ami-0e4e4b2f188e91845 --instance-type t3.micro --security-group-ids  sg-017e24d5e5f10677e --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]" | jq &>/dev/null
#  else
#    echo -e "\e[1;33m$1 Instance already exists\e[0m"
#    return
#  fi
#
#  sleep 5
#
#
#IP=$(aws ec2 describe-instances --filters  "Name=tag:Name,Values=$1" | jq ".Reservations[].Instances[].PrivateIpAddress" | grep -v null  | xargs )
#  ## xargs is used to remove the double  quotes
#  sed -e "s/DNSNAME/$1.roboshop.internal/" -e "s/IPADDRESS/${IP}/" record.json >/tmp/record.json
#  aws route53 change-resource-record-sets --hosted-zone-id Z021234083EL1N0CXFXW --change-batch file:///tmp/record.json | jq  &>/dev/null
#
#  }
#
#if [ "$1" == "all" ]; then
#  ALL=(frontend mongodb catalogue redis user cart mysql shipping rabbitmq payment)
#  for component in ${ALL[*]}; do
#    echo "Creating Instance - $component "
#    CREATE $component
#  done
#else
#  CREATE $1
#fi