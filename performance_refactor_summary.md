# Neovim-Only Performance Rewrite Plan

## Summary

- 目标：优先解决 `autoinst` / `autowire` 性能问题，并把 `RtlTree` 改成普通 buffer 语义，不再自动打开垂直分屏。
- 结论：换语言本身不会自动变快；如果只是把现有 Vimscript 逐行搬到 Lua，收益有限。真正的提速来自两件事一起做：`Lua + 单次解析 + 缓存 + 批量 buffer 更新`。
- 定位：项目改为 `Neovim-only`，最低目标 `Neovim >= 0.9`。不再兼容旧 Vim。
- 用户入口保持不变：继续保留 `:RtlTree`、`g:AutoInst()`、`g:AutoWire()`、`g:AutoDef()` 等命令名和注释标记（如 `/*autoinst*/`、`/*autowire*/`）。

## Implementation Changes

- 新架构放在 `lua/automatic_verilog/`，入口只保留一个很薄的 `plugin/` 层做命令注册和 `vim.g.atv_*` 兼容读取。
- 建立两个缓存层：
  - `project index cache`：缓存 `module -> file`、`file -> dir`、crossdir/filelist/tags 结果；只在相关配置变化、文件写回、显式 refresh 时失效。
  - `parse cache`：按 `absolute path + mtime` 缓存模块解析结果；对当前已修改 buffer 优先读取内存内容，不读磁盘旧内容。
- 重写解析核心为单次扫描 IR，不再在同一流程里多次 `search()` / `getline()` / `readfile()` / 重复正则遍历。
  - `autoinst`：当前 buffer 只解析一次；目标模块文件只解析一次；同一个模块的 `io_seqs` 和 `io_names` 从同一份 IR 派生，不再重复调用 `GetIO`。
  - `autowire`：单次解析当前模块，统一产出已声明 wire、实例端口连接、自动生成区已有内容，再一次性计算新增/保留/删除项。
  - `autodef`：直接复用 `autoreg/autowire` 的同一份 IR，不再额外做整文件重复扫描。
- 所有内容写回改为 `nvim_buf_set_lines()` 批量更新，禁止用“移动光标 + 删除/插入一行行执行”的方式生成结果。
- `RtlTree` 改成普通 scratch buffer：
  - `:RtlTree` 只在当前窗口打开/复用 `RtlTree(<top>)` buffer，不创建 `vsp`。
  - buffer 设为 `buftype=nofile`、`bufhidden=hide`、`buflisted`，这样用户可以用 `:buffer` 找回它。
  - `q` 执行 `:bdelete` 当前树 buffer，不改窗口布局。
  - `o` 在当前窗口 `:edit` 到模块定义；`i` 在当前窗口跳到实例位置。
  - 移除 `g:atv_rtl_split` 和 `s` 的“强制 split”语义；帮助文本同步更新。
- `RtlTree` 数据构建也复用 `project index cache + parse cache`，避免每次展开节点都重新 `readfile()` 和全量解析。

## Public API / Behavior Changes

- 保留现有命令名和注释标记，尽量不改用户使用方式。
- 行为变更：
  - `:RtlTree` 不再自动开垂直分屏。
  - `RtlTree` 关闭行为从“关窗口”改为“删 tree buffer”。
  - `g:atv_rtl_split` 废弃。
- 配置兼容：
  - 继续读取现有 `g:atv_*` 变量。
  - v1 重写不引入 tree-sitter 依赖；先用纯 Lua 解析器做性能版，后续再考虑 AST 升级。

## Test Plan

- 功能回归：
  - `autoinst`：单实例、全文件实例、多模块同文件、`ifdef`、注释、保留用户改动、跨目录解析。
  - `autowire`：已有 wire、自动区增删、复杂赋值、拼接、位宽传播、实例输出生成。
  - `autodef`：复用新 IR 后结果与 `autoreg + autowire` 一致。
  - `RtlTree`：打开、刷新、折叠、跳模块、跳实例、关闭后可通过 buffer 列表找回。
- 性能基准：
  - 冷缓存和热缓存分别测 `AutoInst(1)`、`AutoWire()`、`:RtlTree` 初次构建。
  - 基准文件至少覆盖“大 top + 多实例”场景和“多目录 crossdir”场景。
  - 验收目标：热缓存下 `autoinst` 和 `autowire` 至少达到当前实现的明显可感知提速；计划中以 `3x+` 为目标线，若未达到则继续分析热点而不是直接收尾。
- 测试方式：
  - 用 headless Neovim Lua 测试，不引入额外测试框架依赖。
  - 建 `tests/fixtures` 放 Verilog 样例，`tests/` 里做输出比对和基准脚本。

## Assumptions and Defaults

- 这是一次直接的 `Neovim-only` 重构，不保留旧 Vim 兼容分支。
- 第一版重写聚焦 `autoinst`、`autowire`、`autodef`、`RtlTree` 四块；`autopara/autoarg/snippet/timewave` 暂不迁移，除非为共享基础设施必须做最小适配。
- 性能优先于完全保留旧实现内部结构；但用户可见命令名、注释标记和主要生成格式默认保持稳定。
- 对“换语言会不会更快”的最终判断：会更快，但前提是同时改掉当前的重复扫描/重复读文件/逐行编辑模型；如果不改算法，单纯换成 Lua 不值得。
