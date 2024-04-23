#!/bin/bash

key_name=$(aws ec2 describe-key-pairs --query 'KeyPairs[0].KeyName' --output text)
sec_group_name=sec-puc-mg-devops
sec_group_id=$(aws ec2 create-security-group --group-name $sec_group_name --description "Allow 22, 80, 443 and 8000-10000" --output text)
aws ec2 authorize-security-group-ingress --group-name $sec_group_name --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $sec_group_name --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $sec_group_name --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $sec_group_name --protocol tcp --port 8000-10000 --cidr 0.0.0.0/0
ec2_name="server01"
aws ec2 run-instances --image-id ami-080e1f13689e07408 --instance-type t2.micro --key-name $key_name --security-groups $sec_group_name --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$ec2_name}]" > resultado_ec2.json
# Loop até que a variável ec2_instance_id tenha um valor
while [[ -z "$ec2_instance_id" ]]; do
    ec2_instance_id=$(aws ec2 describe-instances \
                        --filters "Name=tag:Name,Values=$ec2_name" "Name=instance-state-name,Values=running" \
                        --query "Reservations[].Instances[].InstanceId" \
                        --output text)
    sleep 1  # Aguarda 1 segundo antes de tentar novamente
    echo "Aguardando criação do EC2..."
done

echo "A instância EC2 foi encontrada. ID: $ec2_instance_id"

aws ec2 describe-instance-status --instance-ids $ec2_instance_id

ec2_public_ip=$(aws ec2 describe-instances --instance-ids $ec2_instance_id --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)


ssh -i .ssh/labsuser.pem ubuntu@$ec2_public_ip

