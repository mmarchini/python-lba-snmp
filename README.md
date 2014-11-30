# TwinEngine+SNMP [ SNMP ]

Esse é um projeto para a disciplina de [INF01015] Gerência e Aplicação em Redes do curso de Ciência da 
ComutaçãoUniversidade Federal do Rio Grande do Sul. 

O objetivo do projeto é extender um agente SNMP (nesse caso, o Net-SNMP) para disponibilizar uma MIB
customizada que permita acessar e alterar os dados de um jogo. Para tal, foi escolhido o projeto open-source
TwinEngine, que é uma re-implementação do jogo Little Big Adventure, desenvolvido pela Adeline Software 
International em 1994. 
Meu objetivo é possibilitar manipulação do jogo através de uma Interface Web, que se comunica com um Web-Server
que também exerce o papel de Gerente SNMP, se comunicando com o Agente responsável pela comunicação com o jogo. 

O código presente nesse repositório é a implementação em Python de uma extensão do Net-SNMP, utilizando a
biblioteca python-netsnmpagent. O programa se comunica com o TwinEngine através de UNIX Sockets.

## Dependências

Para rodar essa aplicação, você vai precisar instalar os seguintes programas:

* Python
* Virtualenv 
* Net-SNMP 

Caso ainda não tenha eles instalados, siga os passos abaixo para
instalá-los:

### Ubuntu

```bash
sudo apt-get install python python-virtualenv snmpd snmp
```

## Instalação

Para instalar a aplicação, entre na pasta do projeto e siga os passos abaixo:

```bash
virtualenv .env
. .env/bin/activate
python setup.py installl
```

## Rodando

Para rodar o agente, basta executar o comando:

```bash
./run_lba_agent.sh
```


