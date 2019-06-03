#!/bin/bash

# setup
rm -f ci/jenkins-helm-package-temp.yaml
debug=false
print_usage() {
    printf "This script will set the jenkins pipeline to build whatever branch you specify."
}

echo "Would you like to reset the build branch to master? (y/n)"
read resp1
if [ $resp1 = "y" ] || [ $resp1 = "Y" ] || [ $resp1 = "Yes" ] || [ $resp1 = "yes" ]
then
    sed < ci/jenkins-helm-package.yaml > ci/jenkins-helm-package-temp.yaml \
        -e "s/SETBRANCH/master/"

else
    current_branch="$(git branch | grep \* | cut -d ' ' -f2)"
    echo "Do you want jenkins to build branch: ${current_branch}?  (y/n)"
    read resp2
    if [ $resp2 = "y" ] || [ $resp2 = "Y" ] || [ $resp2 = "Yes" ] || [ $resp2 = "yes" ]
    then
        # sed change-build-branch.yaml
        sed < ci/jenkins-helm-package.yaml > ci/jenkins-helm-package-temp.yaml \
            -e "s/SETBRANCH/\"${current_branch}\"/g"
    else
        echo "What branch would you like to set it to?"
        read resp3
        # Check if the branch from resp3 is real and in the repo
        
        git fetch --all
        if [ "$(git branch --list ${resp3} )" ]
        then
            echo "This branch (${resp3}) exists.  Setting up the jenkins yaml"
            sed < ci/jenkins-helm-package.yaml > ci/jenkins-helm-package-temp.yaml \
            -e "s/SETBRANCH/\"${resp3}\"/g"
        else
            echo "Branch ${resp3} does not exist... exiting(2)"
            print_usage
            exit 2
        fi 
       
        # sed it to resp3
        
    fi
fi

oc project jenkins
oc apply -f ci/jenkins-helm-package-temp.yaml

rm ci/jenkins-helm-package-temp.yaml
