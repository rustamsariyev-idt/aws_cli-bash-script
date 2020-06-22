#!/bin/bash 
# 
# This script automates the "AWS CLI" installation process all Linux/Unix distros.

# Set color variables

RED='\033[0;31m'                    # RED Color
GREEN='\033[0;32m'                  # GREEN Color
NC='\033[0m'                        # No Color

# Checking current user root or not. If user not root "please run as root". 

if [[ "$EUID" -ne 0 ]]; then
   printf "${RED}Error:${NC} Please run as "root".\n"
   exit 1;
else
   printf "${GREEN}Success:${NC} User is "root".\n"
fi


# First, we need to check our Linux/Unix distro.
# Variables 

PATH="/usr/local/bin:$PATH"                     # Adding the new "PATH"

YUM_PM="$(which yum 2>/dev/null)"               # Centos/REHL "Package Manager"
PKG_PM="$(which pkg 2>/dev/null)"               # Solaris "Package Manager" 
BREW_PM="$(which brew 2>/dev/null)"             # MacOS "Package Manager"
APT_GET_PM="$(which apt-get 2>/dev/null)"       # Ubuntu "Package Manager"
DNF_PM="$(which dnf 2>/dev/null)"               # Red Hat "Package Manager"
ZYPPER_PM="$(which zypper 2>/dev/null)"         # Suse "Package Manager"


AWS_CLI_BIN="$(which aws 2>/dev/null)"          # aws-cli executable file location check
UNZIP_STAT="$(which unzip 2>/dev/null)"         # unzip executable file location check    
AWS_CLI_VER_CK="$(/usr/local/bin/aws --version > aws_version.txt 2>&1 && grep aws-cli aws_version.txt | awk '{print $1}')"      # AWS_CLI Version check

UNZIP_PG="unzip"                  # Zip and unzip package for unzipping AWS_CLI bundle



# Function for unzip package

function UNZIP_FUNC () {
   # First, we are using "IF" statement for checking which Package Manager of the Linux/Unix distros later install unzip package.

if [[ ! -z $YUM_PM ]]; then
    yum install $UNZIP_PG  -y  > /dev/null 2>&1
 elif [[ ! -z $BREW_PM ]]; then
    brew install -y $UNZIP_PG  > /dev/null 2>&1
 elif [[ ! -z $PKG_PM ]]; then
    pkg install $UNZIP_PG -y  > /dev/null 2>&1
 elif [[ ! -z $APT_GET_PM ]]; then
    apt-get update && apt-get install $UNZIP_PG -y > /dev/null 2>&1
 elif [[ ! -z $DNF_PM ]]; then
    dnf install $UNZIP_PG -y > /dev/null 2>&1
 elif [[ ! -z $ZYPPER_PM ]]; then
    zypper install -y $UNZIP_PG  > /dev/null 2>&1
 else
    printf "${RED}Error:${NC} "unzip" package can't be able to install.\n"
    exit 1;
    set -e                                   # If exit 1 stop script execution
 fi
}



# Function for aws_cli version 1

function AWS_CLI_VER_1 () {

curl -s "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" 
unzip -o -q awscli-bundle.zip                                           
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws  > /dev/null

# Clear AWS_CLI downloaded and unzipped files.
sudo rm -rf awscli-bundle awscli-bundle.zip aws_version.txt
}


function AWS_CLI_VER_2 () {

curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"  
unzip -o -q awscliv2.zip
./aws/install -i /usr/local/aws-cli -b /usr/local/bin   > /dev/null

# Clear AWS_CLI downloaded and unzipped files.
sudo rm -rf aws awscliv2.zip aws_version.txt

}


function AWS_CLI_VER_2_MAC () {
 
curl -s "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
installer -pkg AWSCLIV2.pkg -target /


# Clear AWS_CLI downloaded file.
sudo rm -rf AWSCLIV2.pkg

}


# Checking aws-cli package available(intsalled) or not.

if [[ ! -z "${AWS_CLI_BIN}" ]]; then
   printf "${GREEN}AWS_CLI current version:${NC} ${AWS_CLI_VER_CK}\n"
   rm -rf aws_version.txt
   exit 1
   set -e # If exit 1 stop script execution
else
   printf "${RED}Error:${NC} AWS_CLI not installed.\n"
   rm -rf aws_version.txt
fi


# Checking unzip package available(intsalled) or not.

if [[ ! -z ${UNZIP_STAT} ]] ; then
   printf "${GREEN}Success:${NC} "unzip" package has been installed.\n"
else
   printf "${RED}Error:${NC} "unzip" package has not been installed.\n"
   printf "${GREEN}Starting:${NC} "unzip" package installation starting...\n"
   UNZIP_FUNC     > /dev/null 2>&1                # Function for install unzip package              
fi

# Using the "case" statement for installing the desired aws_cli version

read -p 'Please enter the desired input  AWS CLI version (ex: 1 or 2 (Notice: AWS_CLI 2 for MacOS Please enter input: "mac2")):' VERSION
case $VERSION
in
    1) printf "aws-cli-ver-1 installing starting...\n"; AWS_CLI_VER_1 ;;
    2) printf "aws-cli-ver-2 installing starting...\n"; AWS_CLI_VER_2 ;;
    mac2) printf "aws-cli-ver-2 installing starting...\n"; AWS_CLI_VER_2_MAC ;;
    *) printf "Error: AWS_CLI version not selected.\n"
       exit ;;
esac

AWS_CLI_VER_CK="$(/usr/local/bin/aws --version > aws_version.txt 2>&1 && grep aws-cli aws_version.txt | awk '{print $1}' )"      # AWS_CLI Version
printf "${GREEN}AWS_CLI new installed version:${NC} ${AWS_CLI_VER_CK}\n"
rm -rf aws_version.txt

exit 0

