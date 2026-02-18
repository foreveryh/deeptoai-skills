#!/bin/bash
# 智谱 Web Search - 从配置读取 key 并执行搜索

set -e

QUERY="${1:-清华大学}"
COUNT="${2:-10}"
CONTENT_SIZE="${3:-medium}"
RECENCY="${4:-noLimit}"

CONFIG_FILE="$HOME/.moltbot/moltbot.json"

# 读取 API Key（优先 zhipu，其次 zai，过滤模板值）
get_api_key() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "配置文件不存在: $CONFIG_FILE" >&2
        return 1
    fi
    
    # 方式一：使用 jq（如果有的话）
    if command -v jq >/dev/null 2>&1; then
        # 尝试 zhipu
        KEY=$(jq -r '.models.providers.any.apiKey // empty' "$CONFIG_FILE" 2>/dev/null)
        if [ -n "$KEY" ] && [[ ! "$KEY" =~ ^\{\{ ]]; then
            echo "$KEY"
            return 0
        fi
    else
        # 方式二：纯 bash + grep/sed（无需 jq）
        # 提取 zhipu provider 的 apiKey
        KEY=$(grep -A10 '"any"' "$CONFIG_FILE" 2>/dev/null | grep '"apiKey"' | head -1 | sed 's/.*"apiKey".*:.*"\([^"]*\)".*/\1/')
        if [ -n "$KEY" ] && [[ ! "$KEY" =~ ^\{\{ ]]; then
            echo "$KEY"
            return 0
        fi
    fi
    
    # Fallback 到环境变量
    if [ -n "$ZHIPU_API_KEY" ] && [[ ! "$ZHIPU_API_KEY" =~ ^\{\{ ]]; then
        echo "$ZHIPU_API_KEY"
        return 0
    fi
    
    echo "未找到有效的 API Key（需要 zhipu 或 zai provider，或环境变量 ZHIPU_API_KEY）" >&2
    return 1
}

# 获取 API Key
API_KEY=$(get_api_key)
if [ -z "$API_KEY" ]; then
    exit 1
fi

echo "🔍 搜索查询: $QUERY" >&2
echo "📊 结果数量: $COUNT" >&2
echo "" >&2

# 调用智谱 Web Search API
RESPONSE=$(curl -s --request POST \
  --url https://open.bigmodel.cn/api/paas/v4/web_search \
  --header "Authorization: Bearer $API_KEY" \
  --header 'Content-Type: application/json' \
  --data "{
    \"search_query\": \"${QUERY}\",
    \"search_engine\": \"search_std\",
    \"search_intent\": false,
    \"count\": ${COUNT},
    \"search_recency_filter\": \"${RECENCY}\",
    \"content_size\": \"${CONTENT_SIZE}\"
  }")

# 检查是否有错误
if echo "$RESPONSE" | grep -q '"error"'; then
    echo "❌ API 错误:" >&2
    echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
    exit 1
fi

# 格式化输出（如果有 jq）
if command -v jq >/dev/null 2>&1; then
    echo "✅ 搜索结果:" >&2
    echo "" >&2
    echo "$RESPONSE" | jq -r '
        if .search_result then
            .search_result[] | 
            "## \(.title // "无标题")\n🔗 \(.link // "无链接")\n📝 \(.content[0:200] // "无摘要")\n📅 发布: \(.publish_date // "未知")\n📰 来源: \(.media // "未知")\n"
        else
            "未找到结果"
        end
    '
else
    # 无 jq 时直接输出原始 JSON
    echo "$RESPONSE"
fi

