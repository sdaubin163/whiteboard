#!/bin/bash

# Whiteboard 本地构建脚本（仅供个人使用）

set -e

echo "🚀 构建 Whiteboard 应用（本地使用）..."

# 检查 Xcode 是否可用
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 请安装 Xcode"
    exit 1
fi

# 构建应用
echo "🔨 正在构建..."
xcodebuild \
    -project whiteboard.xcodeproj \
    -scheme whiteboard \
    -configuration Release \
    -derivedDataPath build \
    build

# 找到并复制应用
BUILT_APP=$(find build -name "whiteboard.app" -type d | head -1)

if [ -n "$BUILT_APP" ]; then
    echo "📦 复制应用..."
    cp -R "$BUILT_APP" ./whiteboard.app
    
    echo "✅ 构建完成!"
    echo "📍 应用位置: $(pwd)/whiteboard.app"
    echo ""
    echo "🎯 使用方法:"
    echo "  双击 whiteboard.app 运行，或者："
    echo "  open whiteboard.app"
    
    # 询问是否立即运行
    read -p "是否立即运行应用？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open whiteboard.app
    fi
else
    echo "❌ 构建失败，未找到应用文件"
    exit 1
fi