# XDS Installation Periodical Automation

XDS 소프트웨어의 6개월 라이선스 만료 주기에 맞춰, 최신 버전을 자동으로 다운로드하고 설치하는 스크립트입니다.

## 주요 기능
* **자동 다운로드**: 최신 `XDS-gfortran_Linux_x86_64.tar.gz` 파일을 `xds.mr.mpg.de`에서 HTTPS로 다운로드합니다.
* **안전한 설치**: 임시 디렉토리에서 작업을 수행하고, 성공 시에만 실제 경로(`/pal/lib/pal-soft/bin`)로 이동합니다.
* **유연한 디렉토리 감지**: 압축 해제 후 생성되는 디렉토리 명칭(예: `XDS-INTEL64...` 또는 `XDS-gfortran...`)을 자동으로 감지하여 처리합니다.
* **검증 로직**: 설치 후 실제 바이너리를 실행하여 라이선스 만료일(`licensed until`)이 갱신되었는지 확인합니다.
* **로깅**: `/var/log/xds_update.log`에 모든 진행 상황을 기록합니다.

## 설치 방법 (Installation)

1.  스크립트를 시스템 경로로 복사합니다.
    ```bash
    sudo cp update_xds.sh /usr/local/bin/
    sudo chmod +x /usr/local/bin/update_xds.sh
    ```

2.  로그 파일 권한을 설정합니다.
    ```bash
    sudo touch /var/log/xds_update.log
    sudo chown pal:pal_users /var/log/xds_update.log
    ```

## 자동화 설정 (Crontab)

라이선스 만료일(보통 8월 1일 등)을 고려하여 매년 **1월 1일**과 **7월 1일** 새벽 4시 30분에 실행합니다.

```bash
# Crontab 등록 (crontab -e)
30 4 1 1,7 * /usr/local/bin/update_xds.sh
```

## 기여 (Contribution)

이 코드는 Gemini와 Jules를 사용하여 작성되었습니다.
