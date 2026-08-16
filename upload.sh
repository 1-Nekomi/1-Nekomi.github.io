#!/bin/bash
# Linux/MacOS "chmod +x upload.sh" to make it executable

# npm install -g atomic-algolia

echo "正在构建 Hugo 站点（生成 public 目录）..."
hugo
echo "正在上传数据到 Algolia..."
atomic-algolia