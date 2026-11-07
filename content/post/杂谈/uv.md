---
title: uv
description: 介绍了Python项目管理中"pip+venv"的另一个平替工具uv

date: 2026-11-07T20:18:34+08:00
lastmod: 2026-11-07T20:18:34+08:00
tags:
 - 工具
 - 杂谈
 - python
categories:
 - 杂谈
math: false
mermaid: false
weight: 1000000005
---

# uv

## 1. uv 是什么

`uv` 是 Astral 开发的 Python 工具，覆盖 Python 安装、虚拟环境、项目依赖、锁定、脚本、独立命令行工具、构建和发布等工作。可以把它理解为一套相互衔接的工作流，而不是仅仅一个更快的 `pip`。官方介绍见 [uv 首页](https://docs.astral.sh/uv/)和[功能概览](https://docs.astral.sh/uv/getting-started/features/)。

![uv 的主要工作流](/images/unit/1000000005/1.svg)

| 你的任务 | 常用命令 | 关键产物 |
|---|---|---|
| 管理 Python | `uv python install 3.12`、`uv python pin 3.12` | `.python-version` |
| 创建项目 | `uv init my-app` | `pyproject.toml` |
| 增删项目依赖 | `uv add httpx`、`uv remove httpx` | `pyproject.toml`、`uv.lock` |
| 运行项目 | `uv run python main.py` | 自动使用项目环境 |
| 对齐项目环境 | `uv sync` | `.venv` |
| 临时运行工具 | `uvx ruff check .` | 隔离的工具环境 |
| 沿用 requirements | `uv pip install -r requirements.txt` | 指定虚拟环境中的包 |

**三个最容易混淆的概念：**

- `pyproject.toml` 声明项目允许的依赖范围及配置，适合人工维护。
- `uv.lock` 记录已解析的精确依赖结果，团队项目通常应提交到版本控制。它是 uv 的跨平台锁文件，不等同于纯文本 `requirements.txt`。
- `.venv` 是本机可重建的虚拟环境，通常不提交到版本控制。`uv sync` 可按项目声明和锁文件重建它。

## 2. 安装与检查

### Windows PowerShell

```powershell
# 运行官方 Windows 安装脚本，安装 uv。
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
# 确认 uv 已安装，并查看版本号。
uv --version
```

### macOS / Linux

```bash
# 下载并运行官方 macOS/Linux 安装脚本。
curl -LsSf https://astral.sh/uv/install.sh | sh
# 确认 uv 已安装，并查看版本号。
uv --version
```

安装脚本和其他方式见[官方安装指南](https://docs.astral.sh/uv/getting-started/installation/)。若已装 `pipx`，也可 `pipx install uv`。如果终端提示找不到 `uv`，先重开终端，再检查安装器输出中的 PATH 提示。

```powershell
# 查看 uv 的总帮助。
uv help
# 查看 Python 版本管理子命令的帮助。
uv python --help
# 查看添加依赖命令的参数。
uv add --help
```

> 提醒：`uv` 本身可独立安装；运行 Python 程序时，uv 可以发现系统已有 Python，也可以按需下载它管理的 Python。首次安装解释器和依赖通常需要网络。

## 3. 五分钟上手

下面从一个**完全空的目录**开始，逐步完成用 `python -m venv` + `pip` 时会做的事。命令以 Windows PowerShell 为例。各步骤请在同一个终端按顺序执行。

### 第 1 步：把空目录变成 uv 项目

```powershell
# 创建一个空项目目录。
New-Item -ItemType Directory -Path hello-uv
# 进入新建的项目目录。
Set-Location hello-uv
# 在当前目录生成 uv 项目文件。
uv init .
# 列出当前目录文件，包括隐藏文件。
Get-ChildItem -Force
```

`uv init .` 在**当前目录**建立项目，主要创建 `pyproject.toml` 等初始文件；此时不需要先运行 `pip`，也不需要手动激活环境。`pyproject.toml` 是依赖清单的主要来源。若目录已经存在，直接 `Set-Location` 进去并运行 `uv init .` 即可；如果已有 `pyproject.toml`，不要重复初始化。

### 第 2 步：添加依赖，同时得到隔离环境

```powershell
# 把 rich 加入项目依赖，并同步项目环境。
uv add rich
# 把 httpx 加入项目依赖，并更新锁文件和环境。
uv add httpx
# 检查隔离环境、项目声明和锁文件是否已生成。
Get-ChildItem -Force .venv, pyproject.toml, uv.lock
# 打印 uv 实际使用的 Python 路径，确认它位于项目 .venv。
uv run python -c "import sys; print(sys.executable)"
```

第一次 `uv add` 通常会在项目目录下创建 `.venv`，并安装依赖。它还会把直接依赖写入 `pyproject.toml`、把解析出的精确版本写入 `uv.lock`。第二次 `uv add` 更新这两份文件和环境。最后一行应打印当前项目 `.venv` 内的 Python 路径，例如 Windows 上的 `...\hello-uv\.venv\Scripts\python.exe`。这就是与其他项目隔离的环境：另一个项目有自己的 `.venv` 和依赖版本。

| 传统 `venv` + `pip` | uv 项目中的对应操作 |
|---|---|
| `python -m venv .venv` | `uv add ...` / `uv sync` 自动创建；也可手动 `uv venv` |
| 激活 `.venv` 后 `pip install rich` | `uv add rich`，再用 `uv run` 运行 |
| `pip freeze > requirements.txt` | uv 项目通常提交 `pyproject.toml` 与 `uv.lock` |
| 删除 `.venv` 后重新安装 | 删除 `.venv` 后运行 `uv sync` |

`uv run` 会选择项目的 `.venv`，所以日常使用**不必激活**。如果某个旧工具要求激活环境，PowerShell 可运行 `.\.venv\Scripts\Activate.ps1`；macOS/Linux 用 `source .venv/bin/activate`。退出激活状态用 `deactivate`。激活后直接敲 `python` 才会优先指向该环境；没有激活时请用 `uv run python ...`，不要假设系统 `python` 就是项目解释器。

### 第 3 步：写一个真正使用依赖的程序

将下面内容保存为 `main.py`（PowerShell 可直接粘贴整段）：

```powershell
# 将下面的 Python 源码写入 main.py。
@'
import httpx
from rich import print

print("[bold green]Hello, uv![/bold green]")
print("httpx 版本：", httpx.__version__)
'@ | Set-Content -Encoding utf8 main.py
# 在项目隔离环境中运行 main.py。
uv run python main.py
# 查看项目的直接依赖和间接依赖。
uv tree
```

这里没有发起网络请求；程序只是导入两个包并打印版本。`uv tree` 可看到直接依赖和它们带来的间接依赖。若刚才直接运行 `python main.py` 出现 `ModuleNotFoundError`，先确认是否用了系统 Python，改为 `uv run python main.py`。

### 第 4 步：删除一个不再需要的依赖

先把 `main.py` 改为只使用 `rich`，再删除依赖。下面的命令会重写示例中的 `main.py`：

```powershell
# 将下面的 Python 源码写入 main.py。
@'
from rich import print

print("[bold green]Hello, uv![/bold green]")
'@ | Set-Content -Encoding utf8 main.py
# 从项目声明中移除 httpx，并更新锁文件和环境。
uv remove httpx
# 查看项目的直接依赖和间接依赖。
uv tree
# 在项目隔离环境中运行 main.py。
uv run python main.py
```

`uv remove` 会从 `pyproject.toml` 删除直接依赖、更新 `uv.lock`，并同步 `.venv`。先改代码很重要：如果仍然 `import httpx`，再次运行程序自然会报找不到模块。`uv remove` 可能也移除只被 httpx 需要的间接包；仍被其他依赖使用的包会保留。

### 第 5 步：拿到别人项目的 `requirements.txt`，导入依赖

假设对方给你的文件位于 `C:\Users\你\Downloads\other-project\requirements.txt`，内容类似：

```text
requests>=2.31,<3
rich>=13,<15
```

把它复制进**当前项目根目录**，再将其中的依赖纳入 uv 项目：

```powershell
# 把对方的依赖清单复制到当前项目；请替换成真实路径。
Copy-Item "C:\Users\你\Downloads\other-project\requirements.txt" .\requirements.txt
# 读取 requirements.txt，将其中依赖写入 uv 项目并同步。
uv add -r .\requirements.txt
# 查看项目的直接依赖和间接依赖。
uv tree
# 在项目环境里验证导入成功，并显示 requests 版本。
uv run python -c "import requests, rich; print(requests.__version__)"
```

请把示例路径换成你拿到的真实文件路径。`uv add -r` 会读取文件中的包要求并加入当前项目，更新 `pyproject.toml`、`uv.lock` 和 `.venv`。这里 `requests` 是新依赖；已有的 `rich` 可能按文件里的版本范围调整。之后 uv 项目的主依赖来源是 `pyproject.toml` 和 `uv.lock`；原始 `requirements.txt` 可留作迁移记录，但若不继续同步维护，别把它当成另一份永远准确的清单。

如果你只是想像旧项目一样**按 `requirements.txt` 安装到隔离环境**，暂时不转换成 uv 项目，则使用另一条路线：

```powershell
# 使用 Python 3.12 创建项目虚拟环境。
uv venv --python 3.12
# 按 requirements.txt 把包安装进虚拟环境。
uv pip install -r .\requirements.txt
# 列出虚拟环境中已安装的包。
uv pip list
# 直接使用虚拟环境中的 Python 运行程序。
.\.venv\Scripts\python.exe main.py
```

这条路线中的 `uv pip install` 主要操作 `.venv`，**不会自动把依赖写进 `pyproject.toml` 或生成项目 `uv.lock`**。对于要长期维护的新项目，优先用上面的 `uv add -r`。如果对方项目已经有自己的 `pyproject.toml` 和 `uv.lock`，无需另建项目或导入 requirements；进入对方项目目录，直接运行 `uv sync --locked`。

### 第 6 步：在另一台电脑复现

将项目源码、`pyproject.toml` 和 `uv.lock` 一起交给别人，**不需要复制 `.venv`**。对方在项目目录执行：

```powershell
# 检查 uv.lock 与项目声明一致，并据此同步 .venv。
uv sync --locked
# 在项目隔离环境中运行 main.py。
uv run python main.py
```

`uv sync` 会创建或修复本机的 `.venv`；`--locked` 要求锁文件与项目声明一致，适合协作和 CI。日常开发可直接 `uv sync`。如果只拿到一个旧项目的 `requirements.txt`，先决定是继续用 `uv pip install -r` 的旧式流程，还是用 `uv add -r` 迁入 uv 项目。参见[项目入门](https://docs.astral.sh/uv/guides/projects/)、[依赖管理](https://docs.astral.sh/uv/concepts/dependencies/)、[锁定和同步](https://docs.astral.sh/uv/concepts/projects/sync/)与[从 pip 迁移](https://docs.astral.sh/uv/guides/migration/pip-to-project/)。

## 4. Python 版本管理

```powershell
uv python list                 # 查看可用/已安装版本
uv python install 3.12         # 安装 Python 3.12 的最新补丁版
uv python find 3.12            # 查看匹配解释器的位置
uv python pin 3.12             # 为当前目录写入 .python-version
uv run --python 3.12 python -V # 临时指定运行版本
```

`uv python pin 3.12` 固定的是版本选择线索；项目能运行的 Python 范围通常仍在 `pyproject.toml` 的 `requires-python` 中声明，例如 `>=3.12`。两者应保持协调。`uv python install` 默认安装带版本号的可执行文件，不必假设会替换系统的 `python` 命令。详见[安装和管理 Python](https://docs.astral.sh/uv/guides/install-python/)。

### 已有环境中指定解释器

```powershell
# 使用 Python 3.12 创建项目虚拟环境。
uv venv --python 3.12
# 指定 Python 3.12 运行，并打印所用解释器位置。
uv run --python 3.12 python -c "import sys; print(sys.executable)"
```

项目工作流通常无需手动激活 `.venv`；`uv run` 会选择项目环境。若确实需要在 PowerShell 中激活：

```powershell
# 在当前 PowerShell 会话激活 .venv。
.\.venv\Scripts\Activate.ps1
```

macOS/Linux 对应 `source .venv/bin/activate`。激活仅改变当前 shell 的命令查找路径，不会替代依赖声明与锁定。

## 5. 项目、依赖与锁文件

![项目依赖如何流向环境](/images/unit/1000000005/2.svg)

### 5.1 新建应用或可分发包

```powershell
uv init my-app             # 应用项目
uv init --package my-lib   # 可构建、可安装的 Python 包
```

包项目适合要导入自身模块、提供命令入口或发布到包索引的场景。`uv init --help` 可查看当前版本支持的模板选项。

### 5.2 普通依赖

```powershell
# 把 httpx 加入项目依赖，并更新锁文件和环境。
uv add httpx
# 添加带版本范围的 pandas 依赖。
uv add "pandas>=2.2,<3"
# 从项目声明中移除 httpx，并更新锁文件和环境。
uv remove httpx
# 查看项目的直接依赖和间接依赖。
uv tree
```

`uv add` 会编辑 `pyproject.toml`，并默认重新解析、同步；`uv remove` 做相反操作。避免只在 `.venv` 内手动安装而不记录项目依赖，否则别人无法复现。

### 5.3 开发组、其他组和可选功能

```powershell
# 将 pytest 和 ruff 加入默认开发依赖组。
uv add --dev pytest ruff
# 将 mkdocs 加入 docs 依赖组。
uv add --group docs mkdocs
# 为发布包的 plot 可选功能添加 matplotlib。
uv add --optional plot matplotlib
# 同步项目并额外安装 docs 组依赖。
uv sync --group docs
# 同步项目并安装 plot 可选依赖。
uv sync --extra plot
# 同步时排除默认 dev 依赖组。
uv sync --no-dev
```

`dev` 组默认参与同步；`docs` 之类的其他组需要显式指定，除非项目另行配置默认组。`--optional plot` 对应发布元数据中的 extra；开发组则是本地开发需要、通常不随包发布的依赖。请根据用途选用。详见[管理依赖](https://docs.astral.sh/uv/concepts/dependencies/)。

可能的配置形态：

```toml
[project]
name = "my-lib"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = ["httpx>=0.27"]

[project.optional-dependencies]
plot = ["matplotlib>=3.9"]

[dependency-groups]
dev = ["pytest>=8", "ruff>=0.8"]
docs = ["mkdocs>=1.6"]
```

### 5.4 锁定、同步与更新

```powershell
uv lock                         # 更新/生成 uv.lock
uv sync                         # 环境与项目依赖精确同步
uv sync --locked                # 验证锁文件未过期，再同步
uv sync --frozen                # 使用现有锁文件，跳过新鲜度检查
uv lock --upgrade-package httpx # 仅针对指定包请求更新
uv lock --upgrade               # 请求更新所有可更新的包
```

`uv sync` 默认是**精确同步**：会移除不属于所选依赖集的额外包；`uv run` 默认采用非精确同步，通常保留额外包。`--locked` 与 `--frozen` 也不同：前者检查锁文件是否与声明一致，后者跳过检查。团队和 CI 通常使用 `--locked`，只有明确知道锁文件仍可用时才选择 `--frozen`。详见[锁定和同步](https://docs.astral.sh/uv/concepts/projects/sync/)。

### 5.5 提交哪些文件

```gitignore
.venv/
__pycache__/
.pytest_cache/
```

应用项目建议提交 `pyproject.toml`、`uv.lock`、源代码和需要共享的 `.python-version`。不要提交 `.venv`。对发布型库，是否提交锁文件取决于团队需要；提交它有利于复现本项目的开发、测试环境，库消费者仍根据发布的依赖元数据解析自己的环境。

## 6. 运行脚本和命令行工具

### 6.1 项目内运行

```powershell
# 在项目隔离环境中运行 main.py。
uv run python main.py
# 在项目环境中运行测试。
uv run pytest
# 用项目中的 ruff 检查当前目录。
uv run ruff check .
# 打印 uv 实际使用的 Python 路径，确认它位于项目 .venv。
uv run python -c "import sys; print(sys.executable)"
```

前提是对应命令/依赖已加入项目，例如 `uv add --dev pytest ruff`。在项目目录内，`uv run` 会按项目配置选择并准备环境。

### 6.2 单文件脚本与内联依赖

```powershell
# 把 httpx 和 rich 写入 report.py 的内联依赖元数据。
uv add --script report.py httpx rich
# 按脚本的内联依赖运行 report.py。
uv run report.py
# 为独立脚本生成相邻的锁文件。
uv lock --script report.py
```

`uv add --script` 会把依赖写入脚本顶部的 PEP 723 元数据；`uv lock --script` 可在脚本旁创建单独锁文件。下面是可手写的示意：

```python
# /// script
# requires-python = ">=3.12"
# dependencies = ["httpx", "rich"]
# ///

import httpx
from rich import print

response = httpx.get("https://example.com", timeout=10)
print(response.status_code)
```

保存为 `report.py` 后运行 `uv run report.py`。适合一次性脚本或独立小工具；复杂项目仍建议使用 `pyproject.toml`。参见[脚本指南](https://docs.astral.sh/uv/guides/scripts/)。

### 6.3 临时或长期安装工具

```powershell
uvx ruff check .         # 临时运行，uvx 是 uv tool run 的简写
# 临时运行 black 并查看其版本。
uvx black --version
uv tool install ruff     # 长期安装到独立工具环境
# 查看已长期安装的独立命令行工具。
uv tool list
# 在已安装的约束范围内升级 ruff 工具环境。
uv tool upgrade ruff
# 卸载长期安装的 ruff 工具。
uv tool uninstall ruff
```

`uvx` 适合偶尔使用的 CLI；`uv tool install` 适合经常从任意目录调用的 CLI；`uv add --dev ruff` 则把工具版本纳入当前项目的依赖与锁文件。团队要一致的检查结果时，通常采用项目开发依赖并通过 `uv run ruff ...` 调用。参见[工具指南](https://docs.astral.sh/uv/guides/tools/)。

## 7. 兼容 pip 的工作流

已有 `requirements.txt` 的项目可渐进采用 uv：

```powershell
# 使用 Python 3.12 创建项目虚拟环境。
uv venv --python 3.12
# 按 requirements.txt 在选定虚拟环境安装包。
uv pip install -r requirements.txt
# 列出虚拟环境中已安装的包。
uv pip list
# 输出当前环境中已安装包的固定版本清单。
uv pip freeze
```

`uv pip` 操作的是选定的 Python 环境，并不会自动把依赖写进 `pyproject.toml`。若想从宽松输入文件生成固定版本清单：

```powershell
# 解析宽松依赖并生成固定版本的 requirements.txt。
uv pip compile requirements.in -o requirements.txt
# 让虚拟环境精确匹配 requirements.txt。
uv pip sync requirements.txt
```

这里的 `uv pip sync` 与项目 `uv sync` 是两条不同路线：前者以 requirements 文件为准，后者以 `pyproject.toml` / `uv.lock` 为准。一个项目最好确定主要依赖来源，避免两份声明长期分叉。参见[功能概览](https://docs.astral.sh/uv/getting-started/features/)和[从 pip 迁移](https://docs.astral.sh/uv/guides/migration/pip-to-project/)。

## 8. 进阶用法

### 8.1 多包工作区

当仓库同时包含应用与内部库时，可共享一个 `uv.lock`：

```text
repo/
├── pyproject.toml
├── uv.lock
├── apps/api/pyproject.toml
└── packages/core/pyproject.toml
```

根项目的配置示例：

```toml
[tool.uv.workspace]
members = ["apps/*", "packages/*"]

[tool.uv.sources]
core = { workspace = true }
```

如果根项目依赖 `core`，还需在其 `[project].dependencies` 中声明 `core`。工作区统一锁定，`uv run --package core ...` 或 `uv sync --package core` 针对成员运行/同步；默认针对工作区根项目。成员包名以其 `pyproject.toml` 为准。参见[工作区文档](https://docs.astral.sh/uv/concepts/projects/workspaces/)。

### 8.2 本地路径和 Git 依赖

```powershell
# 把相邻的本地包以可编辑模式加入项目。
uv add --editable ../my-lib
# 从 Git 仓库添加依赖；示意地址需替换。
uv add "git+https://github.com/example/example.git"
```

本地可编辑依赖适合并行开发。Git 依赖应优先锁到可复现的提交或明确标签；对第三方项目填写真实仓库地址，示意地址不可直接运行。检查 `pyproject.toml` 的 `[tool.uv.sources]` 和锁文件，确保来源符合预期。参见[依赖来源](https://docs.astral.sh/uv/concepts/dependencies/)。

### 8.3 CI 中复现环境

通用步骤：检出代码，安装 uv，执行 `uv sync --locked`，再执行 `uv run pytest`。例如本机模拟：

```powershell
# 检查 uv.lock 与项目声明一致，并据此同步 .venv。
uv sync --locked
# 在项目环境中运行简洁输出的测试。
uv run pytest -q
# 用项目中的 ruff 检查当前目录。
uv run ruff check .
```

CI 应使用与项目兼容的 Python；如果需固定主次版本，可提交 `.python-version`。对需要与发布环境一致的检查，按需选择 `uv sync --locked --no-dev`，但那样不会安装放在 `dev` 组的 pytest/ruff。

### 8.4 Docker 中分层安装

以下示例使用 Docker BuildKit 缓存挂载；实际基础镜像与 Python 版本要和项目要求匹配：

```dockerfile
# 以 Python 3.12 的精简镜像作为基础。
FROM python:3.12-slim
# 从官方 uv 镜像复制 uv 和 uvx 可执行文件。
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
# 将容器工作目录设置为 /app。
WORKDIR /app

# 先复制依赖声明与锁文件，以复用依赖安装层。
COPY pyproject.toml uv.lock ./
# 使用构建缓存同步第三方依赖；命令延续到下一行。
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

# 再复制项目源代码。
COPY . .
# 校验锁文件并同步完整项目，同时排除开发依赖。
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-dev

# 让容器优先使用项目虚拟环境中的命令。
ENV PATH="/app/.venv/bin:$PATH"
# 启动容器时运行应用。
CMD ["python", "main.py"]
```

第一层只装依赖以复用镜像缓存；完整源代码拷入后再校验锁文件并同步项目。构建时建议把 uv 镜像固定到团队验证过的版本或 digest，减少构建结果漂移。详见[官方 Docker 指南](https://docs.astral.sh/uv/guides/integration/docker/)。

### 8.5 构建与发布

```powershell
# 新建可构建的包项目。
uv init --package sample-lib
# 进入包项目目录。
Set-Location sample-lib
# 构建源码包和 wheel，产物通常放在 dist 目录。
uv build
```

产物通常在 `dist/`，包含源码包和 wheel。发布前检查包名、版本、许可证、README、构建配置和包内文件；`uv publish` 会上传到包索引，应在确认目标索引和认证方式后执行。详见[构建与发布](https://docs.astral.sh/uv/guides/package/)。

### 8.6 缓存与离线

```powershell
# 显示 uv 缓存目录的位置。
uv cache dir
uv cache clean ruff    # 仅清理 ruff 的缓存条目
uv cache clean         # 清理全部 uv 缓存
uv sync --offline      # 只使用可用的本地缓存
```

离线模式只有在所需 Python、元数据、包文件等已可用时才能成功。不要直接手动删除或修改 uv 缓存内部文件；使用 `uv cache` 命令。参见[缓存机制](https://docs.astral.sh/uv/concepts/cache/)。

## 9. 完整实战：一个小型数据抓取项目

目标：请求一个网页，输出 HTTP 状态，并用测试验证 URL 检查逻辑。下面命令在 PowerShell 中逐段执行。

### 第一步：创建项目与依赖

```powershell
# 创建以 Python 3.12 为最低目标版本的新项目。
uv init --python 3.12 web-status
# 进入实战项目目录。
Set-Location web-status
# 在当前项目写入 .python-version，选择 Python 3.12。
uv python pin 3.12
# 把 httpx 加入项目依赖，并更新锁文件和环境。
uv add httpx
# 将 pytest 和 ruff 加入默认开发依赖组。
uv add --dev pytest ruff
```

### 第二步：编写程序

把以下内容保存为 `main.py`：

```python
import sys

import httpx


def check_url(url: str) -> int:
    if not url.startswith(("http://", "https://")):
        raise ValueError("URL 必须以 http:// 或 https:// 开头")
    response = httpx.get(url, timeout=10, follow_redirects=True)
    return response.status_code


if __name__ == "__main__":
    url = sys.argv[1] if len(sys.argv) > 1 else "https://example.com"
    print(f"{url}: {check_url(url)}")
```

请求需要网络；`example.com` 仅作可公开访问的演示站点，网络受限时可换成自己的测试地址。

### 第三步：编写测试

创建 `tests/test_main.py`：

```python
import pytest

from main import check_url


def test_reject_non_http_url():
    with pytest.raises(ValueError, match="URL 必须"):
        check_url("file:///tmp/demo")
```

测试只验证本地输入校验，不需要外部网络。运行：

```powershell
# 在项目隔离环境中运行 main.py。
uv run python main.py
# 在项目环境中运行简洁输出的测试。
uv run pytest -q
# 用项目中的 ruff 检查当前目录。
uv run ruff check .
# 查看项目的直接依赖和间接依赖。
uv tree
```

### 第四步：复现与交付

将 `pyproject.toml`、`uv.lock`、`.python-version`、`main.py`、`tests/` 提交到版本控制；另一个开发者执行：

```powershell
# 检查 uv.lock 与项目声明一致，并据此同步 .venv。
uv sync --locked
# 在项目环境中运行简洁输出的测试。
uv run pytest -q
```

这个例子展示了声明依赖、锁定版本、自动建环境、运行命令和复现环境的完整路径。

## 10. 常见问题与命令速查

### 常见问题

**`uv run` 和直接运行 `python` 有什么区别？** `uv run` 会使用项目环境，必要时先检查锁文件并同步依赖；直接运行 `python` 取决于当前 shell 的 PATH，可能落到系统解释器。

**为什么 `uv sync` 后一个手动安装的包消失了？** 项目同步默认是精确的，未在选定依赖集中声明的包可能被移除。把它加入项目依赖，或在确实需要保留额外包时使用 `uv sync --inexact`。

**`uv.lock` 和 `requirements.txt` 能混用吗？** 可以从项目导出 requirements 给其他工具，但维护时应明确主来源。纯 `uv pip` 工作流可继续使用 requirements；uv 项目工作流以 `pyproject.toml` 和 `uv.lock` 为主。

**为何 `uv sync --locked` 失败？** 通常是修改了 `pyproject.toml` 而没有更新 `uv.lock`。开发阶段执行 `uv lock` 或 `uv sync`，检查差异并提交锁文件；CI 再用 `--locked` 验证。

**安装 Python 或包失败怎么办？** 先看具体错误是否为网络、代理、索引、Python 版本约束或平台轮子问题；用 `uv -v <命令>` 查看更详细输出，再核对项目的 `requires-python` 与包版本。

### 命令速查

| 场景 | 命令 |
|---|---|
| 检查版本 | `uv --version` |
| 新建项目 | `uv init NAME` |
| 安装 Python | `uv python install 3.12` |
| 固定项目 Python | `uv python pin 3.12` |
| 添加运行依赖 | `uv add PACKAGE` |
| 添加开发依赖 | `uv add --dev PACKAGE` |
| 删除依赖 | `uv remove PACKAGE` |
| 锁定依赖 | `uv lock` |
| 同步环境 | `uv sync` |
| 按锁文件验证并同步 | `uv sync --locked` |
| 运行项目命令 | `uv run COMMAND` |
| 查看依赖树 | `uv tree` |
| 临时运行工具 | `uvx TOOL` |
| 创建虚拟环境 | `uv venv` |
| 从 requirements 安装 | `uv pip install -r requirements.txt` |
| 构建包 | `uv build` |

## 官方资料

- [uv 官方文档首页](https://docs.astral.sh/uv/)
- [安装指南](https://docs.astral.sh/uv/getting-started/installation/)
- [项目指南](https://docs.astral.sh/uv/guides/projects/)
- [依赖与锁定](https://docs.astral.sh/uv/concepts/dependencies/)、[同步机制](https://docs.astral.sh/uv/concepts/projects/sync/)
- [脚本](https://docs.astral.sh/uv/guides/scripts/)、[工具](https://docs.astral.sh/uv/guides/tools/)、[工作区](https://docs.astral.sh/uv/concepts/projects/workspaces/)
- [命令参考](https://docs.astral.sh/uv/reference/cli/)
