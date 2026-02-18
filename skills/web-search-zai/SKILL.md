# web-search-zai (On-demand curl)

这个 skill 不启动常驻服务。

调用时临时执行 `curl` 请求智谱 `web_search` API，平时零占用。

## 读取 API Key 规则

- 优先读取 `~/.clawdbot/clawdbot.json` 的 `models.providers.zhipu.apiKey`
- 其次读取 `~/.clawdbot/clawdbot.json` 的 `models.providers.zai.apiKey`
- 若是模板值（如 `{{.ApiKey}}`）视为无效
- 若以上都没有，则尝试环境变量 `ZHIPU_API_KEY`

## 一次性搜索命令模板

把 `QUERY` 改成你的查询词即可：

```bash
QUERY="清华大学"

API_KEY="$(python3 - <<'PY'
import json
from pathlib import Path

p = Path.home() / '.clawdbot' / 'clawdbot.json'
cfg = json.loads(p.read_text(encoding='utf-8'))
providers = cfg.get('models', {}).get('providers', {})

for name in ('zhipu', 'zai'):
    key = providers.get(name, {}).get('apiKey')
    if isinstance(key, str) and key and not key.startswith('{{'):
        print(key)
        raise SystemExit(0)
print('')
PY
)"

if [ -z "$API_KEY" ]; then
  API_KEY="${ZHIPU_API_KEY:-}"
fi

if [ -z "$API_KEY" ]; then
  echo "No valid key found in zhipu/zai provider or ZHIPU_API_KEY" >&2
  exit 1
fi

curl --request POST \
  --url https://open.bigmodel.cn/api/paas/v4/web_search \
  --header "Authorization: Bearer $API_KEY" \
  --header 'Content-Type: application/json' \
  --data "{\"search_query\":\"${QUERY}\",\"search_engine\":\"search_std\",\"search_intent\":false,\"count\":10,\"search_recency_filter\":\"noLimit\",\"content_size\":\"medium\"}"
```

## 参数建议

- `count`: 3-10
- `content_size`: `small` / `medium` / `large`
- `search_recency_filter`: `noLimit` / `day` / `week` / `month` / `year`

## 使用方式

用户说“搜索 XX”时，按上面的模板执行一次 `curl`，然后把结果整理成标题、链接、摘要返回即可。

