# web-search-zai

轻量版 Markdown skill，不需要 Python/TS 服务，不需要 MCP 常驻进程。

## 工作方式

- 不调用时不启动
- 调用时才执行一次 `curl`
- API key 从 `~/.clawdbot/clawdbot.json` 读取（仅 `zhipu` / `zai`）

## 目录

- `SKILL.md`: 调用模板和读取 key 逻辑
- `_meta.json`: 元信息

## 说明

如果远程配置是 `any` provider + `{{.ApiKey}}` 模板，这个 skill 不会把它当作有效 key。  
需要在远程配置里补 `zhipu` 或 `zai` 的真实 `apiKey`，或者设置 `ZHIPU_API_KEY` 环境变量。

