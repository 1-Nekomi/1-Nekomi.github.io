@echo off

REM 开始前请在该目录下配置.env文件
REM ALGOLIA_APP_ID= YourAlgoliaAppId
REM ALGOLIA_ADMIN_KEY= YourAlgoliaAdminKey
REM ALGOLIA_INDEX_NAME= YourAlgoliaIndexName
REM ALGOLIA_INDEX_FILE= YourAlgoliaIndexFile  

REM npm install -g atomic-algolia

hugo

call atomic-algolia
pause