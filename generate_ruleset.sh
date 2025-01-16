#!/bin/bash

# 下载 china.txt 文件
china_txt_url="https://raw.githubusercontent.com/gaoyifan/china-operator-ip/refs/heads/ip-lists/china.txt"
curl -s -o china.txt "$china_txt_url"

if [ $? -ne 0 ]; then
  echo "Failed to download china.txt. Exiting."
  exit 1
fi

# 生成 ruleset.json 文件
echo '{
  "version": 1,
  "rules": [
    {
      "ip_cidr": [' > ruleset.json

# 将 china.txt 中的每行转换为 CIDR 格式并格式化
awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); if(NF > 0) print "        \"" $0 "\""}' china.txt | sed '/^$/d' | \
# 在每行后添加逗号
awk '{print $0 ","}' >> ruleset.json

# 删除最后一行的逗号
# 使用 sed 删除最后一行的逗号
sed -i '$ s/,$//' ruleset.json

# 添加闭合的 JSON 语法
echo '      ]
    }
  ]
}' >> ruleset.json

# 打印文件内容检查
echo "Generated ruleset.json content:"
cat ruleset.json

# 检查文件是否存在
if [ -f "ruleset.json" ]; then
  echo "ruleset.json exists."
  # 使用 git diff 检查文件是否有修改
  if git diff --quiet ruleset.json; then
    echo "ruleset.json has no changes."
    # 强制覆盖文件，先备份原文件（可选）
    #cp ruleset.json ruleset.json.backup
    # 使用 git checkout 将文件重置为上一次提交的状态，这相当于覆盖文件
    git checkout -- ruleset.json
    echo "ruleset.json has been overwritten."
  else
    echo "ruleset.json has changes."
  fi
else
  echo "ruleset.json does not exist."
fi
