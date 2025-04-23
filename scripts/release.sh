#!/bin/bash

# 确保脚本在错误时退出
set -e

# 检查是否提供了版本号
if [ $# -ne 1 ]; then
  echo "用法: $0 <版本号>"
  echo "例如: $0 v1.0.1"
  exit 1
fi

VERSION=$1

# 检查版本格式
if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "错误: 版本号格式错误，应为 v1.0.0 格式"
  exit 1
fi

# 检查是否已经存在该标签
if git rev-parse "$VERSION" >/dev/null 2>&1; then
  echo "错误: 标签 $VERSION 已存在"
  exit 1
fi

# 创建发布目录（如果不存在）
mkdir -p releases

# 根据模板创建发布说明
if [ -f .github/release_template.md ]; then
  # 替换模板中的版本变量
  sed "s/\${VERSION}/$VERSION/g" .github/release_template.md > "releases/release_notes_$VERSION.md"
  
  # 打开文件编辑
  if command -v code >/dev/null 2>&1; then
    code "releases/release_notes_$VERSION.md"
  elif command -v nano >/dev/null 2>&1; then
    nano "releases/release_notes_$VERSION.md"
  elif command -v vim >/dev/null 2>&1; then
    vim "releases/release_notes_$VERSION.md"
  else
    echo "请手动编辑 releases/release_notes_$VERSION.md 文件，完成后按回车继续"
    read -p "按回车继续..."
  fi
else
  echo "警告: 未找到发布模板文件 .github/release_template.md"
  echo "请手动创建 releases/release_notes_$VERSION.md 文件"
  exit 1
fi

# 复制到 release_notes.md（工作流使用此文件）
cp "releases/release_notes_$VERSION.md" release_notes.md

# 提交发布说明
git add "releases/release_notes_$VERSION.md" release_notes.md
git commit -m "添加 $VERSION 发布说明"

# 创建标签
git tag -a "$VERSION" -m "Travel Joy $VERSION 版本发布"

echo "已创建标签 $VERSION，现在您可以推送标签以触发自动构建："
echo "git push origin $VERSION" 