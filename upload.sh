#!/bin/bash
# Linux/MacOS "chmod +x upload.sh" to make it executable

# 开始前请在该目录下配置 .env 文件
# ALGOLIA_APP_ID= YourAlgoliaAppId
# ALGOLIA_ADMIN_KEY= YourAlgoliaAdminKey
# ALGOLIA_INDEX_NAME= YourAlgoliaIndexName
# ALGOLIA_INDEX_FILE= YourAlgoliaIndexFile

# npm install -g atomic-algolia

echo "正在构建 Hugo 站点（生成 public 目录）..."
hugo
echo "正在上传数据到 Algolia..."
atomic-algolia