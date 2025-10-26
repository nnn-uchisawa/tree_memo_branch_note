# Tree

A treememo mobile app satisfiable for me

## ビルド手順

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
