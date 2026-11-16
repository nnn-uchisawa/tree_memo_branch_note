#!/bin/bash

# カバレッジレポート生成スクリプト
# 使用方法: ./scripts/coverage_report.sh

set -e

echo "======================================"
echo "テストカバレッジレポート生成"
echo "======================================"
echo ""

# カバレッジ付きでテストを実行
echo "🧪 テストを実行中..."
flutter test --coverage

if [ ! -f coverage/lcov.info ]; then
    echo "❌ カバレッジファイルが生成されませんでした"
    exit 1
fi

echo ""
echo "✅ テスト完了"
echo ""

# 簡易サマリーを表示
echo "📊 カバレッジサマリー:"
total_lines=$(grep -c "^DA:" coverage/lcov.info)
covered_lines=$(grep "^DA:" coverage/lcov.info | grep -v ",0$" | wc -l | tr -d ' ')

coverage_percent=$(awk "BEGIN {printf \"%.2f\", ($covered_lines / $total_lines) * 100}")
echo "  全体: ${coverage_percent}% (${covered_lines}/${total_lines} 行)"

echo ""

# HTMLレポート生成
if command -v genhtml &> /dev/null; then
    echo "📄 HTMLレポートを生成中..."
    genhtml coverage/lcov.info -o coverage/html --quiet
    echo ""
    echo "✅ HTMLレポートが生成されました"
    echo "   📁 coverage/html/index.html"
    echo ""
    
    # 自動で開くか確認
    read -p "ブラウザで開きますか？ (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open coverage/html/index.html
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            xdg-open coverage/html/index.html
        else
            echo "coverage/html/index.html をブラウザで開いてください"
        fi
    fi
else
    echo "⚠️  genhtml がインストールされていません"
    echo ""
    echo "HTMLレポートを生成するには、以下のコマンドでlcovをインストールしてください："
    echo ""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  brew install lcov"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "  sudo apt-get install lcov"
    fi
    echo ""
    echo "インストール後、このスクリプトを再実行してください。"
    echo ""
    echo "代わりに、VSCodeの「Coverage Gutters」拡張機能を使うこともできます："
    echo "  1. 拡張機能をインストール"
    echo "  2. Cmd+Shift+P → 'Coverage Gutters: Display Coverage'"
fi

echo ""
echo "======================================"
echo "完了"
echo "======================================"

