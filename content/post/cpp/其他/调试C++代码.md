---
title: 调试C++代码
description: 简单说明了如何利用assert和NDEBUG宏调试C++代码的操作

date: 2026-09-10T20:52:19+08:00
lastmod: 2026-09-10T20:52:19+08:00
tags:
 - C++
 - 调试
categories:
 - C++
math: false
mermaid: false
weight: 1002017000
---

# 调试C++代码

## assert宏

​    在之前学习python的pytest时，我们接触到了assert断言语句，同样的，在C++中也存在断言assert，但它在c++中是一个 **预处理宏（preproceessor marco）** ，位于头文件`cassert`中，它接收一个表达式作为判断依据：

~~~c++
assert(expr);
~~~

其中的表达式参数必须是 **标量类型** ，标量类型包括算术类型（整型、浮点型）、枚举类型、指针类型、成员指针类型，以及 `std::nullptr_t`。这意味着像类、结构体、数组等非标量类型不能直接作为assert的参数。

下面是一个简单的程序示例：
~~~c++
#include<iostream>
#include<cassert>

using namespace std;

int main(){
    int a,b;
    cin >> a >> b ;
    assert(a>b);

    return 0;
}
~~~

运行结果如下：
~~~bash
$ 1
$ 2
main: /home/nekomi/cpp_stu/src/main.cpp:9: int main(): Assertion `a>b' failed.
Aborted (core dumped)
~~~

可以看到因为没有满足断言的条件，程序产生了报错并退出运行，这和pytest中的断言语句作用是一致的。

> [!TIP]
>
> assert宏一般用于检查 **不能发生** 的条件。

## NDEBUG预处理变量

​    assert的行为依赖于一个名为NDBUG的预处理变量的状态，如果定义了NDEBUG，则assert宏则什么都不会做，因此其可以用于 **管理项目的调试开关** 。

> [!TIP]
>
> 在编译时就可以附带参数来让文件头附带NDEBUG宏声明,不同的编译器所需要的参数不同，这里列出一些常用的工具需要的参数，其他的请自行询问AI或者检索资料。
>
> 1. 命令行直接定义
>
>    ~~~bash
>    //GCC / Clang
>    g++ -DNDEBUG main.cpp
>    clang++ -DNDEBUG main.cpp
>    ~~~
>
>    ~~~cmd
>    //MSVC
>    cl /DNDEBUG main.cpp
>    ~~~
>
>    只要在包含`<cassert>`或 `<assert.h>` 之前 `NDEBUG` 已被定义，`assert` 就会展开为 `((void)0)`，即被禁用。
>
> 2. 通过构建系统定义
>
>    ~~~cmake
>    # cmake
>    # 全局添加
>    add_compile_definitions(NDEBUG)
>    
>    # 或针对某个 target
>    target_compile_definitions(my_target PRIVATE NDEBUG)
>    ~~~
>
>    CMake 的 `Release` 配置默认就会添加 `-DNDEBUG`，可查看 `CMAKE_CXX_FLAGS_RELEASE`。
>    
>
>    ~~~makefile
>    CXXFLAGS += -DNDEBUG
>    ~~~
>
>
>    ~~~python
>    cc_binary(
>        name = "app",
>        srcs = ["main.cpp"],
>        copts = ["-DNDEBUG"],
>    )
>    ~~~
>
>    ~~~meson
>    add_project_arguments('-DNDEBUG', language: 'cpp')
>    ~~~
>
> 3. 如果非要在头文件里定义
>
>    可以创建一个公共配置头，但必须保证它在任何 `<cassert>` 之前被包含：
>
>    ~~~c++
>    // config.h
>    #ifndef NDEBUG
>    #define NDEBUG
>    #endif
>    ~~~
>
>    然后在每个源文件的最开头包含`config.h`头文件即可。

同时可以用NDEBUG宏来辅助输出一些调试错误信息，例如：
~~~C++
#include<iostream>
#include<cassert>

using namespace std;

int main(){
    #ifndef NDEBUG
        cerr<< __func__ << " error";
    #endif

    return 0;
}
~~~

运行结果如下：
~~~bash
main error
~~~

其中的`__func__`是编译器定义的一个局部静态变量，用于存放函数的名字，除了这个以外，预处理器还有其他另外4个对于程序调试很有用的名字，这里一并列出：
|    名字    |              作用              |
| :--------: | :----------------------------: |
| `__func__` |  存放当前函数名的字符串字面值  |
| `__FILE__` |  存放当前文件名的字符串字面值  |
| `__LINE__` |    存放当前行号的整形字面值    |
| `__TIME__` | 存放文件编译时间的字符串字面值 |
| `__DATE__` | 存放文件编译时期的字符串字面值 |

上面的字段可以在程序运行过程中提供更多的信息。

---

​    调试C++代码使用assert宏的话可以提供更完善的信息，但是如果滥用assert和NDEBUG宏会导致程序可读性变差，最好在发布正式代码前删除掉调试代码。