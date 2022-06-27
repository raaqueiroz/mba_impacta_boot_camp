<h1 align="center">
  Implantar Jenkins em Kubernetes EKS com Pipelines executando stages em conteineres
  <br/><br/>
  <img src="https://public-transfer-temp-files.s3.amazonaws.com/logo_jenkins_seta_bidirecional_logo_kubernetes.png">
</h1>
<br/><br/>

# Descrição do projeto
Implantação de um servidor Jenkins em um cluster Kubernetes EKS, serviço gerenciado da AWS, e configuração de Pipeline para realização de builds e deploys de aplicações utilizando conteineres e PODs.
Com o uso de ferramenta de IaC Terraform para provisionamento de infraestrutura na nuvem AWS e uso de script shell para instalação dos serviços.
Todos os passos, opções e telas descritas abaixo estarão em português.

<br/><br/>

# Pré Requisitos
Necessário executar tudo em sistema operacional Linux, para esse projeto foram usados os seguintes recursos e versões

- :cloud: AWS CLI (aws-cli/2.4.14)
- :earth_americas: Terraform (v1.2.3)
- :snake: Python (3.8.10)
- :chart_with_upwards_trend: Helm (v3.7.0)

<br/>

:warning: _Configurar o AWS CLI profile default com as credenciais da conta que serão implementados todos os recursos_

<br/><br/>

# Instalação
Seguir os passos abaixo

<br/>

1. Realizar o clone desse repositório em sua máquina Linux

```bash
git clone https://github.com/raaqueiroz/mba_impacta_boot_camp.git
```
<br/>

<img src="https://public-transfer-temp-files.s3.amazonaws.com/git-clone.gif" height="300" />


2. Criar uma VPC com subnets pública e privada onde serão provisionados os serviços.<br/>
:information_source: _Caso já possua uma VPC definida, necessário editar os arquivos terraform do cluster-jenkins e pular o passo 2_

```bash
cd mba_impacta_boot_camp/terraform/networking/
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```
<br/>

<img src="https://public-transfer-temp-files.s3.amazonaws.com/terraform-vpc.gif" height="300" />

3. Criar recursos AWS dentro da VPC provisionada no passo 2.

Será criado
- 1 cluster EKS
- 1 Nodegroup do EKS com uma instância EC2 SPOT (t3.medium) 
- 1 Sistema de arquivos EFS

```bash
cd ../cluster-jenkins/
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```
<br/>

<img src="https://public-transfer-temp-files.s3.amazonaws.com/terraform-cluster-jenkins.gif" height="300" />

4. Instalar serviços no cluster Kubernetes, a partir da execução do script shell

```bash
cd ../../k8s/
sed -i 's/\r//g' install_jenkins.sh
sh install_jenkins.sh
```
<br/>

<img src="https://public-transfer-temp-files.s3.amazonaws.com/terraform-cluster-jenkins.gif" height="300" />

5. Acessar a interface do Jenkins pela URL do Load Balancer.
É possível pegar essa informação com o output de execução do script shell que instala todos os serviços

<img src="https://public-transfer-temp-files.s3.amazonaws.com/terraform-cluster-jenkins.gif" height="300" />

<br/><br/>

# Instalação de plugins Jenkins
Acessar o menu de instalação de plugins
- Gerenciar Jenkins
- Gerenciar Extensões
- Disponíveis

Plugins para instalar:
- Kubernetes
- Pipeline
- Pipeline: Job
- Matrix Authorization Strategy

Selecionar os plugins acima e clicar no botão para instalar sem reiniciar.
Aguardar a instalação, e após concluir marcar a caixa para reiniciar o serviço do Jenkins.

<img src="https://public-transfer-temp-files.s3.amazonaws.com/jenkins-plugins.gif" height="300" />

<br/><br/>

# Configuração de segurança Jenkins
Acessar o menu de configuração de segurança
- Gerenciar Jenkins
- Configurar Segurança Global

<br/>

Na página de configuração de segurança

- Selecionar a opção de segurança realm para _"Base de dados interna do Jenkins"_
- Marcar a opção _"Permitir que os usuários se inscrevam"_
- Selecionar a opção de autorização _"Qualquer um pode fazer qualquer coisa"_

<br/>

:floppy_disk: Salvar as configurações

<br/><br/>

Recarregar novamente a URL do Jenkins.
Clicar na opção _"Criar uma nova conta"_

- Criar um novo usuário que será o administrador.
- Efetuar o login com o novo usuário criado.

<br/>

Acessar o menu de configuração de segurança

- Gerenciar Jenkins
- Configurar Segurança Global

<br/>

Na página de configuração de segurança

- Na parte de segurança realm, remover a opção _"Permitir que os usuários se inscrevam"_
- Alterar a opção de autorização para _"Segurança baseada em matriz"_
- Clicar no botão _"Add User"_
- Informar o nome do novo usuário que foi criado
- Marcar a primeira opção de _"Administer"_ como permissão para o novo usuário que foi adicionado à lista

<br/>

:floppy_disk: Salvar as configurações

<img src="https://public-transfer-temp-files.s3.amazonaws.com/jenkins-security2.gif" height="300" />

<br/><br/>

# Configurar agents em PODs para Kubernetes
Acessar o menu de configuração de agentes

- Gerenciar Jenkins
- Gerenciar nós
- Configurar nuvens

Adicionar um novo Cloud Agent do tipo Kubernetes.

Conforme exemplo, preencher os campos abaixo seguindo os ícones, ações e campos em branco

- Campo
  - Informação que será colocada

- Campo
  - //// VAZIO ////

<br/>

_Ação à ser executada_

## Kubernetes Cloud Details

<br/>

Clicar no botão _"Kubernetes Cloud Details..."_  e seguir com o preenchimento <br/>

- Name
  - kubernetes

- Kubernetes URL
  - https://kubernetes.default:443

- Kubernetes Namespace
  - jenkins

- Jenkins URL
  - http://jenkins.jenkins.svc.cluster.local:8080

- Jenkins tunnel
  - jenkins:50000

<br/>

<img src="https://public-transfer-temp-files.s3.amazonaws.com/kubernetes-details.gif" height="300" />

## Pod Templates

<br/>

Clicar no botão _"Pod Templates..."_ <br/>
Clicar no botão _"Add Pod Template"_ <br/>
Clicar no botão _"Pod Template details..."_ <br/>
Preencher os campos.

- Name
  - python38

- Namespace
  - jenkins

- Labels
  - python38 (Essa será a label usada como agent na execução de Pipelines)

<br/>

<img src="https://public-transfer-temp-files.s3.amazonaws.com/pod-template.gif" height="300" />

### Containers

<br/>

Clicar no botão _"Add Container"_ <br/>
Clicar na opção _"Container Template"_ <br/>
Preencher os campos.

- Name
  - python38 (Recomendado ter o mesmo nome da label do Pod Template)

- Docker image
  - python:3.8.13-slim

- Working directory
  - /home/jenkins/agent

- Command to run
  - //// VAZIO ////

- Arguments to pass to the command
  - //// VAZIO ////

- Allocate pseudo-TTY
  - Marcar a opção

<br/>

<img src="https://public-transfer-temp-files.s3.amazonaws.com/containers.gif" height="300" />

### Volumes

<br/>

Clicar no botão _"Add Volume"_ <br/>
Clicar na opção _"Host Path Volume"_ <br/>
Preencher os campos.


- Host path
  - /var/run/docker.sock

- Mount path
  - /var/run/docker.sock

<br/>

<img src="https://public-transfer-temp-files.s3.amazonaws.com/volumes.gif" height="300" />

### Service Account

<br/>

Descer a página até encontrar o campo _"Service Account"_

- Service Account
  - jenkins

<br/>

<img src="https://public-transfer-temp-files.s3.amazonaws.com/service-account.gif" height="300" />

:floppy_disk: Salvar as configurações

<img src="https://public-transfer-temp-files.s3.amazonaws.com/save-kubernetes.gif" height="300" />

<br/><br/>

# Executar Pipeline de teste
## Criar um novo job do tipo Pipeline
Na página inicial do Jenkins, clicar na opção _"Create a job"_
Preencher o nome do job como _"Pipeline"_
Selecionar o tipo de job _"Pipeline"_

<br/>

Na página das configurações do job

- Acessar a guia _"Pipeline"_
- Em _"Definition"_ selecionar a opção _"Pipeline script"_
- Copiar todo o conteúdo da pipeline de teste nesse aquivo [Jenkinsfile](https://github.com/raaqueiroz/mba_impacta_boot_camp/blob/main/jenkins-pipeline/Jenkinsfile)

<br/>

:floppy_disk: Salvar o job

<img src="https://public-transfer-temp-files.s3.amazonaws.com/criar-pipeline.gif" height="300" />

<br/>

## Efetuar _Build_ pipeline de teste
Após criar o job do tipo Pipeline, será possível acessá-lo e efetuar a construção (_build_). <br/>
Para disparar a execução desse job clicar no botão _"Construir agora"_

<img src="https://public-transfer-temp-files.s3.amazonaws.com/build.gif" height="300" />

<br/>

## Verificar logs e execução
Na página do job é possível verificar todas as construções executadas. <br/>
Para acessar as informações de uma execução, clicar no número da construção que deseja consultar. <br/>
Dentro das informações da construção clicar em _"Console Output"_. <br/>

<br/>

Nos logs vamos verificar que foi alocado um novo POD pelo Jenkins, e dentro desse POD foram lançados 2 conteineres. O primeiro conteiner sempre vai se chamar **_"jnlp"_** pois é o conteiner com o serviço de agente para efetuar a conexão e comunicação do POD com o servidor do Jenkins, enquanto o segundo conteiner lançado possui o nome que foi configurado na subetapa [Containers](https://github.com/raaqueiroz/mba_impacta_boot_camp#containers), e este é responsável por executar os comandos e instruções passados pela pipeline.

<img src="https://public-transfer-temp-files.s3.amazonaws.com/logs.gif" height="300" />

<br/><br/>

# Continuidade
:trophy:

É possível dar sequencia nesse projeto e realizar a construção de novas pipelines mais completas configurando diversos templates de PODs com seus respectivos conteineres.

Cada template de POD é tratado como um agente dentro do Jenkins e pode ser invocado a qualquer momento ao longo da execução de uma pipeline, como por exemplo um agente específico para processar cada stage da sua pipeline.

Cada template de POD pode ter um tipo diferente de conteiner, é possível também utilizar imagens docker personalizadas, que estejam publicadas no Registry do Docker Hub, para execução de comandos específicos.

Para criar novos templates de PODs e ter novos agentes disponíveis com diferentes bibliotecas e comandos, é necessário repetir a subetapa [Pod Templates](https://github.com/raaqueiroz/mba_impacta_boot_camp#pod-templates) e seus passos seguintes.
