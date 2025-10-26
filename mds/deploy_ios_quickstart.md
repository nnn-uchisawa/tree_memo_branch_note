# iOSデプロイ クイックスタート

このガイドは、できるだけ早くiOSデプロイを始めたい方向けの簡易版です。
詳細な説明は [deploy_ios_setup.md](./deploy_ios_setup.md) を参照してください。

## 🎯 必要なもの

- [ ] Appleデベロッパーアカウント（有料）
- [ ] Firebaseプロジェクト
- [ ] Mac（証明書エクスポート用）
- [ ] 署名証明書（Distribution Certificate）
- [ ] App Store用プロビジョニングプロファイル

---

## ⚡ 5ステップでセットアップ

### Step 1: 証明書をエクスポート（Mac）

```bash
# 1. キーチェーンアクセス.appを開く
# 2. "Apple Distribution" 証明書を右クリック → 書き出す
# 3. 形式: .p12、パスワード設定、保存

# 4. Base64エンコード
base64 -i certificate.p12 | pbcopy
# → BUILD_CERTIFICATE_BASE64 として GitHub Secrets に登録
```

### Step 2: プロビジョニングプロファイルをダウンロード

```bash
# 1. Apple Developer Portal → Profiles → ダウンロード
# 2. Base64エンコード
base64 -i YourApp.mobileprovision | pbcopy
# → BUILD_PROVISION_PROFILE_BASE64 として GitHub Secrets に登録
```

### Step 3: Firebase設定を取得

Firebaseコンソール → プロジェクト設定 → iOS から以下を取得：

- `IOS_API_KEY`
- `IOS_APP_ID`
- `IOS_MESSAGING_SENDER_ID`
- `IOS_PROJECT_ID`
- `IOS_STORAGE_BUCKET`
- `IOS_BUNDLE_ID`

（Android版も同様に取得）

### Step 4: Google Services設定ファイルを取得

**iOS:**
```bash
# ローカルにある場合、クリップボードにコピー
cat ios/Runner/GoogleService-Info.plist | pbcopy
# → GOOGLE_SERVICE_INFO_PLIST として GitHub Secrets に登録
```

**Android:**
```bash
# ローカルにある場合、クリップボードにコピー
cat android/app/google-services.json | pbcopy
# → GOOGLE_SERVICES_JSON として GitHub Secrets に登録
```

または、Firebaseコンソールからダウンロード：
- Firebaseコンソール → プロジェクト設定 → 該当アプリ → 設定ファイルをダウンロード

### Step 5: App Store Connectの認証情報

```bash
# 1. Apple ID（メールアドレス）
# → APPLE_ID として GitHub Secrets に登録

# 2. アプリ用パスワードを生成
# appleid.apple.com → サインインとセキュリティ → App用パスワード
# → APP_SPECIFIC_PASSWORD として GitHub Secrets に登録

# 3. Team IDを取得
# Apple Developer → Membership → Team ID をコピー
# → TEAM_ID として GitHub Secrets に登録
```

### Step 6: 便利スクリプトで確認

```bash
# 対話型スクリプトを実行
./scripts/encode_secrets.sh

# メニューから選択：
# - 証明書のエンコード
# - プロファイルのエンコード
# - キーチェーンパスワード生成
# - Secretsチェックリスト表示
```

---

## 📝 GitHub Secrets登録リスト

リポジトリ Settings → Secrets and variables → Actions で以下を登録：

### Firebase（11個）

```
ANDROID_API_KEY
ANDROID_APP_ID
ANDROID_MESSAGING_SENDER_ID
ANDROID_PROJECT_ID
ANDROID_STORAGE_BUCKET

IOS_API_KEY
IOS_APP_ID
IOS_MESSAGING_SENDER_ID
IOS_PROJECT_ID
IOS_STORAGE_BUCKET
IOS_BUNDLE_ID
```

### Google Services（2個）

```
GOOGLE_SERVICE_INFO_PLIST        # iOS用（Step 4で取得）
GOOGLE_SERVICES_JSON             # Android用（Step 4で取得）
```

### Apple証明書（4個）

```
BUILD_CERTIFICATE_BASE64         # Step 1で取得
P12_PASSWORD                     # Step 1で設定したパスワード
BUILD_PROVISION_PROFILE_BASE64   # Step 2で取得
KEYCHAIN_PASSWORD                # 任意の強固なパスワード（20文字以上推奨）
```

### App Store Connect（3個）

```
APPLE_ID                         # Step 5-1で取得
APP_SPECIFIC_PASSWORD            # Step 5-2で取得
TEAM_ID                          # Step 5-3で取得
```

**合計：20個のSecrets**

---

## 🚀 デプロイ実行

### 方法1: タグをプッシュ（自動）

```bash
git tag v1.0.0
git push origin v1.0.0
```

### 方法2: 手動実行

1. GitHub → Actions タブ
2. "Deploy iOS" ワークフローを選択
3. "Run workflow" → 環境選択 → 実行

---

## 🔧 ExportOptions.plistの編集

`ios/ExportOptions.plist` を編集：

```xml
<key>teamID</key>
<string>YOUR_TEAM_ID</string>  <!-- 実際のTeam ID -->

<key>provisioningProfiles</key>
<dict>
    <key>com.example.tree</key>  <!-- 実際のBundle ID -->
    <string>YourApp Distribution</string>  <!-- プロファイル名 -->
</dict>
```

---

## ❓ よくあるエラー

| エラーメッセージ | 原因 | 解決方法 |
|---------------|------|---------|
| No valid code signing identity | 証明書が無効 | `BUILD_CERTIFICATE_BASE64` と `P12_PASSWORD` を確認 |
| No provisioning profile found | プロファイルが見つからない | `BUILD_PROVISION_PROFILE_BASE64` を確認 |
| Authentication failed | App Store Connect認証失敗 | `APPLE_ID` と `APP_SPECIFIC_PASSWORD` を確認 |
| Missing env: IOS_API_KEY | Firebase環境変数不足 | すべてのFirebase Secretsを登録したか確認 |

---

## 💡 Tips

### キーチェーンパスワードを自動生成

```bash
openssl rand -base64 32
```

### Base64エンコードをクリップボードにコピー

```bash
# macOS
base64 -i file.p12 | pbcopy

# Linux
base64 -i file.p12 | xclip -selection clipboard
```

### Secretsが正しく登録されているか確認

GitHub Actions実行時のログで `Step: .envファイルの作成` が成功しているか確認。

---

## 📚 次のステップ

- [ ] 初回デプロイを実行してTestFlightで確認
- [ ] App Store Connectでベータテスターを追加
- [ ] フィードバックに基づいて改善
- [ ] 本番リリース用のワークフローを検討

---

**🎉 準備完了したらタグをプッシュしてデプロイしましょう！**

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actionsタブで進捗を確認できます。

