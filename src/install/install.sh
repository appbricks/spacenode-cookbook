#!/bin/bash

WHITE='\033[1;37m'
BLACK='\033[0;30m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
DARK_GRAY='\033[1;30m'
BROWN_ORANGE='\033[0;33m'
LIGHT_GRAY='\033[0;37m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
NC='\033[0m' # No Color

BOLD='\033[1m'
NORMAL='\033[22m'
DIM='\033[2m'

# Check if docker exists
which docker >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo -e "${RED}\nERROR! Unable to find Docker in the system path.\n" 
  echo -e "${GREEN}Please follow the instructions at: "
  echo -e "- ${BLUE}https://www.docker.com/products/docker-desktop\n" 
  echo -e "${GREEN}to download and install the Docker the desktop app.${NC}"
  exit 1
fi

# Remove existing vpn-server container images
echo -e "${GREEN}\nRemoving any download VS CLI container images...${NC}"
docker images \
  | awk '/appbricks\/vpn-server/{ print "appbricks/vpn-server:"$2 }' \
  | xargs docker rmi 2>&1 >/dev/null

docker_alias="alias vs='docker run --privileged --rm -p 4495:4495 -p 4495:4495/udp -v \$(pwd)/:/vpn -it appbricks/vpn-server:latest'"

case $SHELL in
  /bin/sh)
    profile_file=$HOME/.profile
    ;;
  /bin/bash)
    profile_file=$HOME/.bashrc
    ;;
  /bin/ksh)
    profile_file=$HOME/.kshrc
    ;;
  /bin/zsh)
    profile_file=$HOME/.zshrc
    ;;
  *)
    echo -e "${RED}\nERROR! Unable to determine shell profile to add VS CLI alias to.\n" 
    echo -e "${GREEN}Please add the following to you shell startup script: \n"
    echo -e "- ${BLUE}${docker_alias}${NC}" 
    exit 1
    ;;
esac

if [[ $(uname -s) == Darwin ]]; then
  sed_option="''"
else
  sed_option=""
fi

grep "alias vs=" $profile_file 2>&1 >/dev/null \
  && sed -i${sed_option} "s|^alias vs=.*$|${docker_alias}|" $profile_file \
  || echo -e "\n${docker_alias}" >> $profile_file

echo -e "${GREEN}\nVS CLI has been added to you shell startup profile. Run "
echo -e "'vs --help' to download CLI container image and validate.${NC}"
exec $SHELL
