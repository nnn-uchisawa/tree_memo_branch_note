# Tree

A treememo mobile app satisfiable for me

## ビルド手順

開発環境は Flutter 3.50.0（Dart 3.14.0）以降、Android ビルドは Java 17 以降を使用します。
Android のビルドツールも Flutter 3.50 の構成（Gradle 9.5.0 / AGP 9.3.1 / Kotlin 2.4.20）に合わせています。

```sh
flutter --version
flutter pub get
dart run build_runner build
flutter test
flutter run --flavor local
```

`build_runner` は `flutter_gen_runner` の `build` 4 系との互換性のため、2.16.2 系に制限しています。

Windows では Java 17 を指定して起動できます。`.tooling/java17/` に JDK を展開済みなら `-JavaHome` は省略できます。

```powershell
./scripts/run_android.ps1 -JavaHome 'C:/path/to/jdk-17'
# APK の作成のみ
./scripts/run_android.ps1 -JavaHome 'C:/path/to/jdk-17' -BuildOnly
```

- [flutterの環境セットアップ手順](mds/flutter_setup/index.md)<br>
- [ソースのDL・セットアップ手順](mds/source_operation/index.md)<br>
- [ビルド手順](mds/build_operation/index.md)

## 🚀 CI/CD（GitHub Actions）

このプロジェクトでは、GitHub Actionsを使用した自動化を実装しています。

### ワークフロー

- **CI** (`.github/workflows/ci.yml`) - mainブランチへのプッシュ・PR時に自動実行
  - コード品質チェック（フォーマット、静的解析）
  - テスト実行とカバレッジレポート生成

- **Build** (`.github/workflows/build.yml`) - mainブランチへのプッシュ時に実行
  - Android/iOSのビルド検証

- **PR Check** (`.github/workflows/pr-check.yml`) - PR作成時に自動実行
  - 軽量なクイックチェック

- **Deploy iOS** (`.github/workflows/deploy-ios.yml`) - タグプッシュまたは手動実行
  - TestFlightへの自動デプロイ
  - 設定方法は [iOSデプロイ設定ガイド](mds/deploy_ios_setup.md) を参照
  - セキュリティについては [GitHub Actionsセキュリティガイド](mds/github_actions_security.md) を参照

### iOSデプロイの設定

TestFlightへの自動デプロイを有効にするには：

1. **設定ドキュメントを確認**
   ```bash
   # 詳細な手順は以下を参照
   open mds/deploy_ios_setup.md
   ```

2. **補助スクリプトを実行**
   ```bash
   # Secretsの値を準備するための対話型スクリプト
   ./scripts/encode_secrets.sh
   ```

3. **GitHub Secretsに登録**
   - リポジトリ設定 > Secrets and variables > Actions
   - 必要なSecretsをすべて登録（詳細はガイド参照）

4. **デプロイの実行**
   ```bash
   # タグをプッシュして自動デプロイ
   git tag v1.0.0
   git push origin v1.0.0
   ```
