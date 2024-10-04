#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# チェックするネットワークインターフェース
IFACE="eno1"

# Webhook URLを設定
WEBHOOK_URL="https://discord.com/api/webhooks/"


PAYLOAD=$(cat <<EOF
{
    "embeds": [
        {
            "title": "PC",
            "description": "NICデバイスを再起動しました",
            "color": 10038562
        }
    ]
}
EOF
)

# リトライカウントの初期値
MAX_RETRIES=3
RETRY_COUNT=0

# ethtool でインターフェースのリンクステータスを取得
check_link_status() {
    ethtool $IFACE | grep "Link detected" | awk '{print $3}'
}

# リンクがダウンしている場合にインターフェースを再起動
while [ "$RETRY_COUNT" -lt "$MAX_RETRIES" ]; do
    LINK_STATUS=$(check_link_status)
    
    if [ "$LINK_STATUS" = "no" ]; then
        echo "$(date) - $IFACE: Link is down. Attempting to restart interface... (Attempt $((RETRY_COUNT+1)))"
        ip link set $IFACE down
        sleep 2
        ip link set $IFACE up
        sleep 5  # インターフェースが再起動して安定するのを待つ
        curl --connect-timeout 10 -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"
    else
        echo "$(date) - $IFACE: Link is up."
        exit 0  # リンクが回復したのでスクリプトを終了
    fi

    RETRY_COUNT=$((RETRY_COUNT+1))
done

# リンクが回復しなかった場合、システムを再起動
echo "$(date) - $IFACE: Link is still down after $MAX_RETRIES attempts. Rebooting the system..."
/sbin/reboot
