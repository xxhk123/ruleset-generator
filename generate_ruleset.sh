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

# 将 china.txt 中的每行转换为 CIDR 格式并格式化
awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); if(NF > 0) print "        \"" $0 "\""}' china.txt | sed '/^$/d' | \
# 在每行后添加逗号
awk '{print $0 ","}' >> ruleset.json

# 删除最后一行的逗号
# 使用 sed 删除最后一行的逗号
sed -i '$ s/,$//' ruleset.json

# 添加闭合的 JSON 语法
echo '
      ]
    }
  ]
}' >> ruleset.json

# 打印文件内容检查
echo "Generated ruleset.json content:"
cat ruleset.json

# 确保生成了正确的文件并将其添加到 Git
git status
echo "ruleset.json has been generated."
