# Repository Guidelines

## Project Structure & Module Organization
`plugin/` contains the Vim runtime files shipped to users. Use [`plugin/automatic.vim`](/Users/xiashaobang/workspace/automatic-verilog/plugin/automatic.vim) as the entry point; it loads feature modules from [`plugin/automatic/`](/Users/xiashaobang/workspace/automatic-verilog/plugin/automatic), including `autoinst.vim`, `autopara.vim`, `autodef.vim`, `autoarg.vim`, `crossdir.vim`, and `rtl.vim`. Keep reusable Verilog templates in [`plugin/template/`](/Users/xiashaobang/workspace/automatic-verilog/plugin/template). Documentation lives in [`docs/`](/Users/xiashaobang/workspace/automatic-verilog/docs), and demo GIFs used by the README live in [`demo/`](/Users/xiashaobang/workspace/automatic-verilog/demo).

## Build, Test, and Development Commands
There is no build step. Development is a Vim runtime workflow.

- Install locally by copying `plugin/` into your Vim runtime, or with `Plug 'HonkW93/automatic-verilog'`.
- Smoke-test the repo version directly:
  ```sh
  vim -Nu NONE -c 'set runtimepath^=.' -c 'runtime plugin/automatic.vim'
  ```
- Regenerate help context by reopening Vim and sourcing a changed file with `:source %`.
- Validate docs changes by checking [`README.md`](/Users/xiashaobang/workspace/automatic-verilog/README.md), [`README_en.md`](/Users/xiashaobang/workspace/automatic-verilog/README_en.md), and files under [`docs/`](/Users/xiashaobang/workspace/automatic-verilog/docs).

## Coding Style & Naming Conventions
Write portable Vimscript compatible with older Vim releases; avoid relying on newer Neovim-only features. Follow the existing style: 4-space indentation, quoted comment banners, `g:` for public functions and user configuration, and `s:` for script-local helpers. Name new user-facing globals with the `g:atv_` prefix. Keep feature logic in the matching module file instead of expanding [`plugin/automatic.vim`](/Users/xiashaobang/workspace/automatic-verilog/plugin/automatic.vim).

## Testing Guidelines
This repository does not include an automated test suite. Verify changes manually in Vim against realistic Verilog buffers and the affected command path, for example `:call g:AutoInst(0)`, `:call g:AutoPara(1)`, `:call g:AutoDef()`, or `:RtlTree`. When changing parsing logic, test comments, `ifdef` blocks, multi-module files, and cross-directory lookups.

## Commit & Pull Request Guidelines
Recent history uses `type(scope): summary`, for example `feat(autoinst): ...`, `fix(crossdir): ...`, and `docs(readme): ...`. Keep commits scoped to one feature area when possible. PRs should describe the user-visible behavior change, list the Vim commands exercised during manual testing, link related issues, and include before/after snippets or GIFs for changes that affect generated code layout or UI behavior.

## Configuration Tips
Prefer user configuration through `g:atv_*` globals instead of editing plugin defaults directly. That keeps upgrades safe and matches the guidance in [`docs/install.md`](/Users/xiashaobang/workspace/automatic-verilog/docs/install.md).
