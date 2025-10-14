# Tree

A treememo mobile app satisfiable for me

## ビルド手順

### ソースのDL

terminalでソースを置きたいディレクトリに移動し以下を実行、又はクライアントでクローン
```
$ git clone https://github.com/nnn-uchisawa/tree_memo_branch_note.git
```
/assets/fonts
に「Noto-SansJP-Regular.ttf」を配置
DLはコチラ💁
https://fonts.google.com/noto/specimen/Noto+Sans+JP

/android/app
にgoogle-service.jsonを配置

/ios/Runner
にGoogleService-Info.plistを配置（Xcodeの操作が必要な場合があります）

PJルートに以下の環境変数ファイルを配置
.env
.env.android
.env.ios

### 環境構築

vscodeのflutter設定手順はコチラ💁(英語 公式)
https://docs.flutter.dev/install/with-vs-code

Androidで実行する場合の設定手順はコチラ💁（英語 公式）
https://docs.flutter.dev/platform-integration/android/setup

iOSで実行する場合の設定手順はコチラ💁（英語 公式）
※iOSで実行することができるのはmacのみでWindowsPCでは不可
https://docs.flutter.dev/platform-integration/ios/setup

### パッケージインストール・動的ファイル生成

vscodeでPJルートを開き
vscode内terminalで以下のコマンドを実行

```
$ flutter pub get && flutter pub run build_runner build
```

### 実行端末の設定

インストール対象の端末で開発者モードを有効にする
※途中で端末認証を要求される場合があります

Android：OSバージョンなどによって異なる場合もありますが
1. 設定 → デバイス情報 の順に開く
2. ビルド番号を7回連打
3. 設定 → システム → 開発者向けオプション の順に開く
4. 少し下にスクロールすると「USBデバッグ」の項目があるのでON

iOS
1. 設定 → プライバシーとセキュリティ → デベロッパモード の順に開く
2. デベロッパモードをON

### 実行

1. インストールする端末をUSB接続（vscodeが認識すると右下の🔔マークの左に端末名が表示される　※1トラブルが起き易いところなので認識されない場合各自検索するなどしてください ※2接続モードやadbパスなど）
2. vscodeでPJルートを開く
3. vscode内terminalで以下のコマンドを実行

```
$ flutter run
```

4. デバッグ実行したい場合は以下のコマンドを実行

```
$ flutter run --debug
```
