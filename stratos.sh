#!/bin/bash
clear
echo ""
echo "Wait ..."
sleep 3
clear
       
echo -e "\033[0;35m"
echo "    :::     :::::::::  :::::::::      :::     ::::    ::::  :::::::::: "; 
echo "  :+: :+:   :+:    :+: :+:    :+:   :+: :+:   +:+:+: :+:+:+ :+:        ";
echo " +:+   +:+  +:+    +:+ +:+    +:+  +:+   +:+  +:+ +:+:+ +:+ +:+        ";
echo "+#++:++#++: +#++:++#+  +#++:++#:  +#++:++#++: +#+  +:+  +#+ +#++:++#   ";
echo "+#+     +#+ +#+        +#+    +#+ +#+     +#+ +#+       +#+ +#+        ";
echo "#+#     #+# #+#        #+#    #+# #+#     #+# #+#       #+# #+#        ";
echo "###     ### ###        ###    ### ###     ### ###       ### ########## ";
echo -e "\e[0m"
       
                                                               

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi

if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export STRATOS_CHAIN_ID=tropos-5" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$STRATOS_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$STRATOS_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y
sudo apt-get install tar curl ufw jq make clang pkg-config libssl-dev build-essential git jq expect -y

# install go
if ! [ -x "$(command -v go)" ]; then
    ver="1.19.4"
    cd $HOME
    wget "https://go.dev/dl/go1.19.4.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
    rm "go$ver.linux-amd64.tar.gz"
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
    source ~/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download and build binaries
cd ~
wget https://github.com/stratosnet/stratos-chain/releases/download/v0.9.0/stchaind

# Make sure the file can be executed
chmod +x stchaind

# export profile
echo 'export PATH="$HOME:$PATH"' >> ~/.profile
source ~/.profile

# Build the extracted source code
git clone https://github.com/stratosnet/stratos-chain.git
cd stratos-chain
git checkout tags/v0.9.0
make build

# install
make install

# init
stchaind init $NODENAME

# download genesis and addrbook
wget https://raw.githubusercontent.com/stratosnet/stratos-chain-testnet/main/genesis.json
wget https://raw.githubusercontent.com/stratosnet/stratos-chain-testnet/main/config.toml

# move or replace the genesis file
mv config.toml $HOME/.stchaind/config/
mv genesis.json $HOME/.stchaind/config/


# run the node
cd
./stchaind start 2>&1 >> chain.log & 

echo '================ KELAR CUY, SILAHKAN TUNGGU SAMPE SYNC UNTUK LANJUT ===================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u stratosd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mstchaind status 2>&1 | jq .SyncInfo\e[0m"
