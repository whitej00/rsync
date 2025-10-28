#!/bin/bash
set -e

CONTAINER_NAME="ubuntu_rsync_target"
SSH_PORT=2222
USER_NAME="backup_user"
PASSWORD="backup1234"

# 1. 기존 컨테이너 제거
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# 2. 새 Ubuntu 컨테이너 실행
docker run -d \
  --name "$CONTAINER_NAME" \
  -p 127.0.0.1:${SSH_PORT}:22 \
  ubuntu:22.04 \
  bash -c "tail -f /dev/null"

echo "[+] Ubuntu 컨테이너 생성 완료"

# 3️. SSH + rsync 설치 및 backup 유저 생성
docker exec -it "$CONTAINER_NAME" bash -c "
  set -e
  apt-get update -y &&
  apt-get install -y openssh-server rsync tree &&
  mkdir -p /var/run/sshd /backup/dummy_data &&
  useradd -m -s /bin/bash ${USER_NAME} &&
  echo '${USER_NAME}:${PASSWORD}' | chpasswd &&
  ssh-keygen -A
  /usr/sbin/sshd -D & 
  chown -R backup_user:backup_user /backup
"

echo "[+] SSH 서버 및 사용자 설정 완료"

echo ""
echo "이제 아래 명령으로 공개키 등록하세요"
echo "ssh-copy-id -i ~/.ssh/id_ed25519.pub -p ${SSH_PORT} ${USER_NAME}@localhost"
echo ""
echo ""
echo "에러 발생시, 컨테이너 접속 후 sshd 백그라운드 실행"
echo ""
echo ""
echo "등록 후 테스트:"
echo "ssh -p ${SSH_PORT} ${USER_NAME}@localhost"
echo ""