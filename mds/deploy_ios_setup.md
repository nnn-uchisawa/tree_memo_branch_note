# iOSデプロイ用GitHub Secrets設定ガイド

このドキュメントでは、GitHub ActionsでiOSアプリをTestFlightにデプロイするために必要なSecretsの設定方法を説明します。

## 📋 必要なSecrets一覧

### 1. Firebase関連（.env）

| Secret名 | 説明 | 取得方法 |
|---------|------|---------|
| `ANDROID_API_KEY` | Android Firebase APIキー | Firebaseコンソール > プロジェクト設定 > Android |
| `ANDROID_APP_ID` | Android Firebase アプリID | 同上 |
| `ANDROID_MESSAGING_SENDER_ID` | Android Firebase メッセージングID | 同上 |
| `ANDROID_PROJECT_ID` | Android Firebase プロジェクトID | 同上 |
| `ANDROID_STORAGE_BUCKET` | Android Firebase ストレージバケット | 同上 |
| `IOS_API_KEY` | iOS Firebase APIキー | Firebaseコンソール > プロジェクト設定 > iOS |
| `IOS_APP_ID` | iOS Firebase アプリID | 同上 |
| `IOS_MESSAGING_SENDER_ID` | iOS Firebase メッセージングID | 同上 |
| `IOS_PROJECT_ID` | iOS Firebase プロジェクトID | 同上 |
| `IOS_STORAGE_BUCKET` | iOS Firebase ストレージバケット | 同上 |
| `IOS_BUNDLE_ID` | iOSバンドルID | `com.example.tree` など |

### 2. Google Sign-In関連

| Secret名 | 説明 | 取得方法 |
|---------|------|---------|
| `GOOGLE_SERVICE_INFO_PLIST` | GoogleService-Info.plistの内容 | 下記手順参照 |

### 3. Apple証明書関連

| Secret名 | 説明 | 取得方法 |
|---------|------|---------|
| `BUILD_CERTIFICATE_BASE64` | 署名証明書（p12形式をBase64エンコード） | 下記手順参照 |
| `P12_PASSWORD` | p12証明書のパスワード | 証明書エクスポート時に設定したパスワード |
| `BUILD_PROVISION_PROFILE_BASE64` | プロビジョニングプロファイル（Base64エンコード） | 下記手順参照 |
| `KEYCHAIN_PASSWORD` | キーチェーンのパスワード | 任意の強固なパスワード（20文字以上推奨） |

### 4. App Store Connect関連

| Secret名 | 説明 | 取得方法 |
|---------|------|---------|
| `APPLE_ID` | Apple IDメールアドレス | App Store Connect用のApple ID |
| `APP_SPECIFIC_PASSWORD` | アプリ用パスワード | 下記手順参照 |
| `TEAM_ID` | チームID | Apple Developer > Membership |

---

## 🔧 設定手順

### Step 1: Firebaseの環境変数を取得

1. [Firebaseコンソール](https://console.firebase.google.com/)にアクセス
2. プロジェクトを選択 > ⚙️（設定）> プロジェクト設定
3. 「マイアプリ」セクションでAndroidとiOSそれぞれの設定値をコピー

**ローカルの.envファイル例：**
```bash
# Android Firebase設定
ANDROID_API_KEY=AIzaSy...
ANDROID_APP_ID=1:123456789:android:abc123
ANDROID_MESSAGING_SENDER_ID=123456789
ANDROID_PROJECT_ID=your-project-id
ANDROID_STORAGE_BUCKET=your-project-id.appspot.com

# iOS Firebase設定
IOS_API_KEY=AIzaSy...
IOS_APP_ID=1:123456789:ios:xyz789
IOS_MESSAGING_SENDER_ID=123456789
IOS_PROJECT_ID=your-project-id
IOS_STORAGE_BUCKET=your-project-id.appspot.com
IOS_BUNDLE_ID=com.example.tree
```

### Step 2: GoogleService-Info.plistを準備

Google Sign-Inを使用するため、iOSの`GoogleService-Info.plist`が必要です。

#### ファイルの取得

1. [Firebaseコンソール](https://console.firebase.google.com/)にアクセス
2. プロジェクトを選択 > ⚙️（設定）> プロジェクト設定
3. 「マイアプリ」セクションでiOSアプリを選択
4. **GoogleService-Info.plist**ボタンをクリックしてダウンロード

または、ローカルにある場合：
```bash
# プロジェクトのファイルを使用
cat ios/Runner/GoogleService-Info.plist
```

#### GitHub Secretsに登録

ファイルの**内容全体**をそのままコピーしてGitHub Secretsに登録します：

```bash
# クリップボードにコピー
cat ios/Runner/GoogleService-Info.plist | pbcopy
```

GitHub Secrets:
```
Name: GOOGLE_SERVICE_INFO_PLIST
Secret: （GoogleService-Info.plistの内容全体を貼り付け）
```

**⚠️ 注意：**
- ファイル全体（`<?xml version...`から`</plist>`まで）をコピー
- 改行も含めてすべてコピーすること
- このファイルにはGoogle Sign-Inに必要な`CLIENT_ID`などが含まれています

### Step 3: 署名証明書（.p12）を準備

#### Macの「キーチェーンアクセス」から証明書をエクスポート

1. **キーチェーンアクセス.app**を起動
2. 左側メニューで「ログイン」→「自分の証明書」を選択
3. **"Apple Distribution"** または **"iOS Distribution"** 証明書を探す
4. 証明書を右クリック → 「書き出す...」
5. ファイル形式：**個人情報交換（.p12）**を選択
6. パスワードを設定（これが`P12_PASSWORD`になります）
7. `certificate.p12`として保存

#### Base64エンコード

```bash
# ターミナルで実行
base64 -i certificate.p12 | pbcopy
# クリップボードにBase64エンコードされた文字列がコピーされます
```

この文字列を`BUILD_CERTIFICATE_BASE64`に設定します。

### Step 4: プロビジョニングプロファイルを準備

#### Apple Developer Portalからダウンロード

1. [Apple Developer](https://developer.apple.com/)にログイン
2. **Certificates, Identifiers & Profiles**を選択
3. **Profiles** → 該当する**App Store**プロファイルを選択
4. **Download**ボタンでダウンロード（`YourApp.mobileprovision`）

#### Base64エンコード

```bash
# ターミナルで実行
base64 -i YourApp.mobileprovision | pbcopy
```

この文字列を`BUILD_PROVISION_PROFILE_BASE64`に設定します。

### Step 5: App Storeアップロード用のパスワードを取得

#### アプリ用パスワードの生成

1. [Apple ID管理画面](https://appleid.apple.com/)にアクセス
2. **サインインとセキュリティ** → **App用パスワード**
3. 「パスワードを生成」をクリック
4. ラベル（例：`GitHub Actions`）を入力
5. 生成された16文字のパスワードをコピー

これが`APP_SPECIFIC_PASSWORD`になります。

### Step 6: Team IDを取得

1. [Apple Developer](https://developer.apple.com/)にログイン
2. **Membership**を選択
3. **Team ID**をコピー（例：`AB12CD34EF`）

### Step 7: GitHub Secretsに登録

1. GitHubリポジトリページへアクセス
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret**をクリック
4. 上記の全てのSecretsを登録

#### 登録例：

```
Name: IOS_API_KEY
Secret: AIzaSyC_your_actual_api_key_here
```

**⚠️ 注意事項：**
- Base64エンコードした文字列は改行を含めてすべてコピー
- パスワードやAPIキーは絶対に他人と共有しない
- Secretsは一度登録すると値を確認できないので、控えておくこと

---

## 🎯 ExportOptions.plistの設定

`ios/ExportOptions.plist`を以下のように編集してください：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>  <!-- 実際のTeam IDに置き換え -->
    <key>provisioningProfiles</key>
    <dict>
        <key>com.example.tree</key>  <!-- 実際のBundle IDに置き換え -->
        <string>YourApp Distribution</string>  <!-- プロビジョニングプロファイル名 -->
    </dict>
</dict>
</plist>
```

---

## 🚀 デプロイの実行

### 自動デプロイ（タグプッシュ時）

```bash
git tag v1.0.0
git push origin v1.0.0
```

### 手動デプロイ

1. GitHubリポジトリの**Actions**タブへ
2. **Deploy iOS**ワークフローを選択
3. **Run workflow**をクリック
4. 環境を選択（testflight/production）
5. **Run workflow**を実行

---

## 📝 トラブルシューティング

### エラー: "No valid code signing identity found"

**原因：** 証明書が正しくインポートされていない

**解決策：**
- `BUILD_CERTIFICATE_BASE64`が正しくエンコードされているか確認
- `P12_PASSWORD`が正しいか確認

### エラー: "No provisioning profile found"

**原因：** プロビジョニングプロファイルが見つからない

**解決策：**
- `BUILD_PROVISION_PROFILE_BASE64`が正しくエンコードされているか確認
- プロファイルのBundle IDが一致しているか確認

### エラー: "Authentication failed"

**原因：** App Store Connectへの認証に失敗

**解決策：**
- `APPLE_ID`が正しいか確認
- `APP_SPECIFIC_PASSWORD`が有効か確認（期限切れの場合は再生成）

### ワークフローがFirebase設定でエラー

**原因：** .envの環境変数が不足または誤っている

**解決策：**
- すべてのFirebase関連Secretsが登録されているか確認
- Firebaseコンソールで値が正しいか再確認

---

## 🔒 セキュリティベストプラクティス

1. **Secretsは定期的に更新**
   - App用パスワードは6ヶ月ごとに再生成推奨

2. **環境ごとにSecretsを分離**
   - 開発環境と本番環境でSecretsを分ける場合は、Environmentsを使用

3. **アクセス制限**
   - リポジトリの閲覧権限を適切に設定
   - Secretsへのアクセスは最小限のメンバーに限定

4. **監査ログを確認**
   - ActionsタブでSecretsの使用状況を定期的にチェック

---

## 📚 参考リンク

- [Flutter公式：iOSデプロイガイド](https://docs.flutter.dev/deployment/ios)
- [GitHub Actions：暗号化されたシークレット](https://docs.github.com/ja/actions/security-guides/encrypted-secrets)
- [Apple Developer：プロビジョニングプロファイル](https://developer.apple.com/documentation/appstoreconnectapi/profiles)
- [Firebase：iOSアプリの設定](https://firebase.google.com/docs/ios/setup)

