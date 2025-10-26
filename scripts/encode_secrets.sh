#!/bin/bash

# GitHub Secrets用のファイルをBase64エンコードするスクリプト
# 使用方法: ./scripts/encode_secrets.sh

set -e

echo "======================================"
echo "GitHub Secrets エンコーダー"
echo "======================================"
echo ""

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function encode_certificate() {
    echo -e "${YELLOW}📜 署名証明書（.p12）のエンコード${NC}"
    echo ""
    
    read -p "証明書ファイルのパス (例: ~/Desktop/certificate.p12): " cert_path
    
    if [ ! -f "$cert_path" ]; then
        echo -e "${RED}エラー: ファイルが見つかりません${NC}"
        return
    fi
    
    echo ""
    echo -e "${GREEN}BUILD_CERTIFICATE_BASE64 の値:${NC}"
    echo "-----------------------------------"
    base64 -i "$cert_path"
    echo "-----------------------------------"
    echo ""
    echo "💾 上記の値を BUILD_CERTIFICATE_BASE64 に登録してください"
    echo ""
}

function encode_provisioning_profile() {
    echo -e "${YELLOW}📱 プロビジョニングプロファイルのエンコード${NC}"
    echo ""
    
    read -p "プロファイルファイルのパス (例: ~/Desktop/YourApp.mobileprovision): " profile_path
    
    if [ ! -f "$profile_path" ]; then
        echo -e "${RED}エラー: ファイルが見つかりません${NC}"
        return
    fi
    
    echo ""
    echo -e "${GREEN}BUILD_PROVISION_PROFILE_BASE64 の値:${NC}"
    echo "-----------------------------------"
    base64 -i "$profile_path"
    echo "-----------------------------------"
    echo ""
    echo "💾 上記の値を BUILD_PROVISION_PROFILE_BASE64 に登録してください"
    echo ""
}

function show_env_template() {
    echo -e "${YELLOW}📋 .env ファイルのテンプレート${NC}"
    echo ""
    echo "以下の内容を .env ファイルに記入してください："
    echo ""
    cat << 'EOF'
# Android Firebase設定
ANDROID_API_KEY=
ANDROID_APP_ID=
ANDROID_MESSAGING_SENDER_ID=
ANDROID_PROJECT_ID=
ANDROID_STORAGE_BUCKET=

# iOS Firebase設定
IOS_API_KEY=
IOS_APP_ID=
IOS_MESSAGING_SENDER_ID=
IOS_PROJECT_ID=
IOS_STORAGE_BUCKET=
IOS_BUNDLE_ID=
EOF
    echo ""
    echo "💡 各値はFirebaseコンソール > プロジェクト設定から取得できます"
    echo ""
}

function verify_secrets() {
    echo -e "${YELLOW}✅ 必要なSecretsのチェックリスト${NC}"
    echo ""
    echo "以下のSecretsがGitHubに登録されているか確認してください："
    echo ""
    echo "【Firebase関連】"
    echo "  □ ANDROID_API_KEY"
    echo "  □ ANDROID_APP_ID"
    echo "  □ ANDROID_MESSAGING_SENDER_ID"
    echo "  □ ANDROID_PROJECT_ID"
    echo "  □ ANDROID_STORAGE_BUCKET"
    echo "  □ IOS_API_KEY"
    echo "  □ IOS_APP_ID"
    echo "  □ IOS_MESSAGING_SENDER_ID"
    echo "  □ IOS_PROJECT_ID"
    echo "  □ IOS_STORAGE_BUCKET"
    echo "  □ IOS_BUNDLE_ID"
    echo ""
    echo "【Apple証明書関連】"
    echo "  □ BUILD_CERTIFICATE_BASE64"
    echo "  □ P12_PASSWORD"
    echo "  □ BUILD_PROVISION_PROFILE_BASE64"
    echo "  □ KEYCHAIN_PASSWORD"
    echo ""
    echo "【App Store Connect関連】"
    echo "  □ APPLE_ID"
    echo "  □ APP_SPECIFIC_PASSWORD"
    echo "  □ TEAM_ID"
    echo ""
}

function generate_keychain_password() {
    echo -e "${YELLOW}🔐 キーチェーンパスワードの生成${NC}"
    echo ""
    password=$(openssl rand -base64 32)
    echo -e "${GREEN}生成されたパスワード:${NC}"
    echo "$password"
    echo ""
    echo "💾 上記の値を KEYCHAIN_PASSWORD に登録してください"
    echo ""
}

# メインメニュー
while true; do
    echo "何をしますか？"
    echo ""
    echo "1) 署名証明書（.p12）をBase64エンコード"
    echo "2) プロビジョニングプロファイルをBase64エンコード"
    echo "3) .envファイルのテンプレートを表示"
    echo "4) キーチェーンパスワードを生成"
    echo "5) Secretsチェックリストを表示"
    echo "6) 終了"
    echo ""
    read -p "選択 (1-6): " choice
    echo ""
    
    case $choice in
        1)
            encode_certificate
            ;;
        2)
            encode_provisioning_profile
            ;;
        3)
            show_env_template
            ;;
        4)
            generate_keychain_password
            ;;
        5)
            verify_secrets
            ;;
        6)
            echo "終了します"
            exit 0
            ;;
        *)
            echo -e "${RED}無効な選択です${NC}"
            echo ""
            ;;
    esac
done

