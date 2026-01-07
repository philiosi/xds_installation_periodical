#!/bin/bash

# ==============================================================================
# Script Name: update_xds.sh
# Description: XDS 소프트웨어 자동 업데이트 (파일명 변경 대응 버전)
# ==============================================================================

set -euo pipefail

# 1. 설정 (최신 URL 반영)
# XDS 최신 버전 (gfortran 빌드) URL
SOURCE_URL="https://xds.mr.mpg.de/XDS-gfortran_Linux_x86_64.tar.gz"
TARGET_DIR="/pal/lib/pal-soft/bin"
OWNER_USER="pal"
OWNER_GROUP="pal_users"
LOG_FILE="/var/log/xds_update.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

TEMP_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TEMP_DIR"
    log "임시 작업 파일이 삭제되었습니다."
}
trap cleanup EXIT

log "=== XDS 업데이트 프로세스 시작 ==="

# 2. 다운로드 (파일명 불일치 방지)
# 서버의 파일명이 무엇이든 'xds_pkg.tar.gz'라는 고정된 이름으로 저장합니다.
log "다운로드 시작: $SOURCE_URL"
if wget -q -O "$TEMP_DIR/xds_pkg.tar.gz" "$SOURCE_URL"; then
    log "다운로드 완료."
else
    log "치명적 오류: 파일 다운로드 실패. URL을 확인하세요."
    exit 1
fi

# 3. 압축 해제
log "압축 해제 중..."
# 고정된 파일명을 사용하므로 이전과 같은 'No such file' 에러가 발생하지 않습니다.
tar xzf "$TEMP_DIR/xds_pkg.tar.gz" -C "$TEMP_DIR"

# 4. 폴더 자동 감지 (핵심 수정 사항)
# 압축 해제 후 생성된 디렉토리 이름이 XDS-INTEL64... 이든 XDS-gfortran... 이든 상관없이 자동으로 찾습니다.
EXTRACTED_DIR=$(find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [ -z "$EXTRACTED_DIR" ]; then
    log "치명적 오류: 압축 해제된 디렉토리를 찾을 수 없습니다."
    exit 1
fi

log "감지된 소스 디렉토리: $(basename "$EXTRACTED_DIR")"

# 5. 권한 변경
log "권한 변경 중 ($OWNER_USER:$OWNER_GROUP)..."
chown -R "$OWNER_USER:$OWNER_GROUP" "$EXTRACTED_DIR"

# 6. 파일 설치 (이동)
log "파일 설치(이동) 중..."
if [ -d "$TARGET_DIR" ]; then
    # 기존 파일 덮어쓰기
    mv -f "$EXTRACTED_DIR/"* "$TARGET_DIR/"
    log "파일 이동 완료."
else
    log "치명적 오류: 타겟 디렉토리($TARGET_DIR)가 존재하지 않습니다."
    exit 1
fi

# 7. 설치 검증
log "설치 검증(라이선스 확인) 시작..."
VERIFY_OUTPUT=$("$TARGET_DIR/xds" 2>&1 | head -n 15)

if echo "$VERIFY_OUTPUT" | grep -q "licensed until"; then
    VALID_DATE=$(echo "$VERIFY_OUTPUT" | grep "licensed until" | awk -F'until ' '{print $2}' | awk '{print $1}')
    log "✅ 검증 성공: XDS 라이선스가 갱신되었습니다. (유효 만료일: $VALID_DATE)"
else
    log "⚠️  경고: 설치는 완료되었으나 라이선스 날짜를 확인할 수 없습니다."
fi

log "=== XDS 업데이트가 성공적으로 완료되었습니다 ==="