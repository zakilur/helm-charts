#!/bin/bash

K3D_VER=v1.7.0


CUR_K3D=$($(which k3d) --version | awk '{print $3}')

if [[ "$CUR_K3D" != "$K3D_VER" ]] ; then 
    if [[ "$CUR_K3D" == "" ]]; then
    read -p "k3d does not seem to be installed. Would you like to install k3d version: [$K3D_VER]? [Yn] " -n 1 yn
        case $yn in    
            [Yy]* ) curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | TAG="$K3D_VER" bash;;
            [Nn]* ) echo -e "\nNot installing k3d";;
            * ) echo -e "\n Please answer yes or no.  Bye" && exit 0 ;;
        esac
    else
        read -p "Current k3d version: [$CUR_K3D]. Supported k3d version: [$K3D_VER].  Would you like to change? [Yn] " -n 1 yn
        case $yn in 
            [Yy]* ) curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | TAG="$K3D_VER" bash;;
            [Nn]* ) echo -e "\nContinuing with k3d version [$CUR_K3D]";;
            * ) echo -e "\n Please answer yes or no.  Default to using your current version [$CUR_K3D]";;
        esac
    fi
fi
    

echo "Creating k3d cluster"
k3d create --workers 4 --name greymatter --publish 30000:10808 
while [[ $(k3d get-kubeconfig --name='greymatter') != *kubeconfig.yaml ]]; do echo "echo waiting for k3d cluster to start up" && sleep 10; done
export KUBECONFIG="$(k3d get-kubeconfig --name='greymatter')"
echo "Cluster is connected"
