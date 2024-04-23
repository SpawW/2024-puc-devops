# Comandos de criação do novo ambiente... 

### (opcional) Listar todas as imagens que contenham a palavra ubuntu

```
aws ec2 describe-images --owners amazon --filters "Name=architecture,Values=x86_64" "Name=root-device-type,Values=ebs" "Name=virtualization-type,Values=hvm" --query 'Images[?contains(Name, `ubuntu`) ].[ImageId,Name]' --output table 

```

Pegando exatamente uma imagem ubuntu para usarmos em free tier...

```

aws ec2 describe-images --owners amazon --filters "Name=architecture,Values=x86_64" "Name=root-device-type,Values=ebs" "Name=virtualization-type,Values=hvm" --query 'Images[?contains(Name, `ubuntu`) ].[ImageId,Name]' --output table  | grep 7408

```

### Listar todas as chaves SSH disponíveis na conta

Colocando em variável para uso posterior...

```

key_name=$(aws ec2 describe-key-pairs --query 'KeyPairs[0].KeyName' --output text)

```

### Criação de grupo de segurança

```
sec_group_name=sec-puc-mg-devops
sec_group_id=$(aws ec2 create-security-group --group-name $sec_group_name --description "Allow 22, 80, 443 and 8000-10000" --output text)

```

### Configuração do grupo de segurança
```

aws ec2 authorize-security-group-ingress --group-name $sec_group_name --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $sec_group_name --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $sec_group_name --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $sec_group_name --protocol tcp --port 8000-10000 --cidr 0.0.0.0/0

```


## Vamos criar o EC2 usando o AWS CLI

ID de imagem    : ami-080e1f13689e07408
ID de chave SSH : vockey

```

ec2_name="server01"
aws ec2 run-instances --image-id ami-080e1f13689e07408 --instance-type t2.micro --key-name $key_name --security-groups $sec_group_name --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$ec2_name}]" > resultado_ec2.json

```

Aguardar a conclusão da inicialização da instância e extrair o ID de instância:


```

ec2_instance_id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ec2_name" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)

aws ec2 describe-instance-status --instance-ids $ec2_instance_id

```

Descobrindo o IP da instancia 

```
ec2_public_ip=$(aws ec2 describe-instances --instance-ids $ec2_instance_id --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)

```

### Acesse o EC2 criado

```
ssh -i .ssh/labsuser.pem ubuntu@$ec2_public_ip

```

Falhou? Corrija as permissões do arquivo PEM e tente novamente

#### Instalar o ansible

```

sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible 

```

#### Clone o SEU repositório (não o do professor...)

```
git clone -b ansible_version https://github.com/<SEU USER>/2024-puc-devops.git

cd 2024-puc-devops

```
#### Instalar o docker usando o ansible 

```

ansible-playbook install-docker.yml
```

Teste o docker... falhou?... corrija !!!
Falhou ainda? Qual ação é necessária? O que você precisou fazer para solucionar?

Suba o ambiente usando o docker compose


