---
title: 禁用Fedora的挂起功能
description: 利用CLI方式来禁用fedora Linux中的挂起功能

date: 2026-09-07T17:26:41+08:00
lastmod: 2026-09-07T17:26:41+08:00
tags:
 - 操作系统
 - 挂起
categories:
 - 杂谈
math: false
mermaid: false
weight: 1000000001
---

# 禁用Fedora的挂起功能

​    前几天在把一个开源项目迁移到Fedora Linux时，意外地发现Fedora 44 Workstation假设在使用了 **挂起** 后就一定会导致机器睡死，大致去了解了下挂起的概念：

> Linux中一个非常核心的电源管理功能，简单来说，就是让电脑**在不完全关机的情况下，进入一种极低功耗的“睡眠”状态** 。

经过多方验证，至少对我这台机器网上大多数方法都没办法解决睡死问题（包括且不限于加入cpu参数，更改bios参数、替换显卡驱动等等），而且我的机器还是个笔记本，手动合屏会自动挂起，如果待机时间长了也会挂起（这一点可以在设置中更改），总之挂起在我机器上引起了不小的麻烦，因此只能禁用挂起功能。

   本文仅介绍用 **CLI** 方式禁用挂起功能的方式，其他方式可以自行检索。

> [!WARNING]
>
> 该方法会禁用所有类型的挂起和休眠。

1. 创建一个新的配置文件：

   ~~~bash
   sudo mkdir -p /etc/systemd/sleep.conf.d
   sudo nano /etc/systemd/sleep.conf.d/disable-suspend.conf
   ~~~

2. 在配置文件中编写具体配置：
   ~~~ini
   [Sleep]
   AllowSuspend=no
   AllowHibernation=no
   AllowSuspendThenHibernate=no
   AllowHybridSleep=no
   ~~~

3. 重启系统或者：
   ~~~bash
   sudo systemctl restart systemd-logind
   ~~~

经过测试，这样一来所有类型的挂起和休眠都被禁用了，笔记本手动合屏也不会进入挂起状态。