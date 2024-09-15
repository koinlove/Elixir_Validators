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

#노드 설치 명령어 모음집
install_env_and_ELIXIR_PROTOCOL() {
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
echo -e "${BOLD}${YELLOW}4.토큰 민트 완료했으면 바로 밑에 있는 Stake 칸에 MAX 누른 다음에 approve 누르고 한 번 더 클릭하기.${NC}"
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
	echo -e "${BOLD}${YELLOW}4.토큰 민트 완료했으면 바로 밑에 있는 Stake 칸에 MAX 누른 다음에 approve 누르고 한 번 더 클릭하기.${NC}"
	echo -e "${BOLD}${YELLOW}5.밑에 custom validator라는 버튼 클릭,그리고 방금 받은 Validator address 입력하삼. 님의 validator 지갑 address : $VALIDATOR_ADDRESS for delegation${NC}"
	read -p "이번엔 진짜 완료하셨나욤? (y/n): " daedap
	if [[ "$daedap" =~ ^[yY]$ ]]; then
		echo -e "${BOLD}${CYAN}Pulling Elixir Protocol Validator Image...${NC}"
		docker pull elixirprotocol/validator:v3
	else
		echo -e "{$BOLD}${RED}걍 죽어 이 씨발년아${NC}"
		exit 1
	fi
fi

echo ""
echo -e "${BOLD}${CYAN}Running Docker...${NC}"
docker run -d --env-file validator.env --name elixir -p 17690:17690 --restart unless-stopped elixirprotocol/validator:v3
echo ""
echo -e "${BOLD}${CYAN}Elixir Validator 노드 설치 완료. 이제 꺼져 씨발.${NC}"
}

#노드 재시작 명령어
restart_ELIXIR_PROTOCOL() {
echo -e "${BLUE}docker restart elixir${NC}"
docker restart elixir

echo -e "${BOLD}${CYAN}Elixir Validator 노드 재시작 완료. 이제 꺼져 씨발.${NC}"
}

#노드 업데이트 명령어
update_ELIXIR_PROTOCOL() {
echo -e "${BLUE}도커 멈췄다 죽였다 지우는 중...${NC}"
docker stop elixir
docker kill elixir 
docker rm elixir

echo -e "${BLUE}removing docker image... |${NC}"
docker rmi `docker images | awk '$1 ~ /elixirprotocol/ {print $1, $3}'`

echo -e "${BLUE}docker pull elixirprotocol/validator:v3${NC}"
docker pull elixirprotocol/validator:v3

echo -e "${BLUE}docker run{NC}"
docker run -d --env-file validator.env --name elixir -p 17690:17690 --restart unless-stopped elixirprotocol/validator:v3

echo -e "${BOLD}${CYAN}Elixir Validator 노드 업데이트 완료. 이제 꺼져 씨발.${NC}"
}

#노드 삭제 명령어
uninstall_ELIXIR_PROTOCOL() {

echo -e "${BLUE}엘릭서 프로토콜 도커들 싹 다 없애는 중 ㅎㅎ{NC}"
docker ps -a | grep elixir | awk '{print $1}' | xargs docker stop
docker ps -a | grep elixir | awk '{print $1}' | xargs docker rm
docker rmi `docker images | awk '$1 ~ /elixirprotocol/ {print $1, $3}'`

echo -e "${BLUE}관련 파일들 없애는 중!{NC}"
sudo rm -rf validator_wallet.txt
sudo rm -rf rm validator.env
sudo rm -rf generate_wallet.js

echo -e "${BLUE}sudo apt-get remove node.js && npm{NC}"
sudo apt-get remove node.js
sudo apt-get remove npm

echo -e "${BLUE}node.js에 남은 파일들 다 지우는 중...{NC}"
sudo rm -rf /usr/local/bin/npm /usr/local/share/man/man1/node* /usr/local/lib/dtrace/node.d ~/.npm ~/.node-gyp /opt/local/bin/node /opt/local/include/node /opt/local/lib/node_modules
sudo rm -rf /usr/local/lib/node*
sudo rm -rf /usr/local/include/node*
sudo rm -rf /usr/local/bin/node*
sudo rm -rf elixirprotocol

echo -e "${BOLD}${CYAN}Elixir Validator 노드 지우기 완료. 이제 꺼져 씨발.${NC}"
}

# 메인 메뉴
echo && echo -e "${BOLD}${Red}ELIXIR PROTOCOL 자동 설치 스크립트${NC} by 비욘세제발죽어
 ${Blue}원하는 거 고르시고 실행하시고 그러세효. ${NC}
 ———————————————————————
 ${GREEN} 1. 기본파일 설치 및 ELIXIR PROTOCOL 설치 ${NC}
 ${GREEN} 2. ELIXIR PROTOCOL 재시작 ${NC}
 ${GREEN} 3. ELIXIR PROTOCOL 업데이트 ${NC}
 ${GREEN} 4. ELIXIR PROTOCOL만 삭제하고 싶어요ㅠ ${NC}
 ———————————————————————" && echo

# 사용자 입력 대기
read -e -p " 어떤 과정을 하고 싶으신가요? 위 항목을 참고해 숫자를 입력해 주세요: " num
case "$num" in
1)
    install_env_and_ELIXIR_PROTOCOL
    ;;
2)
    restart_ELIXIR_PROTOCOL
    ;;
3)
    update_ELIXIR_PROTOCOL
    ;;
4)
    uninstall_ELIXIR_PROTOCOL
    ;;
*)
    echo -e "${Red_font_prefix}숫자 못 읽음? 진짜 병신이니 눈깔 삐엇니? 죽어 그냥 자살해 시발 1~5 하나 제대로 입력 못하는 주제에 무슨 노드를 쳐 돌리고~ 에드작을 한다 그러고~ 시발 서당개도 3년이면 풍월을 읊는다는데 만물의 영장이라는 게 시발 에드작을 반년 가까이 하고도 시발 숫자 하나 입력하는 법을 모르고 개 씨발 병신 좆버러지 같은 년 에휴 왜 사니? 여긴 왜 들어왔니? 코인이 하고 싶긴 하니? 너 평소에 하라는 에드작은 다 열심히 하고 있니? 안일하게 살지마 세상에 돈 벌기 쉬운 게 어딨어 다들 피땀흘려서 열심히 돈 버는데 지는 이거 하기 싫다고 편하게 딸깍이나 하러 와서는 숫자 하나 제대로 입력 못하고 내 복창이 터진다 씨발 에휴 병신 금수련아 짐승련아 대체 왜 그러고 사니 존재 자체가 인류의 공해야 너는 그냥 에휴 긴말 안 할게 죽어라 걍 에휴 ㅄ;;;;;;;;${Font_color_suffix}"
    ;;
esac
