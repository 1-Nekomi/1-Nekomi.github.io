---
title: Docker
description: 在Unbuntu22.04环境下学习Docker的记录，包含如何安装、使用

date: 2026-11-07T16:07:57+08:00
lastmod: 2026-11-07T16:07:57+08:00
tags:
 - 杂谈
 - 工具
 - Docker
categories:
 - 杂谈
math: false
mermaid: false
weight: 1000000004
---

# Docker

有时候计算机编程所花费的时间不一定都是在敲代码这件事上，我算是深有体会吧，有时候为了完成一个项目，配置环境能花费我一下午甚至于一整天的时间。而 **Docker** 作为一个工具，解决的就是这个问题。简单来说 Docker 使用轻量级的容器（container）而不是整个操作系统去支持一个应用的配置。应用自身连同它的环境配置被打包为一个个 image 可以自由运行在不同平台的一个个 container 中，这极大地节省了所有人的时间成本。

本文主要讲解如何在 Ubuntu22.04 环境下安装 Docker ，以及一些学习过程中学习到的 Docker 基础用法。

在正式接触 Docker 前，我们先了解一下基础概念。

## 概念

### 容器

容器是 **镜像（image）** 的一个运行实例，每个容器都是互相隔离的，但容器之间会共享一些资源，例如OS_kernel。各个容器都拥有自己的process、Network、Mounts，有点类似于虚拟机，但与虚拟机不同的是，容器并没有使用另一个OS_kernel，而是通过Docker管理来共享 OS_kernel ，如下图所示：

![容器和虚拟机的区别](/images/unit/1000000004/1.jpeg)

在上图中，列出了容器和虚拟机的区别，可以看到虚拟机主要是依赖其内的另一个OS内核来管理本应用的库和依赖，这就导致了如果使用虚拟机来管理应用会十分笨重且臃肿， **占用空间大，启动时间长，资源消耗量大** 。但对于容器，其就十分轻量，一个容器内就只包含应用和其库、依赖，并不包含一套完整的OS内核。

但这也说明了容器的隔离性并没有虚拟机那么好，有一些资源需要让容器之间互相竞争来得到，这就需要依赖Docker来进行管理。

### 镜像

正如上面所说，容器是镜像的一个运行实例，可以简单理解成进程和PCB（进程控制表）之间的关系（但不完全等同这种关系），镜像说明如何按照模板创建一个容器实例。一个镜像可以同时创建多个容器实例，但一个容器实例只能对应一个镜像。

## 安装Docker

需要注意的是Docker依赖于Linux内核环境，因此对于Mac和Windows，如果要安装Docker，只能先安装一个Linux VM，然后将Docker安装在Linux VM中。现在以ubuntu22.04-LTS为例，说明在其上安装Docker的步骤。

以下内容来自 [Ubuntu Docker 安装 | 菜鸟教程](https://www.runoob.com/docker/ubuntu-docker-install.html) 。

### 使用官方脚本自动安装

~~~bash
# 下载并执行Docker官方安装脚本
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 启动Docker服务
sudo systemctl start docker
sudo systemctl enable docker
~~~

### 手动安装

#### 卸载旧版本

Docker 的旧版本被称为 docker，docker.io 或 docker-engine 。如果已安装，请卸载它们：

```bash
$ sudo apt-get remove docker docker-engine docker.io containerd runc
```

当前称为 Docker Engine-Community 软件包 docker-ce 。

安装 Docker Engine-Community，以下介绍两种方式。

#### 使用 Docker 仓库进行安装

在新主机上首次安装 Docker Engine-Community 之前，需要设置 Docker 仓库。之后，您可以从仓库安装和更新 Docker 。

#### 设置仓库

更新 apt 包索引。

```
$ sudo apt-get update
```

安装 apt 依赖包，用于通过HTTPS来获取仓库:

~~~bash
$ sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common
~~~

添加 Docker 的官方 GPG 密钥：

```bash
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
```

使用以下指令设置稳定版仓库
~~~bash
echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/ \
 $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
~~~

#### 安装 Docker Engine-Community

更新 apt 包索引。

```bash
$ sudo apt-get update
```

安装最新版本的 Docker Engine-Community 和 containerd ，或者转到下一步安装特定版本：

```bash
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

要安装特定版本的 Docker Engine-Community，请在仓库中列出可用版本，然后选择一种安装。列出您的仓库中可用的版本：
~~~bash
$ apt-cache madison docker-ce

  docker-ce | 5:18.09.1~3-0~ubuntu-xenial | https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu  xenial/stable amd64 Packages
  docker-ce | 5:18.09.0~3-0~ubuntu-xenial | https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu  xenial/stable amd64 Packages
  docker-ce | 18.06.1~ce~3-0~ubuntu       | https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu  xenial/stable amd64 Packages
  docker-ce | 18.06.0~ce~3-0~ubuntu       | https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu  xenial/stable amd64 Packages
  ...
~~~

使用第二列中的版本字符串安装特定版本，例如 5:18.09.1~3-0~ubuntu-xenial。

```bash
$ sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io
```

测试 Docker 是否安装成功，输入以下指令，打印出以下信息则安装成功:

~~~bash
$ sudo docker run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
1b930d010525: Pull complete                                                                                                                                  Digest: sha256:c3b4ada4687bbaa170745b3e4dd8ac3f194ca95b2d0518b417fb47e5879d9b5f
Status: Downloaded newer image for hello-world:latest


Hello from Docker!
This message shows that your installation appears to be working correctly.


To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.


To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash


Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/


For more examples and ideas, visit:
 https://docs.docker.com/get-started/
~~~

### 使用 Shell 脚本进行安装

Docker 在 [get.docker.com ](https://get.docker.com/)和 [test.docker.com](https://test.docker.com/) 上提供了方便脚本，用于将快速安装 Docker Engine-Community 的边缘版本和测试版本。脚本的源代码在 docker-install 仓库中。 不建议在生产环境中使用这些脚本，在使用它们之前，您应该了解潜在的风险：

- 脚本需要运行 root 或具有 sudo 特权。因此，在运行脚本之前，应仔细检查和审核脚本。
- 这些脚本尝试检测 Linux 发行版和版本，并为您配置软件包管理系统。此外，脚本不允许您自定义任何安装参数。从 Docker 的角度或您自己组织的准则和标准的角度来看，这可能导致不支持的配置。
- 这些脚本将安装软件包管理器的所有依赖项和建议，而无需进行确认。这可能会安装大量软件包，具体取决于主机的当前配置。
- 该脚本未提供用于指定要安装哪个版本的 Docker 的选项，而是安装了在 edge 通道中发布的最新版本。
- 如果已使用其他机制将 Docker 安装在主机上，请不要使用便捷脚本。

本示例使用 [get.docker.com ](https://get.docker.com/)上的脚本在 Linux 上安装最新版本的Docker Engine-Community。要安装最新的测试版本，请改用 test.docker.com。在下面的每个命令，取代每次出现 get 用 test。

```bash
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh
```

如果要使用 Docker 作为非 root 用户，则应考虑使用类似以下方式将用户添加到 docker 组：

```bash
$ sudo usermod -aG docker your-user
```

### 卸载 docker

删除安装包：

```bash
sudo apt-get purge docker-ce
```

删除镜像、容器、配置文件等内容：

```bash
sudo rm -rf /var/lib/docker
```

> [!Tip]
>
> 如果是windows或者mac操作系统，直接安装Docker Desktop也许是更好的选择。

## Docker命令

常见的命令如下所示：

|                命令                 |                             含义                             |                      常见附带参数OPTION                      |
| :---------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
|   `docker run [OPTION] <images>`    | 利用指定镜像实例化一个容器运行<br />后可以跟附加command `sleep <numbers>`让容器休眠numbers秒后再启动 | `-d`:让容器后台运行，返回容器id<br />`--name <string>`：给容器命名string |
|        `docker ps [OPTION]`         |                    显示正在运行状态的容器                    |                    `-a`：显示所有状态容器                    |
|   `docker rm $list{<container>}`    |              删除指定的容器，可以给定名字或者id              |                                                              |
|    `docker rmi $list{<images>}`     |               删除指定的镜像，可以给名字或者id               |                                                              |
|  `docker stop $list{<container>}`   |              停止运行指定容器，可以给名字或者id              |                                                              |
|    `docker pull $list{<images>}`    |               从Docker Hub上拉取指定名字的镜像               |                                                              |
| `docker exec <container> <command>` |      在指定容器内运行指定命令，容器可以用名字或者id指定      |                                                              |
|           `docker images`           |                     查看所有可应用的镜像                     |                                                              |
|    `docker inspect <container>`     |      显示指定容器的大部分详细信息<br />返回json格式消息      |                                                              |
|      `docker logs <container>`      |                    显示指定容器的运行日志                    |                                                              |

## Docker Run命令

对于`docker run`命令，还有一些其他相关的参数可以使用，如下表所示：

|                             命令                             |                             含义                             |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
|                 `docker run <images[:tag]>`                  | 指定运行的images tag（镜像版本）<br />若不指定，默认为`latest` |
|                   `docker run -i <images>`                   | 将宿主机的 standard input 映射到 Docker container，使 container 能够获取用户的输入<br />可以与`-t`参数配合使用，即`-it`参数 |
|                   `docker run -t <images>`                   | 将宿主机的 terminal 映射到 Docker container，使 container 能够向宿主机 terminal 输出信息<br />可以与`-i`参数配合使用，即`-it`参数 |
|           `docker run -p <port1>:<port2> <images>`           | 将宿主机 host 的端口`post1`映射到 Docker container 的端口`post2`<br />所有访问 host 的端口`port1`的流量会被路由到 Docker container 的端口`port2` |
|    `docker run -v <path_outside>:<path_inside> <images>`     | 将宿主机 host 的目录`path_outside`映射到 Docker container 的目录`path_inside`，以保证数据长久存储<br />所有的数据均会被保存在`path_outside`目录下，即使该容器被删除后也不会影响已经存储的数据 |
| `docker run --mount type=<TYPE>,source=<path_outside>,target=<path_inside> <images>` | `-v`参数的另一种形式，可以更明确地指出两种路径`source`、`target`和映射方式`TYPE`（包含bind、volume、tmpfs等挂载类型） |
|       `docker run -e <environment variables> <images>`       |          在镜像实例化运行时，将环境变量配置到容器中          |
|  `docker run --entrypoint <executable> <images> <command>`   |                 重载镜像中的`ENTRYPOINT`指令                 |

## Docker Image

虽然DockerHub上给我们提供了非常多的可用镜像，但假设我们需要给自己的应用创造镜像，那么就需要学会如何使用Dockerfile来build一个本地镜像。

在正式开始编写Dockerfile前，我们先在脑海中构思一下，假设需要我们自己去手动部署这个应用，整体的流程是怎样的，包括以下内容：

1. 应用依赖的操作系统以及系统架构
2. 应用部署在其上所需要的依赖、环境变量、部分源码
3. 应用启动时所需要的命令

在脑海中有了上述构思后，其实就可以开始编写Dockerfile了，Dockerfile里的内容其实就是上述流程的自动实现。常见的指令如下表所示：

|       指令        |                    核心用途                     | 是否创建新层 |
| :---------------: | :---------------------------------------------: | :----------: |
|    **`FROM`**     |          指定基础镜像，所有构建的起点           |      否      |
|     **`RUN`**     |                在构建时执行命令                 |    **是**    |
|    **`COPY`**     |            从构建上下文复制文件/目录            |    **是**    |
|     **`ADD`**     |       复制文件/目录，支持 URL 和自动解压        |    **是**    |
|     **`CMD`**     |            容器启动时的默认命令/参数            |      否      |
| **`ENTRYPOINT`**  |           容器启动时的固定可执行程序            |      否      |
|     **`ENV`**     |         设置环境变量（构建时 + 运行时）         |      否      |
|     **`ARG`**     |           设置构建时变量（仅构建时）            |      否      |
|   **`EXPOSE`**    |          声明容器监听的端口（元数据）           |      否      |
|   **`WORKDIR`**   |             设置后续指令的工作目录              |      否      |
|    **`USER`**     |         指定后续指令和容器运行时的用户          |      否      |
|   **`VOLUME`**    |                 创建匿名挂载点                  |      否      |
|    **`LABEL`**    |           为镜像添加元数据（键值对）            |      否      |
| **`HEALTHCHECK`** |             定义容器的健康检查方式              |      否      |
|    **`SHELL`**    | 更改默认的 shell（影响后续 RUN/CMD/ENTRYPOINT） |      否      |
| **`STOPSIGNAL`**  |          设置容器退出时发送的系统信号           |      否      |
|   **`ONBUILD`**   |   延迟执行的触发器（当镜像被用作基础镜像时）    |      否      |

其中 **`RUN`、`COPY`、`ADD`** 是仅有的三条会**实际修改文件系统、创建新镜像层**的指令，其余指令主要通过修改镜像的**配置元数据**来影响构建或运行行为。


### FROM：一切的基础

**语法**：`FROM <image>[:<tag>|@<digest>] [AS <name>]`

- **功能**：指定基础镜像，开始一个新的构建阶段。一个 Dockerfile 必须以 `FROM` 开头（`ARG` 除外，可用于 `FROM` 之前的变量）。
- **多阶段构建**：通过 `AS <name>` 命名阶段，后续可用 `COPY --from=<name>` 精确复制产物，保持最终镜像精简。
- **示例**：

  ```dockerfile
  # 基础阶段
  FROM golang:1.22 AS builder
  WORKDIR /src
  COPY . .
  RUN go build -o /app/main .
  
  # 最终的精简阶段
  FROM alpine:3.20
  COPY --from=builder /app/main /usr/local/bin/main
  ENTRYPOINT ["main"]
  ```
- **注意**：优先使用**固定标签或 digest**（如 `alpine:3.20` 或 `@sha256:...`），避免使用 `latest` 导致构建结果不可复现。


### RUN：构建时执行

**语法**：

Shell 形式：`RUN <command>`（在 `/bin/sh -c` 中执行）

Exec 形式：`RUN ["executable", "param1", ...]`（直接执行，不经过 shell）

- **功能**：在**构建镜像时**执行命令，结果会固化到镜像层中，常用于安装软件、编译代码、修改配置等。
- **示例**：

  ```dockerfile
  # Shell 形式（可以使用管道、变量、&& 等）
  RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
  
  # Exec 形式（避免 shell 解析，更可控）
  RUN ["/bin/bash", "-c", "echo hello && echo world"]
  ```
- **关键注意**：
  - **合并命令**：将逻辑上同一“层”的命令用 `&&` 串联在一个 `RUN` 中，避免产生多余层和残留缓存。
  - **清理同一层**：下载的临时文件、包管理器缓存在**同一条 `RUN`** 中删除，否则清理操作会在后续层中产生新的“白洞”，无法真正减小镜像体积。


### COPY：精确复制

**语法**：

1. Shell 形式（空格分隔）`COPY <源路径>... <目标路径>`

2. Exec 形式（JSON 数组）`COPY ["<源路径1>", "<源路径2>", ..., "<目标路径>"]`

> [!tip]
>
> 当路径中包含空格时，必须使用 JSON 数组形式，否则空格会被错误地解析为多个路径的分隔符。例如，复制名为 `my file.txt` 的文件应写为 `COPY ["my file.txt", "/app/"]`。
>
> 此外，`COPY` 支持一种**简写形式**，省略目标路径时，默认复制到当前 `WORKDIR`（若未设置则为 `/`）：
>
> ~~~dockerfile
> COPY package.json .
> ~~~

#### 源路径 (`<src>`) 的规则

源路径指**构建上下文**中的文件或目录，而非宿主机文件系统的任意位置。

- **相对路径**：相对于构建上下文根目录（即 `docker build` 命令中指定的目录）。
- **通配符**：遵循 Go 的 `filepath.Match` 规则。
  - `*` 匹配任意数量的非分隔符字符（如 `COPY hom* /mydir/`）。
  - `?` 匹配单个字符（如 `COPY hom?.txt /mydir/`）。
  - `**` 在 `--parents` 选项下可递归匹配多级目录。
- **多个源**：可以指定多个源路径，此时 `<目标路径>` **必须是一个目录**（以 `/` 结尾）。
- **特殊字符**：若文件名包含 `[`、`]` 等特殊字符，需按 Go 规则转义（如 `arr[0].txt` 写为 `arr\[0\].txt`）。

#### 目标路径 (`<dest>`) 的规则

- **绝对路径**：以 `/` 开头，相对于镜像根目录。
- **相对路径**：相对于当前 `WORKDIR`。
- **目录结尾**：如果 `<dest>` 以 `/` 结尾，Docker 会将其视为目录；如果它不存在，Docker 会自动创建它（包括所有父目录）。
- **文件 vs. 目录**：如果 `<dest>` 不以 `/` 结尾，它可能被视为文件。当有多个 `<src>` 时，`<dest>` 必须是目录。

- `COPY` 仅从**构建上下文**复制本地文件/目录，不支持 URL，**不会自动解压**。
- 默认推荐使用 `COPY` 而非 `ADD`，因为语义单一、行为可预测。
- 核心选项：`--from`（跨阶段/镜像）、`--chown`、`--chmod`、`--link`、`--parents`、`--exclude`。


### ADD：功能更强的复制

**语法**：`ADD <src>... <dest>` 或 `ADD ["<src>", ..., "<dest>"]`

- **功能**：与 `COPY` 类似，但额外支持：
  1. **远程 URL**：自动下载 URL 指向的内容到镜像中。
  2. **本地 tar 自动解压**：如果源是本地 tar 压缩包（`.tar`、`.tar.gz`、`.tgz` 等），会自动解压到目标目录。
- **示例**：

  ```dockerfile
  ADD https://example.com/config.tar.gz /etc/app/   # 下载并自动解压
  ADD local-files.tar.gz /app/                       # 本地 tar 自动解压
  ```
- **为何不推荐优先使用**：
  - 远程 URL 下载**不会自动清理缓存**，且难以校验完整性/签名，引入安全风险。
  - 自动解压行为可能出乎意料（本意是复制 tar 包，结果却被展开）。
  - **官方建议**：绝大多数场景使用 `COPY`；仅在确实需要 URL 下载或 tar 自动解压，且理解其副作用时，才考虑 `ADD`。


### CMD 与 ENTRYPOINT：运行时的分工

这两条指令共同定义容器启动时的行为，区别在于“可执行程序”与“默认参数”的分离。

#### CMD：默认参数 / 可被覆盖的默认命令

**语法**：

Exec 形式（**推荐**）：`CMD ["executable", "param1", "param2"]`

Shell 形式：`CMD command param1 param2`

作为 ENTRYPOINT 的参数：`CMD ["param1", "param2"]`

- **功能**：为容器提供**默认的启动命令或参数**。`docker run` 后面的参数会**替换** `CMD`（如果未显式指定 `ENTRYPOINT`，则替换的是整个命令）。
- **多条 CMD**：仅最后一条生效。

#### ENTRYPOINT：固定的可执行程序

**语法**：

Exec 形式（**推荐**）：`ENTRYPOINT ["executable", "param1", "param2"]`

Shell 形式：`ENTRYPOINT command param1 param2`

- **功能**：定义容器启动时**固定运行的可执行程序**。`docker run` 后面的参数通常作为**额外参数**追加给 `ENTRYPOINT`，而不会被替换（除非使用 `--entrypoint`）。
- **与 CMD 配合的最佳实践**：

  ```dockerfile
  ENTRYPOINT ["nginx", "-g", "daemon off;"]
  # 或
  ENTRYPOINT ["python", "app.py"]
  CMD ["--port", "8080"]      # docker run 时可覆盖为 --port 9090
  ```
  此时 `CMD` 为 `ENTRYPOINT` 提供默认参数，用户可以在 `docker run` 时灵活覆盖参数，而无需改变入口程序。


### ENV 与 ARG：两种变量

#### ENV：环境变量（构建 + 运行时）

**语法**：`ENV <key>=<value> ...` 或 `ENV <key> <value>`（旧式，不推荐）

- **功能**：设置**持久化**的环境变量，在**构建阶段后续指令**以及**容器运行时**都可见。
- **示例**：

  ```dockerfile
  ENV APP_HOME=/app \
      APP_ENV=production
  WORKDIR $APP_HOME
  ```

#### ARG：构建时变量（仅构建时）

**语法**：`ARG <name>[=<default value>]`

- **功能**：定义**仅构建时**可用的变量，可通过 `docker build --build-arg <name>=<value>` 传入。`ARG` 变量在镜像构建完成后**不会保留**在容器运行时环境中。
- **在 FROM 之前使用**：`ARG` 可以出现在 `FROM` 之前，用于参数化基础镜像版本等。
- **示例**：

  ```dockerfile
  ARG BASE_VERSION=3.20
  FROM alpine:${BASE_VERSION}
  ARG HTTP_PROXY
  RUN echo "Proxy: $HTTP_PROXY"
  ```
- **与 ENV 的关键区别**：`ARG` 仅构建时，`ENV` 构建时 + 运行时；`ARG` 的值可以通过构建参数覆盖，`ENV` 的值在 Dockerfile 中硬编码。


### WORKDIR：工作目录

**语法**：`WORKDIR /path/to/dir`

- **功能**：为后续的 `RUN`、`CMD`、`ENTRYPOINT`、`COPY`、`ADD` 等指令设置**当前工作目录**。如果目录不存在，Docker 会自动创建它。
- **注意**：`WORKDIR` 可以多次使用，每次都会改变后续指令的上下文。相对路径的 `WORKDIR` 是相对于前一个 `WORKDIR` 的。
- **示例**：

  ```dockerfile
  WORKDIR /app
  COPY . .              # 复制到 /app
  RUN npm install       # 在 /app 下执行
  ```


### USER：运行身份

**语法**：`USER <user>[:<group>]` 或 `USER <UID>[:<GID>]`

- **功能**：指定**后续 `RUN`、`CMD`、`ENTRYPOINT` 指令以及容器运行时**使用的用户/组。出于安全考虑，**强烈建议**在最终阶段切换到非 root 用户。
- **示例**：

  ```dockerfile
  RUN groupadd -r app && useradd -r -g app app
  USER app
  ```
- **注意**：`USER` 切换后，之前的 `COPY --chown` 可能需要配合使用，确保新用户对复制进来的文件有适当权限。


### EXPOSE：声明端口

**语法**：`EXPOSE <port>[/<protocol>] ...`

- **功能**：**声明**容器内应用监听的端口，属于**元数据**，并不会实际“打开”端口或使其可从宿主机访问。
- **实际发布端口**：需要在 `docker run` 时使用 `-p` 或 `-P` 进行映射。
- **示例**：

  ```dockerfile
  EXPOSE 8080/tcp
  EXPOSE 53/udp
  ```
- **价值**：作为文档说明，并可被 `docker run -P` 自动映射到宿主机随机端口。


### VOLUME：匿名卷挂载点

**语法**：`VOLUME ["/data"]` 或 `VOLUME /data`

- **功能**：在镜像中创建一个**挂载点**，并声明该路径应作为**匿名卷**管理。容器运行时，该路径下的数据会存储在 Docker 管理的卷中，与容器生命周期解耦，适合存放数据库文件、上传内容等需要持久化的数据。
- **注意**：`VOLUME` 之后对该路径的修改，在镜像构建中是否可见取决于具体场景；在 `docker run` 时可通过 `-v` 用命名卷或绑定挂载覆盖。


### LABEL：镜像元数据

**语法**：`LABEL <key>=<value> <key>=<value> ...`

- **功能**：为镜像添加**键值对形式的元数据**，可用于版本、维护者、描述、许可证等信息。替代已弃用的 `MAINTAINER`。
- **示例**：

  ```dockerfile
  LABEL org.opencontainers.image.version="1.0.0" \
        org.opencontainers.image.authors="dev@example.com" \
        description="My application"
  ```
- **查看**：`docker inspect <image>` 可查看所有 label。


### HEALTHCHECK：健康检查

**语法**：
- `HEALTHCHECK [OPTIONS] CMD <command>`
- `HEALTHCHECK NONE`（禁用基础镜像继承的健康检查）

- **功能**：定义 Docker 如何**周期性检查容器是否健康**。检查命令的退出码：`0` 健康，`1` 不健康，`2` 保留。
- **常用选项**：
  - `--interval`：检查间隔（默认 30s）
  - `--timeout`：单次检查超时（默认 30s）
  - `--start-period`：启动后的宽限期（默认 0s）
  - `--retries`：连续失败多少次判定为不健康（默认 3）
- **示例**：

  ```dockerfile
  HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1
  ```


### SHELL：更改默认 shell

**语法**：`SHELL ["executable", "parameters"]`

- **功能**：更改后续 `RUN`、`CMD`、`ENTRYPOINT` **Shell 形式**所使用的默认 shell。Exec 形式不受影响。
- **典型场景**：在 Windows 镜像中从 `cmd` 切换到 `powershell`；或在 Linux 中使用 `bash` 替代 `sh` 以支持某些语法。
- **示例**：

  ```dockerfile
  SHELL ["/bin/bash", "-o", "pipefail", "-c"]
  RUN echo "hello" | wc -c   # 现在在 bash 中执行，pipefail 生效
  ```


### STOPSIGNAL：退出信号

**语法**：`STOPSIGNAL <signal>`

- **功能**：设置 `docker stop` 时发送给容器的**系统信号**（如 `SIGTERM`、`SIGINT`、`SIGQUIT` 或数字）。默认通常是 `SIGTERM`。
- **示例**：

  ```dockerfile
  STOPSIGNAL SIGQUIT
  ```
- **场景**：某些应用（如 Nginx）优雅关闭需要特定信号，而非默认的 `SIGTERM`。


### ONBUILD：延迟触发器

**语法**：`ONBUILD <INSTRUCTION>`

- **功能**：注册一条**触发器**，该指令**不会在当前镜像构建时执行**，而是**当这个镜像被用作其他 Dockerfile 的 `FROM` 基础镜像时**，在后续构建中自动执行。
- **示例**：

  ```dockerfile
  # 基础镜像 Dockerfile
  ONBUILD COPY . /app/src
  ONBUILD RUN cd /app/src && npm install
  
  # 子镜像 Dockerfile
  FROM my-base-image
  # 此时会自动执行 ONBUILD 中的 COPY 和 RUN
  ```
- **注意**：`ONBUILD` 会使构建行为“隐式化”，调试困难，且可能引入不期望的副作用。**现代最佳实践倾向于避免使用**，转而通过多阶段构建或显式 COPY 来实现类似目标。


### 补充说明

- **解析器指令**：以 `# syntax=...` 或 `# escape=...` 等形式出现在 Dockerfile 最顶部的特殊注释，用于控制构建器的行为，不属于常规构建指令。
- **指令顺序与缓存**：Docker 按顺序执行指令，并利用层缓存。将**变化频率低**的指令（如安装系统依赖）放在前面，**变化频率高**的指令（如复制应用代码）放在后面，可以最大化缓存命中率。

---

理解上述 Dockerfile 指令的关键在于区分三个维度：

1. **执行时机**：**构建时**（`RUN`、`COPY`、`ADD` 等） vs **运行时**（`CMD`、`ENTRYPOINT`）。
2. **是否创建层**：仅 `RUN`、`COPY`、`ADD` 会写入文件系统并创建新层；其余指令主要修改配置元数据。
3. **生命周期**：`ARG` 仅构建时可见，`ENV` 构建时 + 运行时可见，`VOLUME` 声明的数据独立于容器生命周期。

下面是一个简单的示例：
~~~dockerfile
FROM ubuntu

RUN apt-get update

RUN apt-get install -y python3-flask

COPY app.py /opt/app.py

ENV FLASK_APP=/opt/app.py

ENTRYPOINT flask run --host=0.0.0.0
~~~

### 构建和推送

写完上面的dockerfile后我们可以使用`docker build`来构建镜像，使用命令`docker push`来将本地镜像推送到DockerHub，语法如下所示：

#### docker build

##### 语法

```bash
docker build [OPTIONS] PATH | URL | -
```

`PATH` / `URL` / `-` 指定**构建上下文**的位置。`.` 表示当前目录，`-` 表示从标准输入读取 Dockerfile 或上下文。

##### 常用 OPTIONS

| 选项          | 说明                                                         |
| ------------- | ------------------------------------------------------------ |
| `-t, --tag`   | 为镜像指定名称和标签，格式 `name:tag`。可多次使用打多个标签  |
| `-f, --file`  | 指定 Dockerfile 路径，默认是 `PATH/Dockerfile`               |
| `--build-arg` | 设置构建时变量，对应 Dockerfile 中的 `ARG`                   |
| `--no-cache`  | 构建时不使用缓存，强制重新执行所有步骤                       |
| `--pull`      | 总是尝试拉取基础镜像的更新版本                               |
| `--target`    | 只构建 Dockerfile 中指定的某个构建阶段（多阶段构建时常用）   |
| `--platform`  | 指定目标平台，例如 `linux/amd64`、`linux/arm64`（需要服务端支持多平台） |
| `--network`   | 设置构建过程中 `RUN` 指令使用的网络模式（`default`、`host`、`none` 等） |
| `-q, --quiet` | 抑制构建输出，成功时只打印镜像 ID                            |
| `--rm`        | 构建成功后删除中间容器（默认 `true`）                        |

**示例**

```bash
# 指定 Dockerfile 并打标签
docker build -f docker/Dockerfile.prod -t myapp:v1.0 .

# 传入构建参数，不使用缓存
docker build --build-arg NODE_ENV=production --no-cache -t myapp:prod .

# 只构建多阶段 Dockerfile 中的 builder 阶段
docker build --target builder -t myapp:builder .
```

#### docker push

##### 语法

```bash
docker push [OPTIONS] NAME[:TAG]
```

`NAME[:TAG]` 必须是已经打上**仓库前缀**的镜像名，例如 `username/repo:tag` 或 `registry-host:5000/repo:tag`。

##### 常用 OPTIONS

| 选项             | 说明                                                         |
| ---------------- | ------------------------------------------------------------ |
| `-a, --all-tags` | 推送该镜像在本地的所有标签，而不只是指定的那个标签           |
| `--platform`     | 推送指定平台的单一 manifest，而不是推送完整的多平台索引（需要 API 1.46+） |
| `-q, --quiet`    | 抑制详细输出                                                 |

> [!tip]
>
> `--disable-content-trust` 在部分旧文档中出现，默认值为 `true`，用于跳过镜像签名；日常推送中较少需要手动改动。

**示例**

```bash
# 推送单个标签
docker push myusername/myapp:v1.0

# 推送该镜像的所有本地标签
docker push -a myusername/myapp

# 只推送 linux/amd64 平台的单 manifest
docker push --platform linux/amd64 myusername/myapp:v1.0
```

### 传统构建方式的弊端

传统的docker build存在以下弊端：

1. **无法利用build-cache** ：当构建过程包括install过程时，当dockerfile中的任意一行源代码发生了变化，都会导致后续的rebuild要重新下载packages，会严重拉长每一次build的时长
2. **密钥泄漏风险** ：假设使用build argument来传递密钥，会导致密钥泄漏，用户可以直接通过部分手段查看被保存在镜像中metadata的密钥；如果使用ENV指令设置密钥，也会导致密钥被固化到layer和build历史记录中，从而导致密钥泄漏
3. **无法适应其他机器架构** ：假设你在Linux-x64架构上构建的镜像，那么该镜像大概率无法在Linux-arm64上运行
4. **无法并行执行** ：假设存在两个FROM阶段且两者构建期间并不互相存在依赖关系，那么构建的过程中完全可以并行构建，但传统的docker build只能串行构建它们

为了解决这个问题，docker官方重写了相关的构建工具，现在使用build命令会默认使用 **BuildKit** 来进行构建，其中BuildKit的命令行前端被称为 **Buildx** 。

#### cache-mount

要修复第一个问题，可以参考下面的示例：

~~~dockerfile
# syntax=docker/dockerfile:1

FROM python:3

RUN --mount=type=cache,target=/root/.cache/pip \
	pip install flask flask-mysql

COPY app.py /app/
ENTRYPOINT ["python", "/app/app.py"]
~~~

其中对于第一行的`# syntax=docker/dockerfile:1` 是一个指令，作用是 **向BuildKit说明使用现代的 Dockerfile frontend** ， 从而能够使用 `--moount` 选项

#### secret-protect

要修复第二个问题，可以参考下面的示例：

~~~dockerfile
# syntax=docker/dockerfile:1

FROM alpine
RUN apk add --no-cache curl

RUN --mount=type=secret,id=mykey \
	curl -H "Authorization: Bearer $(cat /run/secrets/mykey)" \
~~~

然后运行命令：
~~~bash
dockerfile buildx build --secret id=mykey,src=./key.txt -t myapp .
~~~

这样就能保证密钥不会出现在build-history、Docker-inspect中，从而保证了密钥的安全。

#### multi-platform builds

要修复第三个问题，可以参考下面的示例：
~~~bash
dockerfile buildx build --platform linux/amd64,linux/arm64 -t mmumshad/my-simple-webapp --push .
~~~

通过选项`--platform`来选择不同架构来进行构建。

#### parallel stage execution

要修复这个问题，我们并不需要新增任何内容，BuildKit会自行帮我们辨别其中的stage并对不存在依赖关系的stage进行并行构建。

### Docker init

假设我们实在是不想每次都手搓dockerfile，那么可以使用命令`docker init`来进入一个交互式prompt，在其中回答下面几个问题，就可以创建一个简单的dockerfile模板：

1. What application platform does your project use?
2. What version of Node do you want to use?
3. Which package manager do you want to use?
4. What command do want to use to start the app?
5. What port does your sever listen on? 

其会生成四个文件：

- `dockerfile`：按照当前最佳实践编写的dockerfile，采用了multi-stage build、slim base image和非root用户，对layer进行了排序以便依赖能够很好地被cache
- `.dockerignore`：类似于`.gitignore`，说明了哪些内容不应该被包含进镜像
- `compose.yaml`：定义了一个映射好端口的service
- `README.Docker.md`：一份关于如何build和run的简短指南

## Docker Compose

假设我们的某一个APP需要依赖多个工具组件，传统的做法就是一个一个地构建镜像（如果已有镜像可以忽略此步）然后启动容器，并将容器加入到对应的network中。

> [!tip]
>
> network的作用如下：
>
> - **提供默认的通信基础**：默认情况下，`docker compose up` 会为你的应用创建一个独立的网络（通常命名为`<项目名>_default`），所有未指定网络的服务都会自动加入这个网络。这为应用内的服务通信提供了开箱即用的基础，无需任何额外配置。
> - **实现自动的服务发现**：这是 Compose 网络最核心的便利之一。每个服务都会在内部 DNS 中注册自己的服务名。因此，容器A可以直接通过服务名（如`db`或`web`）访问容器B，而无需关心其 IP 地址。Docker 会动态分配 IP 并在容器重启或重建时更新，但服务名始终稳定，这简化了服务间的引用和配置。
> - **支持服务隔离与分段**：通过定义多个自定义网络，可以实现服务间的访问控制。例如，你可以创建`frontend`和`backend`两个网络，让代理服务（proxy）只连接`frontend`，数据库（db）只连接`backend`，而应用（app）同时连接两者。这样，代理就无法直接访问数据库，提升了安全性和架构清晰度。
> - **提供灵活的驱动和配置选项**：Compose 的顶层`networks`元素允许你精细控制网络的属性，比如指定网络驱动（`bridge`、`overlay`等）、传递驱动选项（`driver_opts`）、设置是否允许独立容器连接（`attachable`）等，以满足从单机开发到多主机部署的不同场景需求。
>
> 因此如果一个APP需要使用多个组件，那么就需要为其创建一个network并加入相关的容器。

以一个简单的例子说明，假设一个ClickCounter App依赖于Redis和一个C++编写的Worker，那么我们手动部署的过程如下所示（假设初始镜像存在）：
~~~bash
docker network create clicknet # 创建APP网络
docker run -d --name=redis --network=clicknet redis:alpine
docker run -d --name=clickcounter \
			--network=clicknet \
			-p 8085:5000 \
			worker
~~~

当该App的任务结束时，我们就需要同时销毁相关容器和网络：

~~~bash
docker stop redis clickcounter &&
docker rm redis clickcounter

docker network rm clicknet
~~~

很显然，假设一个App的架构很复杂，手动部署的话会很麻烦，清理的时候也会十分麻烦，而Docker Compose就是为了解决这个问题存在的。还是以上面的例子说明，这一次我们创建一个`compose.yaml`，其内容如下：
~~~yaml
services:
	redis:
		image: redis:alpine
	
	clickcounter:
		build: ./worker
		ports:
			- 8085:5000
~~~

然后执行命令`docker compose -f ./compose.yaml up -d`就可以一键构建出我们想要的App，需要删除时直接使用命令`docker compose -f ./compose.yaml down`就可以一键移除相关的容器和组件，这就使得我们维护App变得容易且简单。

> [!tip]
>
> 上述两个compose命令等价`docker compose up -d`、`docker compose down`，前提是当前工作目录下存在`compose.yaml`文件，否则最好使用`-f`选项指定相关文件。

常见的关键字如下所示，掌握其中一小部分足以应付绝大部分情况。

### 顶层关键字

Compose 文件的一级结构由以下顶层元素构成：

| 关键字         | 是否必需 | 作用                                                         |
| :------------- | :------- | :----------------------------------------------------------- |
| **`services`** | **必需** | 定义应用中的所有服务（容器）。每个服务以名称为键，其下配置镜像、端口、网络、存储等。 |
| **`networks`** | 可选     | 声明具名网络，供服务间通信使用。不声明时，Compose 会自动创建默认网络。 |
| **`volumes`**  | 可选     | 声明具名数据卷，用于持久化或共享数据。                       |
| **`configs`**  | 可选     | 声明只读配置文件，以文件形式挂载进容器，适用于非敏感配置。   |
| **`secrets`**  | 可选     | 声明敏感数据（如密码、证书），以文件形式挂载到容器内 `/run/secrets/` 下，与 `configs` 的区别在于用途和安全约束。 |
| **`name`**     | 可选     | 显式指定项目名称，影响资源命名前缀，避免同一目录下多个 Compose 文件产生冲突。 |

> `services` 是唯一在运行时**必需**的顶层元素；其余顶层元素按需声明即可。


### 服务级关键字

服务级关键字是 Compose 文件中最密集的部分。以下按常见程度和功能类别组织。

#### 核心运行配置

| 关键字               | 作用                      | 关键要点                                                     |
| :------------------- | :------------------------ | :----------------------------------------------------------- |
| **`image`**          | 指定服务使用的容器镜像。  | 与 `build` 二选一；两者同时存在时，`image` 用于为构建结果命名。 |
| **`build`**          | 从 Dockerfile 构建镜像。  | 常用子键：`context`（构建上下文路径）、`dockerfile`（自定义 Dockerfile 文件名）、`args`（构建参数）。 |
| **`container_name`** | 指定容器名称。            | 不设置时自动生成 `<项目名>_<服务名>_<序号>`；**一旦使用固定名称，该服务将无法通过 `--scale` 横向扩缩**。 |
| **`command`**        | 覆盖镜像的 `CMD`。        | 字符串形式经 shell 执行，列表形式直接 exec；设为 `null` 恢复镜像默认值。 |
| **`entrypoint`**     | 覆盖镜像的 `ENTRYPOINT`。 | 生产环境通常不建议轻易修改，以免破坏镜像既定的启动逻辑。     |

#### 网络与端口

| 关键字             | 作用                                             | 关键要点                                                     |
| :----------------- | :----------------------------------------------- | :----------------------------------------------------------- |
| **`ports`**        | 宿主机端口映射到容器端口。                       | 短语法 `"8080:80"`；生产环境建议绑定具体接口，如 `"127.0.0.1:8080:80"`，避免暴露到所有网卡。 |
| **`expose`**       | 暴露容器端口给**链接的**服务，但不发布到宿主机。 | 仅用于容器间通信的显式声明。                                 |
| **`networks`**     | 将服务连接到指定的具名网络。                     | 引用顶层 `networks` 中声明的网络；不指定时使用默认网络。     |
| **`network_mode`** | 设置容器的网络模式。                             | 可选 `host`、`none`、`service:<服务名>` 等，与 `networks` 互斥使用。 |

#### 存储与配置

| 关键字        | 作用                             | 关键要点                                                     |
| :------------ | :------------------------------- | :----------------------------------------------------------- |
| **`volumes`** | 挂载目录或数据卷到容器。         | 短语法 `宿主机路径:容器路径` 或 `卷名:容器路径`；具名卷需在顶层 `volumes` 中声明，否则 `down` 时可能被删除。 |
| **`configs`** | 将顶层声明的配置挂载到服务。     | 只读挂载，适用于非敏感配置文件。                             |
| **`secrets`** | 将顶层声明的敏感数据挂载到服务。 | 只读，默认出现在 `/run/secrets/<名称>`；支持 `uid`、`gid`、`mode` 细粒度控制。 |

#### 依赖与生命周期

| 关键字                  | 作用                       | 关键要点                                                     |
| :---------------------- | :------------------------- | :----------------------------------------------------------- |
| **`depends_on`**        | 声明服务启动顺序依赖。     | 短语法仅控制启动**顺序**，不等待依赖“就绪”；需要等待应用真正可用时，应使用长语法配合 `condition: service_healthy`（依赖服务须配置 `healthcheck`）。 |
| **`healthcheck`**       | 定义容器健康检查。         | 子键包括 `test`（检测命令）、`interval`、`timeout`、`retries`、`start_period`；`test` 常用 `["CMD", "curl", "-f", "..."]` 或 `["CMD-SHELL", "..."]`。 |
| **`restart`**           | 重启策略。                 | `no`（默认）、`always`、`on-failure`、`unless-stopped`；生产环境常配合资源限制使用，防止崩溃循环耗尽系统资源。 |
| **`stop_grace_period`** | 停止容器时的优雅等待时间。 | 适用于需要完成清理或保存状态的服务。                         |

#### 资源与调度（`deploy` 及其子键）

| 关键字       | 作用                       | 关键要点                                                     |
| :----------- | :------------------------- | :----------------------------------------------------------- |
| **`deploy`** | 部署与资源相关配置的容器。 | 常用子键：`replicas`（副本数）、`resources.limits`（资源上限）、`resources.reservations`（资源预留）、`restart_policy`。使用 `replicas` 时**不可同时设置 `container_name`**。 |

#### 环境与元数据

| 关键字            | 作用                                                         |
| :---------------- | :----------------------------------------------------------- |
| **`environment`** | 直接以键值对形式注入环境变量。敏感值应避免硬编码，推荐用 `.env` 文件或 `secrets`。 |
| **`env_file`**    | 从文件加载环境变量。                                         |
| **`labels`**      | 为容器添加元数据标签，便于组织和筛选。                       |
| **`annotations`** | 为容器添加注解，常用于与编排平台集成。                       |

#### 其他常见运维关键字

以下关键字在日常使用中也会出现，但频率略低于上述类别：

| 关键字                     | 作用                                     |
| :------------------------- | :--------------------------------------- |
| **`dns` / `dns_search`**   | 自定义容器 DNS 服务器 / 搜索域。         |
| **`extra_hosts`**          | 向容器 `/etc/hosts` 添加额外主机映射。   |
| **`cap_add` / `cap_drop`** | 添加或移除 Linux 内核能力。              |
| **`devices`**              | 映射宿主机设备到容器。                   |
| **`init`**                 | 在容器内使用 init 进程管理子进程回收。   |
| **`logging`**              | 配置日志驱动及选项。                     |
| **`pid`**                  | 设置 PID 命名空间模式。                  |
| **`sysctls`**              | 设置容器内核参数。                       |
| **`tmpfs`**                | 挂载内存文件系统。                       |
| **`platform`**             | 指定容器运行的平台（如 `linux/amd64`）。 |


### `networks`、`volumes` 等顶层元素的常用子键

顶层 `networks`、`volumes` 下也有一些常见配置，用于控制资源的实际行为：

| 顶层元素                  | 常用子键                      | 作用                                                         |
| :------------------------ | :---------------------------- | :----------------------------------------------------------- |
| **`networks`**            | `driver`                      | 网络驱动，默认 `bridge`；可选 `overlay`（多主机）等。        |
|                           | `name`                        | 指定实际网络名称；不设置时自动加项目名前缀。                 |
|                           | `external`                    | 设为 `true` 表示使用已存在的外部网络，Compose 不会创建或删除它。 |
|                           | `attachable`                  | 允许独立容器手动接入该网络，默认 `false`。                   |
|                           | `ipam`                        | 自定义 IP 地址管理配置（子网、网关等）。                     |
|                           | `internal`                    | 设为 `true` 时创建内部网络，隔离外部访问。                   |
| **`volumes`**             | `driver`                      | 卷驱动，默认 `local`。                                       |
|                           | `driver_opts`                 | 向驱动传递选项。                                             |
|                           | `external`                    | 使用外部已存在的卷，不由 Compose 管理生命周期。              |
|                           | `name`                        | 指定实际卷名。                                               |
| **`secrets` / `configs`** | `file`                        | 从宿主机文件加载内容。                                       |
|                           | `external`                    | 使用外部已存在的 secret/config。                             |
|                           | `environment`（仅 `secrets`） | 从环境变量读取敏感值。                                       |

## Docker Engine，Storage

我们通过上述简单的学习，可以了解到Docker是通过其Engine来管理内部的container的，大致的层级如下所示：

![Engine layer](/images/unit/1000000004/2.jpeg)

Dokcer deamon是一个后台进程，主要负责管理images、containers、volumes、network等Docker对象；

Docker REST API server是程序用来于deamon通信并发送指令的API接口。因此可以在其上构建自己的tools；

Docker CLI就是命令行接口，通过REST API与deamon进行通信，其中CLI可以与deamon不在同一个host上。

### 控制container的资源

极端环境下，一个container可以消耗掉host上的所有cpu和memory资源，我们可以在`docker run`命令中加入选项来控制container的资源上限，如下所示：

~~~bash
docker run --cpu=0.5 ubuntu # 最多占用50%的CPU
docker run --memory=100m ubuntu #最多占用100M内存空间
~~~

---

还有一些内容属于运维相关的内容，比如如何部署本地的Registry、怎么一键部署多个实例、Docker Swarm、Kubernetes等等，这些内容如果要单独拿出来又是一大堆知识，超出了本文的内容，因此这里建议读者后续自行搜索更详细的教程自行学习，这里不再对上述内容进行说明。
