#!/bin/bash
set -e

# 기본 설정
SOURCE_DIR="/Users/white/Workspace/src/github.com/whitej00/rsync/dummy_data"
TARGET_USER="backup_user"
TARGET_HOST="localhost"
TARGET_BASE="/backup/dummy_data"
SSH_PORT=2222
SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no"

# 백업 실행
main() {
    local now dest backup_type last_backup rsync_opts day_of_week
    now=$(date +"%Y-%m-%d-%H-%M-%S")
    day_of_week=$(date +%u)  # 1=월요일 ... 7=일요일

    # 최근 FULL 백업 디렉토리 조회 (증분 참조용)
    last_backup=$(ssh -p "$SSH_PORT" $SSH_OPTS "$TARGET_USER@$TARGET_HOST" \
        "ls -1dt $TARGET_BASE/*-FULL 2>/dev/null | head -1" || true)

    # 요일 기준 백업 구분
    if [[ "$day_of_week" -eq 7 || -z "$last_backup" ]]; then
        backup_type="FULL"
        dest="$TARGET_BASE/$now-FULL"
        rsync_opts="-avz --delete --human-readable --stats"
        echo "📂 전체 백업 시작"
    else
        backup_type="INCREMENTAL"
        dest="$TARGET_BASE/$now-INC"
        rsync_opts="-avz --delete --human-readable --stats --link-dest=$last_backup"
        echo "📂 증분 백업 시작 (참조: $(basename "$last_backup"))"
    fi

    # rsync 수행
    echo "🚀 rsync 실행 중..."
    rsync $rsync_opts -e "ssh -p $SSH_PORT $SSH_OPTS" "$SOURCE_DIR/" "$TARGET_USER@$TARGET_HOST:$dest/"

    echo "✅ $backup_type 백업 완료: $dest"

    # latest 심볼릭 링크 갱신
    ssh -p "$SSH_PORT" $SSH_OPTS "$TARGET_USER@$TARGET_HOST" \
        "ln -sfn '$dest' '$TARGET_BASE/latest'"
    echo "✅ latest 링크 갱신 완료"
}

main "$@"