#!/bin/bash

# 기본 설정
BASE_DIR="./dummy_data"
PARENT_DIR_COUNT=$((2 * 2))   # 4
CHILD_DIR_COUNT=$((2 * 2))    # 4
FILE_COUNT=$((2 * 2))         # 4
TOTAL_FILES_COUNT=$((PARENT_DIR_COUNT * CHILD_DIR_COUNT * FILE_COUNT))

FILE_SIZE_MB=1  # 각 파일 1MB
FILE_SIZE_BYTES=$((FILE_SIZE_MB * 1024 * 1024))

echo "=== 더미 데이터 생성 시작 ==="
echo "총 크기: $((TOTAL_FILES_COUNT * FILE_SIZE_MB)) MB"
echo "총 파일 개수: $TOTAL_FILES_COUNT 개"
echo "각 파일 크기: $FILE_SIZE_MB MB"
echo ""

# 기존 디렉토리 삭제 및 재생성
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"

# 부모 디렉토리 생성
for ((main_dir=1; main_dir<=PARENT_DIR_COUNT; main_dir++)); do
    PARENT_DIR_NAME="parent_${main_dir}"
    
    # 각 부모 디렉토리 안에 자식 디렉토리 생성
    for ((child_dir=1; child_dir<=CHILD_DIR_COUNT; child_dir++)); do
        CHILD_DIR_NAME="child_${child_dir}"
        FULL_PATH="$BASE_DIR/$PARENT_DIR_NAME/$CHILD_DIR_NAME"
        mkdir -p "$FULL_PATH"
        
        # 각 자식 디렉토리 안에 파일 생성
        for ((file_num=1; file_num<=FILE_COUNT; file_num++)); do
            FILE_NAME="file_${file_num}.dat"
            FILE_PATH="$FULL_PATH/$FILE_NAME"
            
            # 1MB 파일 생성 (랜덤 데이터)
            dd if=/dev/urandom of="$FILE_PATH" bs="$FILE_SIZE_BYTES" count=1 2>/dev/null
            
            # 파일에 식별 정보 추가
            {
                echo ""
                echo "=== FILE INFO ==="
                echo "Main Directory: $PARENT_DIR_NAME"
                echo "Sub Directory: $CHILD_DIR_NAME"
                echo "File Name: $FILE_NAME"
                echo "Created: $(date)"
                echo "================"
            } >> "$FILE_PATH"
            
            printf "    생성 완료: %s\n" "$FILE_NAME"
        done
    done
    echo ""
done

echo "=== 더미 데이터 생성 완료 ==="
echo ""

# 결과 확인
echo "=== 구조 확인 ==="
if command -v tree >/dev/null 2>&1; then
    tree "$BASE_DIR"
else
    find "$BASE_DIR" -type d | sort
fi

echo ""
echo "=== 크기 확인 ==="
du -sh "$BASE_DIR"
du -sh "$BASE_DIR"/*

echo ""
echo "=== 파일 개수 확인 ==="
echo "파일 개수: $(find "$BASE_DIR" -type f | wc -l)"