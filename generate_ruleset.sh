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

# ------------------------------
# 以下部分是新添加的功能，用于处理你提供的规则列表
# ------------------------------
# 假设你要处理的规则文件是直接给定的一个 URL
rules_url="https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/direct-list.txt"
curl -s -o rules.txt "$rules_url"

if [ $? -ne 0 ]; then
  echo "Failed to download rules.txt. Exiting."
  exit 1
fi

# 生成 singbox 的规则文件
singbox_ruleset="singbox-ruleset.txt"

echo "Converting direct-list.txt to singbox ruleset format..."

# 生成 singbox-ruleset.txt
echo "// Singbox ruleset" > "$singbox_ruleset"
echo "// Auto-generated from direct-list.txt" >> "$singbox_ruleset"
echo "" >> "$singbox_ruleset"

# 假设文件中的内容是域名和正则表达式，转换为 singbox 格式
while read -r line; do
  line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  # 去除空格
  if [[ -z "$line" || "$line" == \#* ]]; then
    continue  # 忽略空行和注释行
  fi

  # 调试输出，查看每一行
  # echo "Processing line: $line"

  # 处理规则并转换为 singbox 规则
  if [[ "$line" =~ ^full.* ]]; then
    # 处理 full 域名规则
    echo "DOMAIN,${line#full},Direct" >> "$singbox_ruleset"
  elif [[ "$line" =~ ^.*\..*\..* ]]; then
    # 处理普通域名
    echo "DOMAIN-KEYWORD,$line,Direct" >> "$singbox_ruleset"
  elif [[ "$line" =~ ^/.*\/ ]]; then
    # 处理正则表达式
    echo "DOMAIN-REGEX,$line,Direct" >> "$singbox_ruleset"
  else
    # 处理意外的格式
    echo "UNKNOWN, $line" >> "$singbox_ruleset"
  fi
done < rules.txt

echo "Converted to singbox ruleset format."
cat "$singbox_ruleset"
