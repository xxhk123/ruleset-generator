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

# 将 china.txt 中的每行转换为符合 CIDR 格式的数组项，并去掉末尾的逗号
awk '{ print "        \"" $0 "\"" }' china.txt >> ruleset.json

# 删除最后一行多余的逗号，并关闭 JSON 数组和对象
echo '
      ]
    }
  ]
}' >> ruleset.json

echo "ruleset.json has been generated."
