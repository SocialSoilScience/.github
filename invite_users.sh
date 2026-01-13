#!/bin/bash

# 检查是否提供了 Issue URL
if [ -z "$1" ]; then
  echo "用法: $0 <issue_url>"
  exit 1
fi

ISSUE_URL=$1

# 从 URL 中提取组织名称 (假设 URL 格式为 https://github.com/ORG/REPO/issues/NUM)
ORG_NAME=$(echo "$ISSUE_URL" | awk -F/ '{print $4}')

if [ -z "$ORG_NAME" ]; then
  echo "无法从 URL 中提取组织名称。"
  exit 1
fi

echo "正在从 $ISSUE_URL 提取用户并邀请至 $ORG_NAME ..."

# 获取评论区的所有用户名并去重
# 使用 sort -u 进行去重
USERS=$(gh issue view "$ISSUE_URL" --comments --json comments -q '.comments[].author.login' | sort -u)

if [ -z "$USERS" ]; then
  echo "未找到评论用户。"
  exit 0
fi

for USER in $USERS; do
  echo "正在邀请用户: $USER ..."
  # 执行邀请 API 调用
  # 如果失败不退出，继续邀请下一个
  gh api --method PUT "/orgs/$ORG_NAME/memberships/$USER" -f role=member || echo "邀请 $USER 失败"
done

echo "任务完成。"
