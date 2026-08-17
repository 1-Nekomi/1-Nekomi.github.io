REM 开始前请在该目录下配置.env文件
REM ALGOLIA_APP_ID= YourAlgoliaAppId
REM ALGOLIA_ADMIN_KEY= YourAlgoliaAdminKey
REM ALGOLIA_INDEX_NAME= YourAlgoliaIndexName
REM ALGOLIA_INDEX_FILE= YourAlgoliaIndexFile  

REM npm install -g atomic-algolia

echo 正在构建 Hugo 站点（生成 public 目录）...
hugo
echo 正在上传数据到 Algolia...
call atomic-algolia
pause