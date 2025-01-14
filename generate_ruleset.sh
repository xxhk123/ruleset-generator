#!/bin/bash

# 下载 china.txt 文件
curl -O https://raw.githubusercontent.com/gaoyifan/china-operator-ip/refs/heads/ip-lists/china.txt

# 检查 china.txt 是否存在
if [ ! -f "china.txt" ]; then
  echo "china.txt file not found!"
  exit 1
fi

# 开始构建 ruleset 文件
echo "{
  \"rules\": [" > ruleset.json

# 逐行读取 china.txt 中的 IP-CIDR 格式数据
while IFS= read -r line; do
  # 跳过空行和注释行
  if [[ -z "$line" || "$line" == \#* ]]; then
    continue
  fi
  # 将每个 CIDR 地址加入规则
  echo "    {\"IP-CIDR\": \"$line\"}," >> ruleset.json
done < "china.txt"

# 关闭 JSON 数组
echo "  ]" >> ruleset.json

echo "Ruleset generated: ruleset.json"
