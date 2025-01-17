#!/bin/bash
set -e

function install_awscli(){

  if [ $(command -v aws) ];then
    echo "Found AWS CLI: $(aws --version)"
    return
  fi

  echo "Installing AWS CLI..."

  if [ ! $(command -v unzip ) ];then
    if [ $(command -v yum) ];then
      echo "Installing unzip package with yum..."
      yum install unzip -y
    elif [ $(command -v apt-get) ];then
      echo "Installing unzip package with apt-get..."
      apt-get install unzip -y
    elif [ $(command -v zipper) ];then
      echo "Installing unzip package with zypper..."
      zypper i unzip -y
    else
      >&2 echo "Unable to find the package manager in your machine"
      >&2 echo "Please install the unzip package manually!"
      >&2 exit 1
    fi
  fi

  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  sudo ./aws/install

  echo "Clean up the installer"
  rm -rf awscliv2.zip aws
}

install_awscli

aws configure
