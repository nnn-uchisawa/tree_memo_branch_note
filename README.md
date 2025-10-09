# Tree

A treememo mobile app satisfiable for me

## ビルド手順

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
<span style="background:black,color:white">$ flutter pub get && flutter pub run build_runner build</span>
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

1. インストールする端末をUSB接続（vscodeが認識すると右下の🔔マークの左に端末名が表示される　※トラブルが起き易いところなので認識されない場合各自検索するなどしてください）
2. vscodeでPJルートを開く
3. vscode内terminalで以下のコマンドを実行

```
<span style="background:black,color:white">$ flutter run</span>
```

4. デバッグ実行したい場合は以下のコマンドを実行

```
<span style="background:black,color:white">$ flutter run --debug</span>
```