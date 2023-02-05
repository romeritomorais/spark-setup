#!/bin/bash

echo """
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|     _                     _            ____                   _              |
|    / \   _ __   __ _  ___| |__   ___  / ___| _ __   __ _ _ __| | __          |
|   / _ \ | '_ \ / _` |/ __| '_ \ / _ \ \___ \| '_ \ / _` | '__| |/ /          |
|  / ___ \| |_) | (_| | (__| | | |  __/  ___) | |_) | (_| | |  |   <           |
| /_/   \_\ .__/ \__,_|\___|_| |_|\___| |____/| .__/ \__,_|_|  |_|\_\          |
|         |_|                                 |_|                              |
|                                                                              |
| installer of spark(scala & pyspark)                                          |
| developed by Romerito Morais https://www.linkedin.com/in/romeritomorais/     |    
| script tested on fedora32+, centos8+, ubuntu20.04+, popOs, linuxmint30.1+    |
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"""

# DEFINIÇÃO DE VERSAO DO SPARK/HADOOP
SPARK_VERSION="spark"
HADDOP_VERSION="bin-hadoop"
DELTALAKE_VERSION="2.1.1"

# EXTRAI O NOME DA DISTRO
export DISTRO=$(cat /etc/os-release | head -3 | tail -1 | cut -d "=" -f 2)
export USER=$HOME

Menu() {
echo "
Which version of Apache Spark do you want to install?
Opções:
     0)  ${SPARK_VERSION}-3.3.1-${HADDOP_VERSION}3.tgz
     1)  ${SPARK_VERSION}-3.3.0-${HADDOP_VERSION}3.tgz
     2)  ${SPARK_VERSION}-3.2.2-${HADDOP_VERSION}3.2.tgz
     3)  ${SPARK_VERSION}-3.2.1-${HADDOP_VERSION}3.2.tgz
     4)  ${SPARK_VERSION}-3.2.0-${HADDOP_VERSION}3.2.tgz
     5)  exit
  "
  echo
  echo -n "option code:  "
  read OPCAO

if [ $OPCAO -eq 0 ]; then
    export SPARK="${SPARK_VERSION}-3.3.1"
    export HADOOP="${HADDOP_VERSION}3"
elif [ $OPCAO -eq 1 ]; then
    export SPARK="${SPARK_VERSION}-3.3.0"
    export HADOOP="${HADDOP_VERSION}3"
elif [ $OPCAO -eq 2 ]; then
    export SPARK="${SPARK_VERSION}-3.2.2"
    export HADOOP="${HADDOP_VERSION}3.2"
elif [ $OPCAO -eq 3 ]; then
    export SPARK="${SPARK_VERSION}-3.2.1"
    export HADOOP="${HADDOP_VERSION}3.2"
elif [ $OPCAO -eq 4 ]; then
    export SPARK="${SPARK_VERSION}-3.2.0"
    export HADOOP="${HADDOP_VERSION}3.2"
fi

case $OPCAO in
    5) exit ;;
  esac

}

Menu

# CRIA OS DIRETORIOS TEMPORÁRIOS DA INSTALAÇÃO
mkdir -p "${USER}/.setup_${SPARK}"
mkdir -p "${USER}/.setup_${SPARK}/src"

# LINK DE ARQUIVOS A SEREM BAIXADOS
SCALA_ICON="https://cdn.iconscout.com/icon/free/png-256/scala-226059.png"
SPARK_BIN="https://archive.apache.org/dist/spark/${SPARK}/${SPARK}-${HADOOP}.tgz"


echo """
************************************************************************************************
installing dependencies ...
"""

# INSTALA DEPENDENCIAS DE ACORDO COM A DISTRO
if [ ${DISTRO} = fedora ] || [ ${DISTRO} = centos ]; then
    sudo yum install python3-pip
    sudo yum remove jupyter-notebook -y
    sudo pip3 uninstall spylon-kernel -y
    sudo pip3 uninstall jupyterlab -y
    sudo yum update -y
    sudo yum install java-11-openjdk-devel -y
    sudo yum install java-1.8.0-openjdk-devel -y
    sudo pip3 install --upgrade pip
    sudo pip3 install spylon-kernel
    sudo python3 -m spylon_kernel install
    sudo yum install jupyter-notebook -y
    if [ ${SPARK:6:5} = 3.2.0 ] || [ ${SPARK:6:5} = 3.2.1 ] || [ ${SPARK:6:5} = 3.2.2 ]; then 
      sudo pip3 install delta-spark==${DELTALAKE_VERSION}
    fi
    pip3 install pyspark==${SPARK:6:5}
    pip3 install sparksql-magic
elif [ ${DISTRO} = ubuntu ] || [ ${DISTRO} = pop ] || [ ${DISTRO} = linuxmint ]; then
    sudo apt install python3-pip -y
    sudo apt remove jupyter-notebook -y
    sudo pip3 uninstall spylon-kernel -y
    sudo pip3 uninstall jupyterlab -y
    sudo apt update -y
    sudo apt install default-jre -y
    sudo apt install openjdk-8-jdk -y    
    sudo pip3 install --upgrade pip
    sudo pip3 install spylon-kernel
    sudo python3 -m spylon_kernel install
    sudo pip3 install terminado --user --ignore-installed
    sudo apt install jupyter-notebook -y
    if [ ${SPARK:6:5} = 3.2.0 ] || [ ${SPARK:6:5} = 3.2.1 ] || [ ${SPARK:6:5} = 3.2.2 ]; then 
      sudo pip3 install delta-spark==${DELTALAKE_VERSION}
    fi
    pip3 install pyspark==${SPARK:6:5}
    pip3 install sparksql-magic
fi

echo """
************************************************************************************************
downloading the ${SPARK}-${HADOOP} ...
"""

# BAIXA OS BINÁRIOS
wget -c -P "${USER}/.setup_${SPARK}/src" $SCALA_ICON
wget -c -P "${USER}/.setup_${SPARK}/src" $SPARK_BIN

# RENOMEIA ARQUIVOS DE IMAGEM BAIXADA
mv "${USER}/.setup_${SPARK}/src/scala-226059.png" "${USER}/.setup_${SPARK}/src/logo-64x64.png" && sudo cp "${USER}/.setup_${SPARK}/src/logo-64x64.png"

echo """
************************************************************************************************
installing the ${SPARK}-${HADOOP} ...
"""

# ENTRA EM DIRETORIO TEMPORARIO E EXTRAIO OS ARQUIVOS DE INSTALAÇÃO
cd "${USER}/.setup_${SPARK}/src" && tar -xvf "${SPARK}-${HADOOP}.tgz"

# MOVE PASTA PARA RAIZ DO DIRETORIO ATUAL
mv "${USER}/.setup_${SPARK}/src/${SPARK}-${HADOOP}" "${USER}/.setup_${SPARK}/${SPARK}-${HADOOP}"

# CRIA LINK SIMBÓLICO
sudo ln -s "${USER}/.setup_${SPARK}/${SPARK}-${HADOOP}" /usr/local/${SPARK}-${HADOOP}

# MODIFICA DADOS DO ARQUIVO DE DEFINIÇÃO
cat << EOF > /tmp/kernel.json
{
    "argv": [
        "/usr/bin/python3",
        "-m",
        "spylon_kernel",
        "-f",
        "{connection_file}"
    ],
    "display_name": "${SPARK}",
    "env": {
        "PYTHONUNBUFFERED": "1",
        "SPARK_SUBMIT_OPTS": "-Dscala.usejavacp=true"
    },
    "language": "scala",
    "name": "spylon-kernel"
}
EOF

# COPIA ARQUIVO DO KERNEL PARA DIRETORIOS DO SISTEMA
sudo cp /tmp/kernel.json /usr/local/share/jupyter/kernels/spylon-kernel

# REMOVE CÓPIA LOCAL
sudo rm -rf /tmp/kernel.json

sleep 5

# PEGA VERSAO DO JUPUYTER INSTALADO
JUPYTER_VERSION=$(jupyter-notebook --version)

echo """
************************************************************************************************
apache-${SPARK}-${HADOOP} successfully installed!
delta-lake-${DELTALAKE_VERSION} successfully installed!
jupyter-notebook-${JUPYTER_VERSION} successfully installed!
************************************************************************************************
"""