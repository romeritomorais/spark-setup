#!/bin/bash

echo """
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+  ____                   _      ___           _        _ _                               +
+ / ___| _ __   __ _ _ __| | __ |_ _|_ __  ___| |_ __ _| | |                              +
+ \___ \| '_ \ / _' | '__| |/ /  | || '_ \/ __| __/ _' | | |                              +
+  ___) | |_) | (_| | |  |   <   | || | | \__ \ || (_| | | |                              +
+ |____/| .__/ \__,_|_|  |_|\_\ |___|_| |_|___/\__\__,_|_|_|                              +
+       |_|                                                                               +
+ instalador autonomo do apache-spark 3.2.0                                               +
+ desenvolvido por Romerito Morais https://www.linkedin.com/in/romeritomorais/            +
+ testado nas distribuiçõs derivados de RHEL, Debian                                      +
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"""

export USER_DIST=$(cat /etc/os-release | head -3 | tail -1 | cut -d "=" -f 2)
export USER_HOME=$HOME

SPARK="spark-3.2.0"
HADOOP_VERSION="bin-hadoop3.2"
JUPYTER_LAB_VERSION="3.4.3"
INSTALL_DIRECTORY=$(pwd)
INSTALL_BIN_SPARK="https://archive.apache.org/dist/spark/${SPARK}/${SPARK}-${HADOOP_VERSION}.tgz"

sudo rm -rf /opt/apache-spark-${SPARK:6:6}
# sudo rm -rf /usr/share/applications/jupyterlab.desktop
sudo rm -rf /usr/local/spark-${SPARK:6:6}
sudo mkdir -p /opt/apache-spark-${SPARK:6:6}/src

clear

echo """
************************************************************************************************************************************************************************************************
instalando as dependencias do ${SPARK} ...
************************************************************************************************************************************************************************************************
"""

if [ ${USER_DIST} = fedora ] || [ ${USER_DIST} = centos ]; then
    sudo yum install python3-pip
    sudo yum remove jupyter-notebook -y
    sudo pip3 uninstall spylon-kernel -y
    sudo pip3 uninstall -y pyspark
    sudo yum remove python3-nbformat==5.1.3
    sudo yum update -y
    sudo yum install java-11-openjdk-devel -y
    sudo yum install java-1.8.0-openjdk-devel -y
    sudo pip3 install --upgrade pip
    sudo pip3 install spylon-kernel
    sudo python3 -m spylon_kernel install
    sudo yum install jupyter-notebook -y
    sudo pip3 install pyspark==${SPARK:6:6}
    sudo pip3 install delta-spark==2.0.0
    sudo pip3 install koalas
    sudo pip3 install sparksql-magic
    sudo yum install xdg-utils -y
elif [ ${USER_DIST} = ubuntu ] || [ ${USER_DIST} = linuxmint ] || [ ${USER_DIST} = pop ]; then
    sudo apt install python3-pip -y
    sudo apt remove jupyter-notebook -y
    sudo pip3 uninstall spylon-kernel -y
    sudo pip3 uninstall -y pyspark
    sudo apt remove python3-nbformat==5.1.3
    sudo apt update -y
    sudo apt install default-jre -y
    sudo apt install openjdk-8-jdk -y    
    sudo pip3 install --upgrade pip
    sudo pip3 install spylon-kernel
    sudo python3 -m spylon_kernel install
    sudo pip3 install terminado --user --ignore-installed
    sudo apt install jupyter-notebook -y
    sudo pip3 install pyspark==${SPARK:6:6}
    sudo pip3 install delta-spark==2.0.0
    sudo pip3 install koalas
    sudo pip3 install sparksql-magic
    sudo apt install xdg-utils -y
fi


echo """
************************************************************************************************************************************************************************************************
baixando o framework ${SPARK} com o sistema de arquivo distribuido ${HADOOP_VERSION} ...
************************************************************************************************************************************************************************************************
"""
sudo wget -c -P /opt/apache-spark-${SPARK:6:6}/src ${INSTALL_BIN_SPARK}
sudo cp ${INSTALL_DIRECTORY}/img/jupyterlab.png /opt/apache-spark-${SPARK:6:6}/src
sudo cp ${INSTALL_DIRECTORY}/img/logo-64x64.png /usr/local/share/jupyter/kernels/spylon-kernel/


echo """
************************************************************************************************************************************************************************************************
instalando o framework ${SPARK} com o sistema de arquivo distribuido ${HADOOP_VERSION} ...
************************************************************************************************************************************************************************************************
"""

cd /opt/apache-spark-${SPARK:6:6}/src
sudo tar -xvf "${SPARK}-${HADOOP_VERSION}.tgz"

sudo mv /opt/apache-spark-${SPARK:6:6}/src/${SPARK}-${HADOOP_VERSION}  /opt/apache-spark-${SPARK:6:6}
sudo ln -s /opt/apache-spark-${SPARK:6:6}/${SPARK}-${HADOOP_VERSION}/ /usr/local/spark-${SPARK:6:6}

echo "export SPARK_HOME=/usr/local/spark-${SPARK:6:6}" >> ~/.bashrc
echo 'export PYTHONPATH=$(ZIPS=("$SPARK_HOME"/python/lib/*.zip); IFS=:; echo "${ZIPS[*]}"):$PYTHONPATH' >> ~/.bashrc
source ~/.bashrc

cat << EOF > /tmp/kernel.json
{
    "argv": [
        "/usr/bin/python3",
        "-m",
        "spylon_kernel",
        "-f",
        "{connection_file}"
    ],
    "display_name": "Spark-${SPARK:6:6}",
    "env": {
        "PYTHONUNBUFFERED": "1",
        "SPARK_SUBMIT_OPTS": "-Dscala.usejavacp=true"
    },
    "language": "scala",
    "name": "spylon-kernel"
}
EOF

sudo cp /tmp/kernel.json /usr/local/share/jupyter/kernels/spylon-kernel
sudo rm -rf /tmp/kernel.json

sleep 5

echo """
************************************************************************************************************************************************************************************************
softwares instalados com sucesso!!

apache-spark-${SPARK:6:6}-${HADOOP_VERSION}
jupyter-notebook-$(jupyter-notebook --version)

**** observação ****
procure no menu de programas pelo aplicativo Jupyter Laboratory na categoria programming
************************************************************************************************************************************************************************************************
"""
