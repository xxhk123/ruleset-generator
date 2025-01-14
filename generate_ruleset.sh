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
awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); if(NF > 0) print "        \"" $0 "\""}' china.txt >> ruleset.json

# 删除最后一行的逗号，关闭 JSON 数组和对象
# 使用 'head' 和 'tail' 删除多余的逗号
head -n -1 ruleset.json > temp.json && mv temp.json ruleset.json

echo '
      ]
    }
  ]
}' >> ruleset.json

echo "ruleset.json has been generated."
