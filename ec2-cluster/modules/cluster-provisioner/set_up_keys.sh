#!/usr/bin/env bash

user=$1
instance_ips=( `echo $2 | jq '.[]' -r` )

public_keys=()

for ip in "${instance_ips[@]}"
do
   ssh $user@$ip -o StrictHostKeyChecking=no -n "ssh-keygen -t rsa -b 4096 -N \"\" -f /home/${user}/.ssh/id_rsa"   

   public_key=`ssh $user@$ip -o StrictHostKeyChecking=no -n "cat /home/$user/.ssh/id_rsa.pub"`
   public_keys+=( "$public_key" )
done

for ip in "${instance_ips[@]}"
do
   ssh $user@$ip -o StrictHostKeyChecking=no -n "printf \"%s\n\" \"${public_keys[@]}\" >> /home/$user/.ssh/authorized_keys"
done
