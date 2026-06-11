@echo off
chcp 65001
cd /d D:\stsmod\SlayTheSpire2MODs

:: 添加当前目录所有文件、子目录全部内容
git add .

:: 提交备注
git commit -m "更新所有文件"

:: 先拉取远程更新，再推送
git pull origin main
git push origin main

echo 全部文件同步完成！
pause