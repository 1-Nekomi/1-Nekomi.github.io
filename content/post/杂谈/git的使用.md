---
title: git的使用
description: 主要介绍版本控制工具git的一些简单概念以及常用的命令

date: 2026-08-07T21:37:00+08:00
lastmod: 2026-08-07T21:37:00+08:00
tags:
 - git
 - 工具
categories:
 - 杂谈
math: true
mermaid: true
weight: 1000000000
---

# git的使用 #

​    在日常敲代码的时候，经常会遇到需要对代码某些版本进行备份的需求，在以前那个计算机发展尚不成熟的年代，前辈们都只能手动备份，非常麻烦，也不利于协作，虽然后面也有BitKeeper这样的商业闭源版本控制工具，但其并不是免费的。不过随着某个人开发了git，局面就向git一面倒了，这个人就是Linux操作系统的开发者Linus Torvalds。在正式开始前，要先感谢一下前辈们为如今如此方便的操作所作出的贡献。

   前排提示，本博客仅为个人学习记录，且不适用于新手，如有误，欢迎指正。

## 什么是git ##

​    一款**开源、分布式版本控制系统（DVCS, Distributed Version Control System）**，作用是跟踪文件变更、记录完整历史、支持多人并行协作开发，可以随时回退历史版本、创建分支并行开发、合并不同开发者代码，广泛用于源代码管理，也可管理文档、配置文件等各类文本文件。

​    换句话就是git能够**自动管理代码的版本**，当代码出现难以解决的致命错误时，可以利用git将代码恢复到一个可用的状态（前提是你提交过这个代码状态）。

​    本文并不着重介绍git的各种设计理念和发展路径，而是主要介绍git是怎么使用的，为了方便查阅，某些地方并不会过深地讲解实现原理。

​    在正式使用git前，需要拥有一个`Github`的账号，`GitHub`主要是提供网络代码托管服务，相关注册教程请自行搜索。

## 个人使用场景 ##

### 创建仓库   

   在进行远程托管前需要在本地创建一个仓库，创建一个空目录（不一定非要空目录，有文件的目录也可以），为了后面描述方便，将其命名为`Git-Study`，然后在该目录中初始化一个git仓库。

~~~bash
$ mkdir Git-Study 
$ cd Git-Study
$ git init
~~~

​    通过这个操作，该目录会成为一个git仓库，目录中会多出来一个名为 **.git** 的文件夹（用于跟踪管理仓库，默认隐藏），说明本地仓库初始化成功了。

---

本部分核心代码为：

~~~bash
git init
~~~

---

### 本地仓库提交

​    现在在`Git-Study`目录下编写一个名为`test.txt`的文本文件，随便编辑一部分内容，为了后续讲解方便，笔者这里编辑内容如下：

~~~txt
Git is good.
Git is a version control system.
~~~

  此时我们执行命令`git status`可以随时掌握仓库当前的状态，执行后可以看到`test.txt`被修改了，但还没有提交。

~~~bash
$ git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   test.txt

no changes added to commit (use "git add" and/or "git commit -a")
~~~

​    假设已经忘记了上一次修改是怎么修改的`test.txt`，那么可以尝试`git diff`，就可以查看修改状态。

~~~bash
$ git diff
diff --git a/test.txt b/test.txt
index 1e9e10d..ae2d779 100644
--- a/test.txt
+++ b/test.txt
@@ -1,2 +1 @@
 Git is free software distributed under the GPL.
-Git is a distributed version control system.
\ No newline at end of file
~~~

​    可以看到我删除了第二行，此后再进行提交就会更放心一点，避免提交了错误的修改上去。

​    编辑完成，为了能够进行推送(push)操作，需要先进行 **添加(add)** 操作`git add`和 **提交(commit)**`git commit` 操作，以上面的文件为例子。

~~~bash
$ git add test.txt
$ git commit -m "wrote a test file."
~~~

 *add操作*是为了让git知道**本次commit操作所涉及的文件有哪些**，因此你可以add多个文件；而*commit操作*则是为了**对本次提交进行说明**，一旦进行了commit操作，**所有add过的文件中的更改**会变成一个更改节点存储在本地仓库，在一些带有GUI的git工具中我们可以查看本次提交中涉及到的更改，例如在vscode中，我们可以在此处看到我们的提交记录，并能够看到更改记录。

![vscode中查看更改记录](/images/unit/1000000000/3.png)

---

本部分核心代码为：

~~~bash
git status
git diff
git add <file_path>
git commit -m <message>
~~~

---

### 版本查看

​    假设我们在多次编辑了文件，并均正常进行了commit操作后，git就会按照时间线将提交记录组织成一个树结构（假设没有分支则为线性树）。

​    为了后面的讲解方便，现在对上述`Git-Study`仓库中的`test.txt`文件进行两次更改：

~~~txt
Git is free software distributed under the GPL. # 第一次更改
Git is a version control system.
~~~

~~~txt
Git is free software distributed under the GPL.
Git is a distributed version control system. # 第二次更改
~~~

​    分别提交注释`"append GPL"`和`"add distributed"`后，假设在某一个时间段内，我们想要看**提交的历史记录**，就需要用到`git log`命令，这个命令会显示**从最近到最远的提交日志**。

~~~bash
$ git log
commit b413beaa81fac93eb0b915cb72ece3a542f44fb6 (HEAD -> main)
Author: 1-Nekomi <1372718707@qq.com>
Date:   Tue Aug 11 17:04:58 2026 +0800

    append distributed

commit c323a33cbbf8d2b1521c21dc7f080e938c1979b9
Author: 1-Nekomi <1372718707@qq.com>
Date:   Tue Aug 11 17:01:41 2026 +0800

    append GPL

commit 68d4c46c73f1a7e3a5b3be2b6306d5952bcbf6e7
Author: 1-Nekomi <1372718707@qq.com>
Date:   Mon Aug 10 21:05:45 2026 +0800

    wrote a test file.
~~~

​    可以附带`--pretty=oneline`参数减少输出信息。

~~~bash
$ git log --pretty=oneline
b413beaa81fac93eb0b915cb72ece3a542f44fb6 (HEAD -> main) append distributed
c323a33cbbf8d2b1521c21dc7f080e938c1979b9 append GPL
68d4c46c73f1a7e3a5b3be2b6306d5952bcbf6e7 wrote a test file.
~~~

同时可以附带`--graph`和`--abbrev-commit`参数来查看分支树的结构：

~~~bash
$ git log --graph --pretty=oneline --abbrev-commit
~~~

这个命令后续在**分支管理**部分我们会多次用到。

---

本部分核心代码为：

~~~bash
git log [--graph] [ --pretty=oneline ] [--abbrev-commit]
~~~

---

### 版本回退和回溯

​    假设在上述过程中，commit记录为`"append distributed"`的节点不是我们想要的，想要回退版本，首先需要知道我们目前的版本是什么，通过`git log`命令我们可以得知，我们的HEAD指针是在记录为`"append distributed"`的节点上，分支为`main`的版本中，这个就是我们目前的版本。

​    接着回退版本需要配合`HEAD`指针，`HEAD`有**两种**参数选择，一个是`HEAD^`，其中 **`^`的个数** 表示要回退的版本数量；另一种就是          `HEAD~<number>`，其中 **`<number>`中所填写的数字** 表示要回退的版本数量。

​    这个时候就可以配合`git reset`命令进行版本回退：

~~~bash
$ git reset --hard HEAD^
OR
$ git reset --hard HEAD~1
HEAD is now at c323a33 append GPL
~~~

​    其中`--hard`参数表示**回退到上个版本的已提交状态**，其他参数`--soft` 表示**回退到上个版本的未提交状态**，`--mixed`表示**回退到上个版本已添加但未提交的状态**。

​    假设突然后悔了，**想回到未进行回退的版本**该怎么办？这个时候就需要用到之前`git log`命令提供的**节点ID**，以上述`test.txt`未回退时的log结果为例：

~~~bash
$ git log
commit b413beaa81fac93eb0b915cb72ece3a542f44fb6 (HEAD -> main)
Author: 1-Nekomi <1372718707@qq.com>
Date:   Tue Aug 11 17:04:58 2026 +0800

    append distributed

commit c323a33cbbf8d2b1521c21dc7f080e938c1979b9
Author: 1-Nekomi <1372718707@qq.com>
Date:   Tue Aug 11 17:01:41 2026 +0800

    append GPL

commit 68d4c46c73f1a7e3a5b3be2b6306d5952bcbf6e7
Author: 1-Nekomi <1372718707@qq.com>
Date:   Mon Aug 10 21:05:45 2026 +0800

    wrote a test file.
~~~

​    在每个节点log的commit后跟着一大串就是`commit id`，也叫**版本号**，通过**SHA1**计算得到，主要作用是**避免在进行多人协作时产生仓库版本号冲突**。

​    这个时候配合`git reset`命令就可以实现版本回溯（不等价于回退）：

~~~bash
$ git reset --hard b413beaa81fac93eb0b915cb72ece3a542f44fb6
HEAD is now at b413bea append distributed
~~~

​    但是假设你**找不到前面的log日志**了又该怎么办？这个时候可以试试`git reflog`命令：

~~~bash
$ git reflog
b413bea (HEAD -> main) HEAD@{0}: reset: moving to b413beaa81fac93eb0b915cb72ece3a542f44fb6
c323a33 HEAD@{1}: reset: moving to HEAD~1
b413bea (HEAD -> main) HEAD@{2}: commit: append distributed
c323a33 HEAD@{3}: commit: append GPL
68d4c46 HEAD@{4}: commit (initial): wrote a test file.
~~~

​    通过查找**commit记录**，就可以知道`HEAD`指针所指向节点的id部分前缀，配合终端的TAB自动补全就可以得到完整的`commit_id`了。

---

本部分核心代码：

~~~bash
git reset [<mode>] [<commit>]
git reflog
~~~

---

### 工作区和暂存区

​    在继续下面的讲解前，这里需要短暂说明一下工作区和暂存区，以防止后续的命令不知道在干什么。

​    **工作区(Working Directory)** 就是在电脑上的目录，这个应该很好理解。而在工作区中有一个隐藏的文件夹`.git`，这个就是Git的 **版本库（Repository）** ，也可以叫**仓库**，在版本库中有这么几样东西：

- **暂存区(stage或index)**
- **第一个分支（名字默认master，也有可能是其他名字，笔者这里用的是main）**
- **指向第一个分支的指针HEAD**

​    在上述的`add`和`commit`操作中，Git就是在`main`分支上进行操作的，而`add`操作会**将需要提交的文件存放在暂存区**，`commit`操作则会**一次性提交暂存区中所有更改到main分支中，并生成一个新的提交节点，让`HEAD`指针指向这个新的节点**。

​    可以将暂存区理解成计算机系统中的**缓存**，但注意，两者实际上还是有一些区别的。

​    为了更好理解暂存区，我们这里举一个简单的例子，假设在`test.txt`新增一行：
~~~txt
Git is free software distributed under the GPL.
Git is a distributed version control system.
Git has a mutable index called stage.
~~~

​    现在我们正常进行`add`操作，但是在进行`commit`操作前，我们先再在`test.txt`中新增一行：

~~~txt
Git is free software distributed under the GPL.
Git is a distributed version control system.
Git has a mutable index called stage.
Git tracks changes.
~~~

​    然后我们进行`commit`操作，注释为`"add index"`,接着执行`git status`：
~~~bash
$ git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   test.txt

no changes added to commit (use "git add" and/or "git commit -a")
~~~

​    可以看到第二次修改并没有被提交，这就是由于**两次修改，假设第二次修改发生在第一次修改进行`add`操作后才发生的且第二次修改没有进行过`add`操作，那么`commit`操作只会提交第一次修改**。那么没有被提交的第二次修改在哪呢，可以自行思考一下。

### 撤销修改

​    假设在编辑`test.txt`文件时，在其中错误加入了一行：

~~~txt
Git is free software distributed under the GPL.
Git is a distributed version control system.
Git has a mutable index called stage.
Genshin impact start! #错误加入的一行
~~~

​    ~~很明显有一行的风格有点与众不同~~,此时使用命令`git checkout`可以**丢弃工作区的修改**。
~~~bash
$ git checkout -- test.txt
~~~

​    上述命令就是**将文件`test.txt`在工作区的修改全部撤销**，但可能会有两种情况：

1. `test.txt`自修改后还没有被存放到暂存区，撤销修改就回到和**版本库一摸一样的状态**，相当于回到最近一次进行了`git commit`时的状态；
2. `test.txt`已经添加进暂存区，但又进行了修改，撤销修改就回到**添加进暂存区后的状态**，相当于回到最近一次进行了`git add`时的状态。

​    但假设没有注意到异常，进行了`git add`将错误的代码进行了提交，那么可以使用命令`git reset HEAD <file>`来**将暂存区中的修改撤销掉，重新放回工作区**。

~~~bash
$ git reset HEAD test.txt
Unstaged changes after reset:
M       test.txt
~~~

> [!TIP]
>
> ​    把暂存区中的修改撤销后，如果需要将修改彻底进行撤销操作，还需要再进行一次**从工作区中撤销**的操作。

---

本部分核心代码：

~~~bash
git checkout -- <file>
git reset HEAD <file>
~~~

---

### 删除文件

​    当你通过**文件管理器**删除了一个文件时，git也能够察觉，工作区和版本库会因此不一致，通过`git status`可以查看哪些文件被删除。

​    这里有两个选择：

1. 确实需要从版本库中删除文件，使用命令`git rm`
   ~~~bash
   $ git rm <file>
   ~~~

   > [!TIP]
   >
   > ​    先通过文件管理器删除文件后，再使用`git rm <file>`和`git add <file>`效果是一样的。

2. 删错了，需要进行从版本库中进行恢复，使用命令`git checkout`:

   ~~~bash
   $ git checkout -- <file>
   ~~~
   本质上是{{< spoiler >}}**利用版本库中的版本替换工作区中的版本**{{< /spoiler >}}

   > [!WARNING]
   >
   > ​    **从来没有被添加进版本库就被删除**的文件无法通过版本库进行恢复。

---

本部分核心代码：

~~~bash
git rm <file>
git checkout -- <file>
~~~

---

## 远程库操作

​    现在通过上述学习，我们能够正常在我们自己的电脑上进行仓库管理，但是假设我们换了一个设备，且原来的设备也正好不在身边，该怎么转移仓库？

​    这个时候就需要用到Github了，注册请详见其他教程。Github注册完成后就可以在个人账户中创建一个**仓库（repository）**，这个仓库用于接收从git上推送的代码文件。首先进入GitHub中，在页面上点击`NEW`按钮，如图所示：

![在github上创建一个新的仓库](/images/unit/1000000000/1.png)

​    接着填充所创建仓库的信息，各个信息字段如下图所示：

![填充仓库的信息](/images/unit/1000000000/2.png)

​    创建完成后，还需要创建一个`SSH key`加入到Github上，用于**验证推送者的身份，防止冒充者将代码推送到他人仓库中**。相关教程因为篇幅原因这里不列出。

> [!TIP]
>
> 每个设备在进行推送前都需要先创建`SSH key`并加入到Github中，否则这个设备所推送的内容会被认定为冒充者推送的。

### 推送远程库

​    可能你会有一个问题，假设在Github上创建两个远程仓库，在进行推送的时候git怎么知道推送的是哪个远程仓库呢？因此，在进行推送前需要先将远程仓库与本地仓库进行**关联**操作。

​    在上述的`Git-Study`仓库目录下执行命令`git remote`：

~~~bash
$ git remote add origin git@github.com:1-Nekomi/Git-Study.git
~~~

​    上述命令中请注意将`1-Nekomi`替换为自己的Github账户名，否则会推送到笔者的仓库，且一定会失败（可以思考为什么）。

​    添加后远程库名字就是`origin`，这是git的默认叫法，也可以改成其他名字。

​    使用命令`git push`可以进行 **推送(push)** 操作：

~~~bash
$ git push -u origin main
Enumerating objects: 12, done.
Counting objects: 100% (12/12), done.
Delta compression using up to 32 threads
Compressing objects: 100% (7/7), done.
Writing objects: 100% (12/12), 1.02 KiB | 524.00 KiB/s, done.
Total 12 (delta 1), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (1/1), done.
To github.com:1-Nekomi/Git-Study.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
~~~

​    上述命令将本地的`main`分支推送到远程，而且由于远程库是空的，第一次推送时加上了参数`-u`，这样不但会**把本地的`main`分支内容推送远程新的`main`分支**，还会**把两者关联起来**，后续命令就可以简化成：

~~~bash
$ git push origin main
~~~

---

本部分关键代码：

~~~bash
git remote add <online_name> git@github.com:<user_name>/<repository_name>.git
git push [-u] <online_name> <local_branch_name>
~~~

---

### 删除远程库

​    如果想要删除远程库，则可以使用命令`git remote rm`，在使用前可以先用命令`git remote -v`查看远程库信息：
~~~bash
$ git remote -v
origin  git@github.com:1-Nekomi/Git-Study.git (fetch)
origin  git@github.com:1-Nekomi/Git-Study.git (push)
~~~

然后根据**远程库名字**删除，比如：

~~~bash
$ git remote rm origin
~~~

此处的删除其实只是**解除了本地和远程的绑定关系，并没有物理意义上删除远程库**。远程库此时并没有任何改动，如果需要物理意义上删除远程库，需要登录到Github上进行操作，这里就不介绍了。

---

本部分核心代码：

~~~bash
git remote -v
git remote rm origin
~~~

---

### 克隆远程库

​    回到原来的问题，在通过原来的设备将本地仓库推送到Github上后，新设备就可以通过 **克隆(clone)** 操作来将远程库克隆到新设备本地变成本地仓库。

​    以上面的`Git-Study`为例，打开一个空目录，使用命令`git clone`：
~~~bash
$ git clone git@github.com:1-Nekomi/Git-Study.git
~~~

但SSH形式的克隆是有限制的，也就是**只能克隆你名下的仓库**，假设你需要克隆其他人的仓库，你有两种选择：

1. 使用Github上的`fork`选项将他人的仓库创建一个副本放在自己的账号中，再使用`SSH`形式的`git clone`命令

2. 直接通过`HTTPS`网址克隆，以上述仓库为例：
   ~~~bash
   $ git clone https://github.com/1-Nekomi/Git-Study.git
   ~~~

---

本部分核心代码：

~~~bash
$ git clone <SSH/HTTPS>
~~~

---

## 分支管理

​    **分支(branch)** 是git管理中较为重要的一个概念，我们假设这样一个场景，一个仓库存储了一个最基本的软件模板，后续需要基于这个仓库开发一个新的功能，但是为了防止新增的代码破坏了原有的完好代码，需要新开一个分支，在这个分支上完成功能后再合并回主分支即可。

​    当然，分支的作用也不只局限于此，还有很多自由使用的场景，这里就不一一列举。

​    在上述的`Git-Study`仓库中，每次提交都会成为一个**提交节点**，并根据时间串成一个时间线，这条时间线就是名为`main`的主分支（git主分支名字默认为`master`），而之前提到过的`HEAD`指针，严格意义上指的并不是某个具体的提交节点，而是**指向主分支**，而**主分支名字才是指向提交节点**。

​    为了方便理解，可以通过下面的图进行理解。

![初始状态](/images/unit/1000000000/4.png)

在上述图中，**每次提交都会使`main`分支向前移动一步，分支的线也会越来越长**。当我们创建一个新的分支`dev`时，Git会新建一个指针`dev`，并把`HEAD`指针指向`dev`指针，说明当前分支位于`dev`上，如下图所示：
![新增分支dev](/images/unit/1000000000/5.png)

而此时假设我们新增一个提交，`dev`指针就会往前一步，而`main`指针由于此时`HEAD`并没有指向它，因此不会变化，如下图所示:

![dev新增提交](/images/unit/1000000000/6.png)

假设在`dev`上的工作已经完成，需要合并回主分支，则会将`main`指针移动到`dev`指针的位置，且将`HEAD`指针指向`main`指针，如下图所示：

![合并dev分支](/images/unit/1000000000/7.png)

接着删除`dev`分支就会把`dev`指针删除，如图所示：

![删除dev分支](/images/unit/1000000000/8.png)

可能你会疑惑这样做有什么用，因为假设不新增`dev`分支，就在`main`上进行工作，就算出错了也可以回退内容，因此实际上分支适用于 **多人协作** 场景。现在不理解影响不大，通过后续的学习可以对分支有更深的理解。

### 创建与合并分支

​    可以通过命令`git branch`来创建新的分支：
~~~bash
$ git branch dev
~~~

然后可以使用`git checkout`来切换到我们新创建的`dev`分支：

~~~bash
$ git checkout dev
Switched to branch 'dev'
~~~

当然，也可以通过命令`git switch`来进行分支切换：

~~~bash
$ git switch dev
Switched to branch 'dev'
~~~

> [!TIP]
>
> 上述命令也可以通过一条命令实现：
> ~~~bash
> $ git checkout -b dev
> ~~~
>
> 如果使用`switch`来切换分支，则：
> ~~~bash
> $ git switch -c dev
> ~~~


接着可以使用`git branch`命令来查看当前分支：

~~~bash
$ git branch
* dev
  main
~~~

​    我们在`test.txt`文件中新增一行：
~~~txt
Git is free software distributed under the GPL.
Git is a distributed version control system.
Git has a mutable index called stage.
Creating a new branch #新增一行
~~~

然后将这个修改进行提交，并切换至`main`分支：

~~~bash
$ git checkout main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
~~~

此时查看`test.txt`文件我们可以发现刚刚加入的`Creating a new branch`不见了，这是因为{{< spoiler >}}**刚刚的提交是在`dev`分支上进行的**{{< /spoiler >}}。

​    现在我们将`dev`分支的提交合并到`main`主分支上，可以使用命令 `git merge` **将指定分支合并到当前分支**：
~~~bash
$ git merge dev
Updating 821b8b9..beef496
Fast-forward
 test.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
~~~

上述信息中的`Fast-forward`说明本次合并是直接将`main`指针指向了`dev`指针指向的提交，因此速度很快。接着可以删除`dev`分支：
~~~bash
$ git branch -d dev
Deleted branch dev (was beef496).
~~~

这样一来就只剩`main`分支了，可以通过`git branch`命令进行验证。

​    在上述过程中，假设分支开发出现了问题，不能将其合并回主分支，且代码已经无法恢复，只能强制删除分支，则需要带上`-D`参数：

~~~bash
$ git branch -D dev
Deleted branch dev (was beef496).
~~~

---

本部分核心代码

~~~bash
git branch [-d | -D] [<branch_name>]
git checkout [-b] <branch_name>
git switch [-c] <branch_name>
git merge <branch_name>
~~~

---

### 解决冲突

​    但是分支合并往往不会一帆风顺，举个例子：我们新建一个分支`feature1`，并修改`test.txt`文件,在`feature1`分支上提交修改后切换回`main`分支，在`main`分支上修改`test.txt`文件并在该分支上提交修改。两次修改如下：

~~~
# 在feature1上的修改
Git is free software distributed under the GPL.
Git is a distributed version control system.
Git has a mutable index called stage.
Creating a new branch is quick.

# 在main上的修改
Git is free software distributed under the GPL.
Git is a distributed version control system.
Git has a mutable index called stage.
Creating a new branch is simple.
~~~

此时`main`和`feature1`两个分支都有了各自的提交，此时提交树会变成这样：

![提交树](/images/unit/1000000000/9.png)

此时执行命令`git merge`就会发现分支合并产生了冲突：

~~~bash
$ git merge feature1
Auto-merging test.txt
CONFLICT (content): Merge conflict in test.txt
Automatic merge failed; fix conflicts and then commit the result.
~~~

这个时候Git无法进行自动合并，需要我们去手动处理合并冲突，此时直接查看`test.txt`文件的内容：
~~~txt
Git is free software distributed under the GPL.
Git is a distributed version control system.
Git has a mutable index called stage.
<<<<<<< HEAD
Creating a new branch is simple.
=======
Creating a new branch is quick.
>>>>>>> feature1
~~~

可以看到Git用`<<<<<<<`,`=======`,`>>>>>>>`标记了不同分支的内容，我们修改如下内容后保存并进行提交：
~~~txt
Git is free software distributed under the GPL.
Git is a distributed version control system.
Git has a mutable index called stage.
Creating a new branch is simple and quick.
~~~

~~~bash
$ git add test.txt & git commit -m "conflict fixed."
[main b2cba10] conflict fixed.
~~~

现在分支树就变成了如下图所示的样子：
![解决冲突后的分支树](/images/unit/1000000000/10.png)

此时我们可以通过带参数的`git log`来查看合并情况：

~~~bash
$ git log --graph --pretty=oneline --abbrev-commit
*   b2cba10 (HEAD -> main) conflict fixed.
|\
| * fd1656f (feature1) add quick
* | 3706292 add simple
|/
* beef496 branch test
* 821b8b9 (origin/main) add index
* b413bea append distributed
* c323a33 append GPL
* 68d4c46 wrote a test file.
~~~

当然也可以通过`vscode`中自带的git管理工具查看。最后删除`feature1`分支，冲突就算解决了。
~~~bash
$ git branch -d feature1
Deleted branch feature1 (was fd1656f).
~~~

### 合并模式

​    在进行合并时，git一般是使用`Fast-forward`模式，在这个模式下删除分支后会丢失分支信息，因此可以在进行合并时带上`--no-ff`参数来禁用`Fast-forward`模式，这样git在进行合并操作时会生成一个新的`commit`，这样就可以**从分支历史上看出分支信息**。

​    首先创建一个`dev`分支，在该分支下修改`text.txt`文件，并进行提交，后面切换回`main`分支，准备合并`dev`分支：
~~~bash
$ git merge --no-ff -m "merge with no-ff" dev
Merge made by the 'ort' strategy.
 test.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
~~~

因为本次需要创建一个`commit`,所以需要带上`-m`参数。合并后的分支树如下图所示：
![解决冲突后的分支树](/images/unit/1000000000/10.png)

合并后查看分支树结构：

~~~bash
$ git log --graph --pretty=oneline --abbrev-commit
*   a803d44 (HEAD -> main) merge with no-ff
|\
| * 87efbf7 (dev) add simple and quick
|/
* beef496 branch test
...
~~~

---

本部分核心代码：

~~~bash
git merge --no-ff -m <message> <branch_name>
~~~

---

### 工作区储藏与分支同步

​    假设在开发的过程中，在`main`分支上有一个bug急需要我们进行修复，但在`dev`分支上的工作没有完成，没办法进行提交。可能这里你会有一个问题，我们不提交直接切换到`main`分支上不行吗，按理来说，`main`分支应该看不见`dev`分支上的修改吧？

​    然而，这里需要注意的是：**git上所有未提交的修改，对于所有分支都是可见的，并且这些修改最终都是会被某次提交独占**。

​    举个例子，我们在上述的`dev`分支上修改`test.txt`文件，但不进行提交，直接切换到`main`分支，然后使用`git status`命令：
~~~bash
$ git status
On branch main
Your branch is ahead of 'origin/main' by 3 commits.
  (use "git push" to publish your local commits)

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   test.txt

no changes added to commit (use "git add" and/or "git commit -a")
~~~

我们可以注意到即使切换到`main`分支，在`dev`分支上的修改依然可以被`main`分支捕捉，假设此时我们在`main`分支上进行提交的话，最终在`dev`分支上的修改就会被记录在`main`分支上。

​    因此仅仅只是切换分支是没办法隐藏`dev`分支上的修改的，需要先将在`dev`分支上在工作区中的修改进行储藏，用命令`git stash`就可以做到(注意要在**需要储藏工作区修改的分支**上执行)：

~~~bash
$ git stash
Saved working directory and index state WIP on dev: 87efbf7 add simple and quick
~~~

此时我们就注意到原来在`test.txt`文件的上的修改不见了，切换回`main`分支使用`git status`也不会有未提交的修改。这样就可以在`main`分支上创建一个新的分支用于修复bug了。

​    修复完成后，回到`dev`分支我们需要恢复我们原来的工作区修改，先使用`git stash list` **查看储藏的工作区修改**：

~~~bash
$ git stash list
stash@{0}: WIP on dev: 87efbf7 add simple and quick
~~~

可以看到有一份待恢复的工作区修改，恢复有两种方法：

1. 用`git stash apply`恢复，但恢复后储藏的工作区修改备份并不会被删除，需要额外执行`git stash drop`来删除；
2. 用`git stash pop`恢复，恢复后会删除储藏的工作区备份。

上述命令在有多份工作区储藏的前期下，默认会先恢复**最新的那一份**。但是在恢复工作区前，需要保证**当前状态的工作区中不存在任何未提交的修改**，否则会产生报错，如下所示：
~~~bash
$ git stash pop
error: Your local changes to the following files would be overwritten by merge:
        test.txt
Please commit your changes or stash them before you merge.
Aborting
On branch dev
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   test.txt

no changes added to commit (use "git add" and/or "git commit -a")
The stash entry is kept in case you need it again.
~~~

恢复的时候也可以恢复指定的`stash`，例如：

~~~bash
$ git stash apply stash@{1}
~~~

​    在`main`分支上修复了bug后，不难想到，`dev`分支假设是在早期的`main`分支中的版本分出来的，那么按理来说`dev`分支中也会有这个bug，但是重复操作太冗余了，因此我们可以将在`main`分支上**将为了修复bug所做的修改复制到`dev`分支**中即可：

~~~bash
$ git cherry-pick <main-commit_id>
~~~

这样git会自动在`dev`分支中进行一次提交，完成同步分支之间的修改，不用多次重复操作。

---

本部分核心代码：

~~~bash
git stash [ < pop | list | < apply | drop> [stash@{<number>}] ]
git cherry-pick <commit_id>
~~~

---

### 分支推送与抓取

​    推送分支就是将分支上所有本地提交推送到远程库。这样git就会将该分支推送到远程库，例如推送`dev`分支：
~~~bash
$ git push origin dev
~~~

​    在进行多人协作的时候，有时候可能会遇到推送失败的情况，一般是由于**远程库分支冲突**导致的。举个例子，假设存在另一个开发者**DV**和我们一起进行协同开发，他先在他的设备上`clone`了我们的远程库：
~~~bash
$ git clone https://github.com/1-Nekomi/Git-Study.git
~~~

但是默认情况下DV只能看到本地的`main`分支，为了在`dev`分支上与我们一起协同工作，他也创建了远程`origin`的`dev`分支到本地：

~~~bash
$ git checkout -b dev origin/dev
~~~

接着他在`dev`分支上进行修改，然后`push`到远程。但很不巧的是，我们正好也在`dev`分支上对`test.txt`文件进行了修改，我们尝试推送到远程：
~~~bash
$ git push origin dev
To github.com:1-Nekomi/Git-Study.git
 ! [rejected]        dev -> dev (fetch first)
error: failed to push some refs to 'github.com:1-Nekomi/Git-Study.git'
hint: Updates were rejected because the remote contains work that you do not
hint: have locally. This is usually caused by another repository pushing to
hint: the same ref. If you want to integrate the remote changes, use
hint: 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
~~~

可以看到推送失败了，因为**DV的提交与我们的提交冲突**了，这个时候只需要先**从远程把DV的提交拉取到本地，然后手动解决冲突后再推送到远程**就可以了,使用命令`git pull`可进行拉取：
~~~bash
$ git pull
~~~

这个时候有可能会失败，原因是**没有指定本地`dev`与远程`origin/dev`分支的链接**，可以利用`git branch`设置`dev`和`origin/dev`的链接：
~~~bash
$ git branch --set-upstream-to=origin/dev dev
~~~

拉取成功后打开`test.txt`文件，手动解决冲突后再进行推送。

---

本部分核心代码：

~~~bash
git push <origin_name> <local_branch_name>
git checkout -b <local_branch_name> <origin_branch_name>
git pull
git branch --set-upstream-to=<origin_branch_name> <local_branch_name>
~~~

---

### 分支策略

| 分支类型      | 稳定性         | 来源（从哪里拉） | 归宿（合并到哪里）         | 用途                 |
| :------------ | :------------- | :--------------- | :------------------------- | :------------------- |
| **`main`**    | 极稳定         | -                | -                          | 仅存放线上正式版本   |
| **`dev`**     | 不稳定         | `main`           | `main`（通过   `release`） | 日常集成本地测试     |
| **`feature`** | 不稳定         | `dev`            | `dev`                      | 开发新功能           |
| **`bugfix`**  | 不稳定         | `dev`            | `dev`                      | 修复测试环境 Bug     |
| **`hotfix`**  | 不稳定（紧急） | **`main`**       | **`main` 和 `dev`**        | 修复线上紧急 Bug     |
| **`release`** | 较稳定         | `dev`            | **`main` 和 `dev`**        | 正式发版前的回归测试 |

## 标签管理

​    **标签(tag)** 一般是用来代表某个提交的节点，标签就是版本库的一个快照，通俗点讲也就是**版本号**，其与某个`commit`绑定在一起。

### 创建标签

​    首先切换到要打标签的分支上，然后使用命令`git tag`：
~~~bash
$ git tag v1.0
~~~

可以使用`git tag`命令来查看所有标签：

~~~bash
$ git tag
v1.0
~~~

上述操作默认是在最新的`commit`上进行的，如果想要在过去某个`commit`上打标签，需要提供对应的`commit id`：

~~~bash
$ git tag v0.9 <commit_id>
~~~

同时，也可以创建有说明的标签：

~~~bash
$ git tag -a v0.1 -m "version 0.1 released" <commit_id>
~~~

标签不是按时间列出的，而是**按字母排序**的，使用命令`git show`来查看标签信息：

~~~bash
$ git show v0.9
~~~

> [!NOTE]
>
> 标签总是和某个`commit`挂钩，假设这个`commit`同时出现在两个分支上，那么这两个分支上都可以看到这个标签。

---

本部分核心代码：

~~~bash
git tag [-a] <tag_name> [-m <message>] [<commit_id>]
git show <tag_name>
~~~

---

### 操作标签

​    假设标签打错了，可以进行删除，如果标签没有进行推送，则可以在本地删除：

~~~bash
$ git tag -d v0.1
~~~

反之，假设已经推送到远程了，则需要先删除本地的标签，然后再从远程删除:
~~~bash
$ git push origin :refs/tags/v0.1
~~~

从Git 1.7.0起，支持更直观的语法：
~~~bash
# 删除远程标签
$ git push origin --delete v0.1
# 等效
$ git push origin :v0.1
~~~

​    假设需要将标签推送到远程，可以使用命令：

~~~bash
$ git push origin v1.0 # 推送v1.0标签
$ git push origin --tags # 推送全部尚未推送的本地标签
~~~

---

本部分核心代码：

~~~bash
git tag -d <tag_name>
git push <origin_name> < --delete <tag_name>| :refs/tags/<tag_name> | :<tag_name> >
git push <origin_name> < <tag_name> | < --tags > >
~~~

---

---

   最后，需要提示的是上述命令格式大多数都是老版本的，但在新版本也能够得到支持，为了兼容性，学习老版的命令格式能够尽可能广泛地应用到各个仓库中。虽然现在有很多方便的GUI-git工具，但是在面对一些复杂情况的时候，还是命令操作更加方便直观。
