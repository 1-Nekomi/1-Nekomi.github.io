---
title: python中的虚拟环境
description: 介绍python中虚拟环境的概念，以及如何为项目创建一个虚拟环境

date: 2026-08-25T15:17:14+08:00
lastmod: 2026-08-25T15:17:14+08:00
tags:
 - 虚拟环境
 - python
 - 概念
categories:
 - python
math: false
mermaid: false
weight: 1003004000
---

# python中的虚拟环境

​    在对python有了基础认知后，在着手于开发项目前，我们先需要了解 **虚拟环境（Virtual Environment）** 这个重要概念。虚拟环境有助于更好地管理项目中的解释器版本和第三方库。

​    在python中有许多第三方库，其中有一些第三方库是存在依赖冲突的。例如全局环境下同时需要安装第三方库A、B、C，项目1需要使用A，项目2需要使用C。但A依赖于B的v1.0版本，C依赖于B的v2.0版本，假设我安装了B的v1.0版本就无法使用C，反之安装B的v2.0版本就无法使用A。而这会导致两个项目都无法正常运行，这个时候就需要使用虚拟环境来对环境进行隔离。

   Python中创建虚拟环境的常见方法主要有五种：`venv`、`virtualenv`、`pipenv`、`poetry`和`conda`。

下面的表格是它们的区别：

| 工具             | 核心特点                                                     | 适用场景                               |
| :--------------- | :----------------------------------------------------------- | :------------------------------------- |
| **`venv`**       | Python 3.3+ 内置，轻量级，只负责环境隔离                     | 简单脚本、入门学习、传统项目           |
| **`virtualenv`** | 第三方工具，功能比 `venv` 更丰富，支持旧版 Python            | 需要兼容旧版 Python 的项目             |
| **`pipenv`**     | 整合了 `pip` 和 `venv`，使用 `Pipfile` 和 `Pipfile.lock` 管理依赖 | Web 开发等通用 Python 应用             |
| **`poetry`**     | 现代化工具，依赖解析强大，集成了构建和打包功能               | 中大型项目，需要严格依赖管理和打包发布 |
| **`conda`**      | 不仅管理 Python 包，还能管理非 Python 的库，适合数据科学     | 数据科学、机器学习项目                 |

## venv

​    该模块从Python3.3后就作为标准库内置在python中，因此不需要额外安装就可以使用。

### 创建虚拟环境

​    在项目目录下运行命令：
~~~bash
# Linux/macOS
python3 -m venv <Your_venv_name>

# Windows
python -m venv <Your_venv_name>
~~~

这会在该目录下创建一个名为`<Your_venv_name>`的文件夹。

> [!TIP]
>
> 社区惯例一般是将虚拟环境名规定为`.venv`

### 激活环境    

​    接着就可以激活虚拟环境：

~~~bash
# Linux/macOS
source <Your_venv_name>/bin/activate

# Windows-CMD
<Your_venv_name>\Scripts\activate

# Windows-PowerShell
<Your_venv_name>\Scripts\activate.ps1
~~~

如果激活成功，命令行提示符前面会显示虚拟环境名`<Your_venv_name>`。

### 管理依赖

​    在虚拟环境中可以像平时一样使用`pip`包管理器安装依赖，每个虚拟环境中的依赖互不影响。

~~~bash
# 安装依赖
pip install <package_name>

# 导出项目依赖到 requirements.txt
pip freeze > requirements.txt

# 在新环境中安装已确定的依赖
pip install -r requirements.txt
~~~

### 退出虚拟环境

​    在虚拟环境中工作完成需要退出环境。

~~~bash
deactivate
~~~

---

venv一般适用于绝大部分情况下的python项目开发，但需要注意其不适用于旧版本的python项目。

---

## virtualenv

​    适用于老版本的python(<3.3)项目，当然也适用于新版本python(>=3.3)项目。

### 安装

​    `virtualenv`属于第三方库，因此需要先安装：
~~~bash
pip install virtualenv
~~~

### 创建虚拟环境

```bash
virtualenv <Your_venv_name>
```

---

后续的激活、安装依赖、与退出与`venv`一致。

---

## pipenv

​    `pipenv`主要是将`pip`和`venv`的工作流整合在一起，自动管理虚拟环境和依赖。

### 安装

​    `pipenv`属于第三方库，因此需要先进行安装：
~~~bash
pip install pipenv
~~~

### 创建虚拟环境

​    在项目目录下执行：
~~~bash
pipenv [--python <python_version>] install
~~~

会自动创建虚拟环境并生成`Pipfile`和`Pipfile.lock`依赖包管理文件，将项目分享给其他人时，执行该命令会创建一个虚拟环境并自动安装文件`Pipfile`中的依赖包。

### 激活与运行命令

激活虚拟环境：`pipenv shell`

在虚拟环境中运行命令：`pipenv run <command>`

### 安装与卸载依赖

用包名安装并写入`Pipfile`：`pipenv install <package_name> [--dev]`

安装`Pipfile`中的依赖包:`pipenv install [--dev]`

> [!TIP]
>
> 其中`--dev`参数表示 **将依赖安装在虚拟环境中的开发环境** ，如果不带这个参数则默认安装在 **生产环境** 中。

卸载依赖包并从`Pipfile`中移除：`pipenv uninstall <package_name>`

卸载所有包：`pipenv uninstall --all[-dev]`

> [!NOTE]
>
> 如果在卸载所有包时带上`-dev`附加参数，则会卸载所有开发环境包并从`Pipfile`中移除，否则只会删除所有生产环境包。

## poetry

​    一种现代工具，不仅可以管理依赖还可以负责项目的构建和打包。

### 安装

​    根据官方文档，建议将`portry`安装在虚拟环境中。

~~~bash
# 可能需要 pipx
pip install poetry

# 安装脚本Linux/macOS/Windows-WSL
curl -sSL https://install.python-poetry.org | python3 -

# Windows-PowerShell
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python
~~~

### 创建新项目

~~~bash
#会在目录下创建标准项目结构，并包含pyproject.toml文件。
poetry new <project_name> 

#在已有项目中使用会交互式地引导创建`pyproject.toml`文件。
poetry init 
~~~

### 激活和运行命令

​    poetry不需要手动激活环境，同时可以使用`potry run <command>`来运行命令。也可以使用`potry shell`来进入一个子shell。

### 安装和卸载包

~~~bash
poetry add <requests> [--dev]
poetry remove <requests>
~~~

## conda

​    `conda`是Anaconda发行版中的包和环境管理器，在数据科学和机器学习领域非常流行。

### 安装

​    需要先安装 **Anaconda或者Miniconda** ，这里因篇幅问题不介绍安装过程。

### 创建环境

~~~bash
conda create -n <venv_name> python=<python_version>
~~~

### 激活环境

~~~bash
conda activate <venv_name>
~~~

### 安装依赖包

~~~bash
conda install <requests>
~~~

### 退出环境

~~~bash
conda deactivate
~~~

