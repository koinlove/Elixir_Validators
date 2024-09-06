## 엘릭서 노드 프로그램을 깔아보아요~
를 하기 전에
## 콘타보 로그인은 하셨나요? 콘타보 로그인 하고 진행해야 합니다~
터미널에 콘타보 로그인하고 진행해 주세요~ ^^ 감사합니다.

## 노드 설치 명령어
```bash
[ -f "Elixir.sh" ] && rm Elixir.sh; wget -q https://raw.githubusercontent.com/byonjuk/Elixir_Validators/main/Elixir.sh && chmod +x Elixir.sh && ./Elixir.sh
```

위에 올리면 바로 후루룩 하면서 알아서 깔린답니다.

- 주의해야 할 것들
```bash
1. 이름 넣으라는 거 < 내 귀여운 노드 이름이니까 "영문"으로 귀여운 이름 만드세요~ 내가 좋아하는 팝가수라거나..
2. 리워드 수령할 주소 넣으라는 거, 메마 EVM 주소(0x로 시작하는) 넣으면 됩니다. 본지갑도 ㄱㅊ음
3. 그 뒤로는 사이트 들어가서 하는 거니까 그닥 어려울 거 없음.
```

가이드 사진이 필요하신가요..? 실수 많이 하면 추가할게요.. 생각 좀 해 보고...

## 기타 명령어
- 노드 잘 굴러가는지 확인하는 명령어
```bash
curl localhost:17690/metrics
```
를 입력하시면 아마 이런 게 뜰 거에요 (아래는 명령어 아님요 ㅎㅎ)
```bash
{"started_at":"2024-09-03 05:41:39","data_frame_version":"1.0.1","order_proposal_version":"1.0.1","app_version":"3.1.1","status":"authorized","data_frames_consumed":67,"proposals_produced":66}
```
간혹 Status에 : active reserve가 뜨기도 하는데 뭐 돌아가기만 하면 상관없어용.

- 노드의 로그 확인하는 명령어
```bash
docker logs elixir -f -n 100
```
아니면 이거로 로그 보셔두 되구염...

- 노드에 저장된 지갑 주소 확인 명령어
```bash
cat validator_wallet.txt
```
이거 입력하면 님 지갑주소랑 그런 거 보여용

```bash
cat validator.env
```
이거 해도 보이실 거. (프라이빗 키랑 지갑이랑 기타 등등 보이실 거임.)

오류 뜨면 뵨죽이나 라나돼레이에게 톡하세욤. 그럼 20000

## 내 랭크 확인하는 방법
```bash
https://dxzenith.github.io/Elixir-Validator-Node/
```
여기 들어가서 내가 설정한 닉네임 검색하면 됩니다.

## 나 뭔가 실수했어요, 내 가상서버(VPS)에서 Elixir_Validator Node를 삭제하고 싶어요.
```bash
docker ps -a | grep elixir | awk '{print $1}' | xargs docker stop && docker ps -a | grep elixir | awk '{print $1}' | xargs docker rm && docker rmi `docker images | awk '$1 ~ /elixirprotocol/ {print $1, $3}'` && sudo apt-get remove node.js && sudo apt-get remove npm && sudo rm -rf /usr/local/bin/npm /usr/local/share/man/man1/node* /usr/local/lib/dtrace/node.d ~/.npm ~/.node-gyp /opt/local/bin/node /opt/local/include/node /opt/local/lib/node_modules && sudo rm -rf /usr/local/lib/node* && sudo rm -rf /usr/local/include/node* && sudo rm -rf /usr/local/bin/node*
```

(한 줄입니다) 입력한 후에

```bash
rm validator_wallet.txt && rm validator.env && rm generate_wallet.js
```

입력해서 깔끔하게 지워주기

## 다시 재설치 하려면 
```bash
[ -f "Elixir.sh" ] && rm Elixir.sh; wget -q https://raw.githubusercontent.com/byonjuk/Elixir_Validators/main/Elixir.sh && chmod +x Elixir.sh && ./Elixir.sh
```
넣으시면 됩니다~ ㅎㅎ
