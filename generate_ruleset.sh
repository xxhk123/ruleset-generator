#!/bin/bash

# 下载 china.txt 文件
china_txt_url="https://raw.githubusercontent.com/gaoyifan/china-operator-ip/refs/heads/ip-lists/china.txt"
curl -s -o china.txt "$china_txt_url"

# 生成 ruleset.json 文件
echo '{
  "version": 1,
  "rules": [
    {
      "ip_cidr": [' > ruleset.json

# 将 china.txt 中的每行转换为符合 CIDR 格式的数组项
# 确保每个 CIDR 地址没有多余的空格和换行
awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); if(NF > 0) print "        \"" $0 "\""}' china.txt | sed '/^$/d' >> ruleset.json

# 删除最后一行的逗号，关闭 JSON 数组和对象
# 使用 head 命令删除最后一行的逗号
head -n -1 ruleset.json > temp.json && mv temp.json ruleset.json

# 添加闭合的 JSON 语法
echo '
      ]
    }
  ]
}' >> ruleset.json

echo "ruleset.json has been generated."

# 以下是将更改提交到 Git 仓库的部分

# 配置 Git
git config --global user.email "action@github.com"
git config --global user.name "GitHub Actions"

# 添加所有修改的文件（包括新下载的 china.txt）
git add ruleset.json
git add china.txt
git add generate_ruleset.sh

# 检查是否有修改，如果有修改则提交
if git diff --staged --quiet; then
  echo "No changes to commit"
  exit 0
else
  git commit -m "Update ruleset.json"
  git push
fi
