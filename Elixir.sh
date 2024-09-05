#!/bin/bash

BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
NC='\033[0m'

# Install KOREAN
sudo apt-get install language-pack-ko -y

sudo locale-gen ko_KR.UTF-8

sudo update-locale LANG=ko_KR.UTF-8 LC_MESSAGES=POSIX


echo -e "${GREEN}한국어 설치 완료.${NC}"

command_exists() {
    command -v "$1" &> /dev/null
}

if command_exists nvm; then
    echo -e "${GREEN}NVM is already installed.${NC}"
else
    echo -e "${YELLOW}Installing NVM...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

if command_exists node; then
    echo -e "${GREEN}Node.js is already installed: $(node -v)${NC}"
else
    echo -e "${YELLOW}Installing Node.js...${NC}"
    nvm install node
    nvm use node
    echo -e "${GREEN}Node.js installed: $(node -v)${NC}"
fi

echo ""

echo -e "${BOLD}${CYAN}Checking for ethers package installation...${NC}"
if ! npm list ethers &> /dev/null; then
    echo -e "${RED}ethers package not found. Installing ethers package...${NC}"
    npm install ethers
    echo -e "${GREEN}ethers package installed successfully.${NC}"
else
    echo -e "${GREEN}ethers package is already installed.${NC}"
fi


echo -e "${BOLD}${CYAN}Checking for Docker installation...${NC}"
if ! command_exists docker; then
    echo -e "${RED}Docker is not installed. Installing Docker...${NC}"
    sudo apt update && sudo apt install -y curl net-tools
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    echo -e "${GREEN}Docker installed successfully.${NC}"
else
    echo -e "${GREEN}Docker is already installed.${NC}"
fi

echo -e "${BOLD}${CYAN}Generating Validator wallet...${NC}"
cat << 'EOF' > generate_wallet.js
const { Wallet } = require('ethers');
const fs = require('fs');

const wallet = Wallet.createRandom();
const mnemonic = wallet.mnemonic.phrase;
const address = wallet.address;
const privateKey = wallet.privateKey;

const walletData = `
Mnemonic: ${mnemonic}
Address: ${address}
Private Key: ${privateKey}
`;

const filePath = 'validator_wallet.txt';
fs.writeFileSync(filePath, walletData);

console.log('');
console.log('Validator Wallet Mnemonic Phrase:', mnemonic);
console.log('Validator Wallet Address:', address);
console.log('Validator Wallet Private Key:', privateKey);
console.log('\x1B[32mWallet credentials saved to \x1b[35m validator_wallet.txt\x1B[0m');
EOF

node generate_wallet.js
echo ""

ENV_FILE="validator.env"

echo -e "${BOLD}${CYAN}Creating environment variable file: ${ENV_FILE}${NC}"
echo "ENV=testnet-3" > $ENV_FILE
IP_ADDRESS=$(curl -s ifconfig.me)
echo "STRATEGY_EXECUTOR_IP_ADDRESS=$IP_ADDRESS" >> $ENV_FILE
echo ""

read -p "님이 원하는 이름 박아 넣으세용 : " DISPLAY_NAME
echo "STRATEGY_EXECUTOR_DISPLAY_NAME=$DISPLAY_NAME" >> $ENV_FILE

read -p "노드 채굴 리워드 받을 주소 입력하삼(메인지갑 넣으세요): " BENEFICIARY
echo "STRATEGY_EXECUTOR_BENEFICIARY=$BENEFICIARY" >> $ENV_FILE
echo ""
PRIVATE_KEY=$(grep "Private Key:" validator_wallet.txt | awk -F': ' '{print $2}' | sed 's/^0x//')
VALIDATOR_ADDRESS=$(grep "Address:" validator_wallet.txt | awk -F': ' '{print $2}')
echo "SIGNER_PRIVATE_KEY=$PRIVATE_KEY" >> $ENV_FILE

echo ""
echo -e "${BOLD}${CYAN}The $ENV_FILE file has been created with the following contents:${NC}"
cat $ENV_FILE
echo ""

echo -e "${BOLD}${YELLOW}1.방문하세요: https://testnet-3.elixir.xyz/ (CTRL 누른 상태에서 마우스 클릭하면 들어가짐).${NC}"
echo -e "${BOLD}${YELLOW}2.위 사이트에서 세폴리아 이더가 있는 지갑으로 로그인하세요(방금 생성한 지갑 입력하라는 거 아님.).${NC}"
echo -e "${BOLD}${YELLOW}2-1.만약 지갑에 이더가 없으면 톡방에 세폴리아 이더 어디서 받냐고 물어보셈.${NC}"
echo -e "${BOLD}${YELLOW}3.'MINT 1,000 MOCK' 클릭해서 토큰 받기.${NC}"
echo -e "${BOLD}${YELLOW}4.토큰 민트 완료했으면 바로 밑에 있는 Stake 칸에 MAX 누른 다음에 approve 누르고 STAKE 한 번 더 클릭하기.${NC}"
echo -e "${BOLD}${YELLOW}5.밑에 custom validator라는 버튼 클릭,그리고 방금 받은 Validator address 입력하삼. 님의 validator 지갑 address : $VALIDATOR_ADDRESS for delegation${NC}"
echo ""

read -p "위의 스텝들 다 완료 하셨나용?? (y/n): " response
if [[ "$response" =~ ^[yY]$ ]]; then
    echo -e "${BOLD}${CYAN}Pulling Elixir Protocol Validator Image...${NC}"
    docker pull elixirprotocol/validator:v3
else
    echo -e "${BOLD}${RED}미친년. 씨발 n<< 그냥 장식으로 쳐 달았는데 이걸 왜 쳐 누름? 미친년인가 넌 평생 가난하게 살 거야 에드 정산 하나도 못 받을 거고 니가 하는 에드작 다 쳐망할 거고 니가 돌리는 노드 죄다 좆망할 거고 니 통장에 -잔고만 쌓일 거고 빚도 5000만원 생길 듯 하등 쓸모없는년.{NC}"
    echo -e "${BOLD}${YELLOW}시발다시해봐미친년아.${NC}"
	echo -e "${BOLD}${YELLOW}1.방문하세요: https://testnet-3.elixir.xyz/ (CTRL 누른 상태에서 마우스 클릭하면 들어가짐).${NC}"
	echo -e "${BOLD}${YELLOW}2.사이트 들어가서 세폴리아 이더가 있는 지갑으로 CONNECT하세요(방금 생성한 지갑 입력하라는 거 아님.).${NC}"
    echo -e "${BOLD}${YELLOW}2-1.만약 지갑에 이더가 없으면 톡방에 세폴리아 이더 어디서 받냐고 물어보셈.${NC}"
    echo -e "${BOLD}${YELLOW}3.'MINT 1,000 MOCK' 클릭해서 토큰 받기.${NC}"
	echo -e "${BOLD}${YELLOW}4.토큰 민트 완료했으면 바로 밑에 있는 Stake 칸에 MAX 누른 다음에 approve 누르고 STAKE 한 번 더 클릭하기.${NC}"
	echo -e "${BOLD}${YELLOW}5.밑에 custom validator라는 버튼 클릭,그리고 방금 받은 Validator address 입력하삼. 님의 validator 지갑 address : $VALIDATOR_ADDRESS for delegation${NC}"
	read -p "이번엔 진짜 완료하셨나욤? (y/n): " daedap
	if [[ "$daedap" =~ ^[yY]$ ]]; then
		echo -e "${BOLD}${CYAN}Pulling Elixir Protocol Validator Image...${NC}"
		docker pull elixirprotocol/validator:v3
	else
		echo -e "$BOLD}${RED}걍 죽어 이 씨발년아${NC}"
		exit 1
	fi
fi

echo ""
echo -e "${BOLD}${CYAN}Running Docker...${NC}"
docker run -d --env-file validator.env --name elixir -p 17690:17690 --restart unless-stopped elixirprotocol/validator:v3
echo ""
echo -e "${BOLD}${CYAN}Elixir Validator 노드 설치 완료. 이제 꺼져 씨발.${NC}"
