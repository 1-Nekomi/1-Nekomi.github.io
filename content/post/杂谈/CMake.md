---
title: CMake
description: 简述了跨平台编译工具CMake的一些基础用法

date: 2026-09-25T13:51:02+08:00
lastmod: 2026-09-25T13:51:02+08:00
tags:
 - 杂谈
 - 工具
 - 编译
categories:
 - 杂谈
math: false
mermaid: false
weight: 1000000003
---

# CMake

​    CMake是个一个开源的跨平台自动化建构系统，用来管理C/C++软件建置的程序，并不依赖于某特定编译器，并可支持多层目录、多个应用程序与多个函数库。CMake 通过使用简单的配置文件 **CMakeLists.txt** ，自动生成不同平台的构建文件（如Makefile、Ninja构建文件、Visual Studio工程文件等），简化了项目的编译和构建过程。

CMake 本身不是构建工具，而是生成构建系统的工具，它生成的构建系统可以使用不同的编译器和工具链。

学习CMake这个工具有助于帮助简化编写编译脚本的流程，这里以make为例讲述CMake的一些基础用法。

## CMakeLists.txt文件基础

​    CMakeLists.txt文件是CMake的核心配置文件，每个CMake项目至少需要一个CMakeLists.txt文件，在该文件中我们需要 **按顺序** 指明几个部分，以便于生成底层构建工具的文件。

### 指定CMake最低版本

​    在文件开头需要指明CMake的最低版本，语法如下：
~~~cmake
cmake_mininum_required(VERSION <version>)
~~~

其中的`<version>`需要指明CMake的版本号，如果不清楚机器上的CMake版本号，可以使用命令`cmake --version`来查看。

### 定义项目名称和语言

​    接着我们需要定义项目名称和语言，语法如下：
~~~cmake
project(<项目名> [VERSION <version>] [LANGUAGES <语言>...])
~~~

其中的版本和语言是可选参数，版本参数这里指的是共享库目标的版本，语言参数一般常用的有 **CXX、C** （CXX表示C++语言），在调用了`project()`后会自动设置`PROJECT_NAME`等变量。

### 添加可执行文件

​    该部分主要是设置一个最终生成的可执行文件，语法如下:
~~~cmake
add_executable(<target_name> <source_file>...)
~~~

上述的`<target_name>`和`<source_file>`都可以以路径的形式给出，前者可以直接使用`project()`生成的变量`PROJECT_NAME`变量，例如：
~~~cmake
add_exeadd_executable(${PROJECT_NAME} src/main.cpp)
~~~

### 添加库文件

​    假设该程序需要编译一些库，则需要指明一些参数，语法如下：
~~~cmake
add_library(<target_name> [STATIC | SHARED | MODULE] <source_file>...)
~~~

对于上述，需要指明编译出的库文件名，接着给出该库的属性：

- `STATIC`：静态库（.a/.lib），编译时直接嵌入可执行文件
- `SHARED`：动态库（.so/.dll），运行时加载
- `MODULE`：模块库，本质是动态库，但不能被`target_link_libraries`链接，只用于一些程序内部的插件，用代码显式调用。

当不指定类型时，由变量`BUILD_SHARED_LIBS`决定该库文件的类型。

最后给出编译该库文件所需要的源文件就可以编译出该库文件。

### 链接库

​    在编译完库或者需要链接一些外部库时，则可以选择编译时链接，语法如下：
~~~cmake
target_link_libraries(<target_name>
    <PRIVATE|PUBLIC|INTERFACE> <库或目标>...
    [<PRIVATE|PUBLIC|INTERFACE> <库或目标>...]...
)
~~~

其中`<target_name>`需要指定可执行文件或者其他库，对于三个作用域关键字的说明如下表所示：

|   关键字    | 当前目标是否使用 | 是否传递给依赖当前目标的其他目标 |     典型用途     |
| :---------: | :--------------: | :------------------------------: | :--------------: |
|  `PRIVATE`  |       使用       |              不传递              | 当前目标内部依赖 |
|  `PUBLIC`   |       使用       |               传递               | 当前目标公开依赖 |
| `INTERFACE` |      不使用      |               传递               | 接口库、头文件库 |

下面举个例子简单说明：
~~~cmake
add_library(my_lib STATIC my_lib.cpp)

target_link_libraries(my_lib
    PRIVATE internal_dep
    PUBLIC  public_dep
    INTERFACE interface_dep
)
~~~

- `internal_dep`：只给`my_lib`自己用。
- `public_dep`：`my_lib`自己用，同时链接`my_lib`的目标也会自动链接它。
- `interface_dep`：`my_lib`自己不用，但链接`my_lib`的目标会用到。

对于可执行文件目标，通常只使用`PRIVATE`参数。

### 设置变量

   在之前我们接触了一个变量`PROJECT_NAME`，这是由`project()`自动生成的一个变量，同理我们也可以自定义变量，语法如下：
~~~cmake
set(<变量名> <值>...)
~~~

一个变量可以同时设置多个值形成一个列表，例如：
~~~cmake
set(SOURCES main.cpp utils.cpp helper.cpp)
~~~

后续要使用该变量时，可以使用`${变量名}`来对其进行引用。

### 指定头文件路径

​    主要包含两种方法：`target_include_directories()`和`include_directories()`，两者对比如下表所示：

|      特性      |           `include_directories()`            |      `target_include_directories()`      |
| :------------: | :------------------------------------------: | :--------------------------------------: |
|  **作用范围**  | 全局作用域，影响当前目录及子目录中的所有目标 |    仅作用于指定的目标，不污染其他目标    |
|  **推荐程度**  |       不推荐，除非维护旧版 CMake 项目        |  推荐优先使用，符合现代 CMake 最佳实践   |
| **目标关联性** |  不直接关联到特定目标，可能意外影响其他目标  |   显式绑定到指定目标，依赖关系一目了然   |
|  **可维护性**  |   较差，容易导致全局路径污染，问题难以排查   |      较好，路径与目标绑定，逻辑清晰      |
| **可见性控制** |             无法精确控制传播范围             | 通过 PUBLIC、PRIVATE、INTERFACE 精确控制 |

这里就不介绍其中的`include_directories()`方法了，对于`target_include_directories()`，其语法如下：
~~~cmake
target_include_directories(<target>
    [SYSTEM] [AFTER|BEFORE]
    <INTERFACE|PUBLIC|PRIVATE> [items1...]
    [<INTERFACE|PUBLIC|PRIVATE> [items2...] ...]
)
~~~

- `<target>`：必须是由 `add_executable()` 或 `add_library()` 创建的目标，不能是 `ALIAS` 目标。
- `items`：要添加的包含目录，可以是绝对路径、相对路径（相对于当前源目录），或生成表达式。

#### 作用域关键字

这三个关键字决定了包含目录是否传递给依赖当前目标的其他目标。

|   关键字    | 当前目标是否使用 | 是否传递给消费者 |            典型场景            |
| :---------: | :--------------: | :--------------: | :----------------------------: |
|  `PRIVATE`  |        是        |        否        | 仅当前目标内部使用的头文件目录 |
|  `PUBLIC`   |        是        |        是        |  当前目标使用，且消费者也需要  |
| `INTERFACE` |        否        |        是        |  当前目标不使用，但消费者需要  |

类似于上述链接库中的作用域关键字，可以类比进行学习，这里就不再举例说明。

#### system关键字

`SYSTEM` 将包含目录标记为**系统包含目录**。

- 对于 GCC/Clang，会使用 `-isystem` 而不是 `-I`。
- 编译器会抑制这些目录中头文件产生的警告。
- 当与 `PUBLIC` 或 `INTERFACE` 一起使用时，系统属性也会传递给消费者。

#### BEFORE和AFTER

控制新添加的包含目录在已有包含目录列表中的位置。

- 默认是 `AFTER`，即追加到列表末尾。
- `BEFORE` 会插入到列表开头，使这些目录优先被搜索。

### 设置安装规则

​    主要用于定义执行命令`make install`时各类文件的安装位置，语法如下：
~~~cmake
install(TARGETS <目标>...
         [RUNTIME DESTINATION <可执行文件安装路径>]
         [LIBRARY DESTINATION <动态库安装路径>]
         [ARCHIVE DESTINATION <静态库安装路径>]
         [INCLUDES DESTINATION <头文件安装路径>])
~~~

### 条件语句

​    语法如下：
~~~cmake
if(<条件>) ... elseif(<条件>) ... else() ... endif()
~~~

支持的条件包含 **比较、逻辑运算、变量判断等** ，例如：
~~~cmake
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    # Debug 模式下启用调试信息
    message(STATUS "当前为 Debug 构建模式")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
else()
    # Release 模式下启用优化
    message(STATUS "当前为 Release 构建模式")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
endif()
~~~

### 自定义命令

​    语法如下：
~~~cmake
add_custom_command(
          TARGET <目标>
          PRE_BUILD | PRE_LINK | POST_BUILD
          COMMAND <命令> [参数...]
          [COMMENT <说明>]
          [VERBATIM])
~~~

其中的参数：

- `PRE_BUILD`：在编译前执行
- `PRE_LINK`：在链接前执行
- `POST_BUILD`：在构建完成后执行

例如：
~~~cmake
add_custom_command(
    TARGET MyApp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "构建完成！"
    COMMENT "打印构建完成信息"
)
~~~

### 查找库和包

​    有些外部库如果我们每一次都自己编写路径去显式链接，会十分麻烦，CMake提供了指令来帮助我们寻找和配置这些外部依赖。语法如下：
~~~cmake
find_package(<PackageName> [<version>] [REQUIRED] [COMPONENTS <components>...])
~~~

- `<PackageName>`：唯一的必选参数，要查找的包名。
- `[<version>]`：可选，指定所需的版本号，格式如 `1.2.3`。
- `[REQUIRED]`：可选，表示该包是必须的；找不到时 CMake 会报错并停止配置。
- `[COMPONENTS <components>...]`：可选，指定需要的包组件（模块）。

查找完成后，CMake会设置一个变量`<PackageName>_FOUND`，其值为`TRUE`或`FALSE`，表示是否找到。对于Config模式的包，通常会提供**导入目标（Imported Targets）**，推荐直接链接这些目标，例如：

~~~cmake
find_package(GTest REQUIRED)
find_package(Boost REQUIRED)

target_link_libraries(MyApp PRIVATE GTest::gtest_main)
target_link_libraries(MyApp PRIVATE Boost::Boost)
~~~

## 系统变量

​    有一些变量是CMake在构建过程中自动生成的，不需要我们自己去定义，这里列出一些常用的系统变量供读者参考：
### 目录与路径变量

这类变量用于获取项目源代码、构建产物的目录位置。

|           变量名           |                             说明                             |
| :------------------------: | :----------------------------------------------------------: |
|     `CMAKE_SOURCE_DIR`     |        工程顶层目录，即入口 `CMakeLists.txt` 所在路径        |
|     `CMAKE_BINARY_DIR`     | 工程编译发生的目录，即执行 `cmake` 命令进行项目配置的目录，一般为 `build` |
|    `PROJECT_SOURCE_DIR`    |                    同 `CMAKE_SOURCE_DIR`                     |
|    `PROJECT_BINARY_DIR`    |                    同 `CMAKE_BINARY_DIR`                     |
| `CMAKE_CURRENT_SOURCE_DIR` |            当前处理的 `CMakeLists.txt` 所在的路径            |
| `CMAKE_CURRENT_BINARY_DIR` |    当前处理的 `CMakeLists.txt` 中生成目标文件所在编译目录    |
| `CMAKE_CURRENT_LIST_FILE`  |      输出调用这个变量的 `CMakeLists.txt` 文件的完整路径      |
|  `CMAKE_CURRENT_LIST_DIR`  |        当前处理的 `CMakeLists.txt` 文件所在目录的路径        |
| `CMAKE_CURRENT_LIST_LINE`  |            当前执行 `CMakeLists.txt` 文件所在行号            |

> [!TIP]
>
> **`CMAKE_\*` 与 `CMAKE_CURRENT_\*` 的区别** ：`CMAKE_*` 始终指向顶级 `CMakeLists.txt` 文件，而 `CMAKE_CURRENT_*` 指向当前正在处理的 `CMakeLists.txt` 文件。在子目录中引用 `CMAKE_SOURCE_DIR` 可能指向父项目的顶层目录，需要特别注意。

### 系统与平台变量

这类变量用于判断目标平台，在跨平台构建和条件编译中至关重要。

|          变量名          |                             说明                             |
| :----------------------: | :----------------------------------------------------------: |
|   `CMAKE_SYSTEM_NAME`    | 不包含版本的系统名，如 `Linux`、`Windows`、`Darwin`（macOS） |
|  `CMAKE_SYSTEM_VERSION`  |                    系统版本，如 `2.6.22`                     |
|      `CMAKE_SYSTEM`      |           系统名称和版本的组合，如 `Linux-2.6.22`            |
| `CMAKE_SYSTEM_PROCESSOR` |               处理器名称，如 `i686`、`x86_64`                |
| `CMAKE_HOST_SYSTEM_NAME` | 运行 CMake 的主机的操作系统名称（交叉编译时与目标系统不同）  |
|   `CMAKE_HOST_SYSTEM`    |                   主机的系统名称和版本组合                   |
|          `UNIX`          |       在所有类 UNIX 平台为 `TRUE`，包括 OS X 和 Cygwin       |
|         `WIN32`          |          在所有 Windows 平台为 `TRUE`，包括 Cygwin           |
|         `APPLE`          |                   在 Apple 系统上为 `TRUE`                   |
|  `CMAKE_SIZEOF_VOID_P`   | 编译器检测到的目标体系结构 `void *` 的大小（4 或 8），可用于确定 32 位还是 64 位系统 |

> [!TIP]
>
> **交叉编译场景** ：`CMAKE_SYSTEM_NAME` 描述 **目标系统** ，`CMAKE_HOST_SYSTEM_NAME` 描述 **主机系统** 。在交叉编译时，应使用前者判断目标平台。注意 `WIN32`、`APPLE`、`UNIX` 等变量已被视为“软弃用”，推荐使用 `CMAKE_SYSTEM_NAME` 进行判断。

### 编译器与构建配置变量

|            变量名             |                             说明                             |
| :---------------------------: | :----------------------------------------------------------: |
|      `CMAKE_C_COMPILER`       |                   指定 C 编译器的完整路径                    |
|     `CMAKE_CXX_COMPILER`      |                  指定 C++ 编译器的完整路径                   |
|     `CMAKE_C_COMPILER_ID`     |      使用的 C 编译器标识符（如 `GNU`、`Clang`、`MSVC`）      |
|    `CMAKE_CXX_COMPILER_ID`    |                   使用的 C++ 编译器标识符                    |
|      `CMAKE_BUILD_TYPE`       | 构建类型，如 `Debug`、`Release`、`RelWithDebInfo`、`MinSizeRel` |
|        `CMAKE_C_FLAGS`        |                     C 编译器的命令行选项                     |
|       `CMAKE_CXX_FLAGS`       |                    C++ 编译器的命令行选项                    |
|    `CMAKE_CXX_FLAGS_DEBUG`    |            Debug 配置的 C++ 编译标记，如 `-g -O0`            |
|   `CMAKE_CXX_FLAGS_RELEASE`   |            Release 配置的 C++ 编译标记，如 `-O3`             |
|      `CMAKE_C_STANDARD`       |          指定项目编译的 C 语言版本，如 `C99`、`C11`          |
|     `CMAKE_CXX_STANDARD`      |       指定项目编译的 C++ 语言版本，如 `C++14`、`C++17`       |
| `CMAKE_CXX_STANDARD_REQUIRED` |    布尔值，是否强制使用 `CMAKE_CXX_STANDARD` 中设置的版本    |

> [!WARNING]
>
> - `CMAKE_C_COMPILER`、`CMAKE_CXX_COMPILER` 等变量一旦首次 configure 完成就会被缓存并锁定，后续无法更改。
> - 设置编译器应在 `project()` 命令之前，或通过 toolchain 文件设置。
> - `CMAKE_CXX_FLAGS` 是字符串类型，追加内容应使用 `string(APPEND CMAKE_CXX_FLAGS " ...")`。

### 查找与链接变量

这类变量控制 `find_package`、`find_library` 等命令的搜索行为。

|            变量名             |                             说明                             |
| :---------------------------: | :----------------------------------------------------------: |
|      `CMAKE_PREFIX_PATH`      |       指定额外的包查找路径，用于查找第三方库的安装目录       |
|     `CMAKE_INCLUDE_PATH`      |                   指定额外的头文件查找路径                   |
|     `CMAKE_LIBRARY_PATH`      |                   指定额外的库文件查找路径                   |
|    `CMAKE_FRAMEWORK_PATH`     |             指定额外的框架查找路径（macOS 系统）             |
|      `CMAKE_MODULE_PATH`      | `find_package` 和 `include` 命令搜索 CMake 模块的路径，默认为空 |
| `CMAKE_STATIC_LIBRARY_PREFIX` |               静态库的前缀，在 UNIX 上为 `lib`               |
| `CMAKE_STATIC_LIBRARY_SUFFIX` |               静态库的后缀，在 UNIX 上为 `.a`                |
| `CMAKE_SHARED_LIBRARY_PREFIX` |               动态库的前缀，在 UNIX 上为 `lib`               |
| `CMAKE_SHARED_LIBRARY_SUFFIX` |               动态库的后缀，在 UNIX 上为 `.so`               |

**`CMAKE_MODULE_PATH` 的使用**：将其设置为 `FindXXX.cmake` 文件所在目录，使 `find_package` 优先在指定路径中搜索模块。例如：

```cmake
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/modules)
```

`CMAKE_PREFIX_PATH` 通常通过命令行设置：

```cmake
cmake -DCMAKE_PREFIX_PATH=/opt/mylib ..
```

### 输出与安装变量

|              变量名              |                             说明                             |
| :------------------------------: | :----------------------------------------------------------: |
|      `CMAKE_INSTALL_PREFIX`      | `make install` 时的安装路径前缀，默认为 `/usr/local`（Linux）或 `C:/Program Files/${PROJECT_NAME}`（Windows） |
|     `EXECUTABLE_OUTPUT_PATH`     |            重新定义目标二进制可执行文件的存放位置            |
|      `LIBRARY_OUTPUT_PATH`       |               重新定义目标链接库文件的存放位置               |
| `CMAKE_RUNTIME_OUTPUT_DIRECTORY` |                 可执行文件和 DLL 的输出目录                  |
| `CMAKE_LIBRARY_OUTPUT_DIRECTORY` |                       库文件的输出目录                       |
| `CMAKE_ARCHIVE_OUTPUT_DIRECTORY` |                   静态库和导入库的输出目录                   |

`CMAKE_INSTALL_PREFIX` 可在配置时通过命令行指定：

```cmake
cmake -DCMAKE_INSTALL_PREFIX=/opt/myapp ..
```

若要在 `CMakeLists.txt` 中修改，需要使用 `CACHE` 选项：

```cmake
set(CMAKE_INSTALL_PREFIX "/opt/myapp" CACHE PATH "Install prefix" FORCE)
```

### 项目与版本变量

|          变量名          |                  说明                   |
| :----------------------: | :-------------------------------------: |
|      `PROJECT_NAME`      |    `project()` 命令中指定的项目名称     |
|   `CMAKE_PROJECT_NAME`   |             当前项目的名称              |
|     `CMAKE_VERSION`      |          当前使用的 CMake 版本          |
|  `CMAKE_MAJOR_VERSION`   |             CMake 主版本号              |
|  `CMAKE_MINOR_VERSION`   |             CMake 次版本号              |
|  `CMAKE_PATCH_VERSION`   |             CMake 补丁等级              |
|   `BUILD_SHARED_LIBS`    | 使用 `add_library` 时是否默认生成动态库 |
| `CMAKE_VERBOSE_MAKEFILE` |    设为 `TRUE` 时显示详细的编译命令     |

### 环境变量

环境变量通过 `$ENV{VAR}` 在 CMake 中访问，与 CMake 变量语法不同。

| 环境变量                     | 说明                                   |
| :--------------------------- | :------------------------------------- |
| `CMAKE_PREFIX_PATH`          | 环境变量版本，指定额外的包查找路径     |
| `CMAKE_INCLUDE_PATH`         | 环境变量版本，指定额外的头文件查找路径 |
| `CMAKE_LIBRARY_PATH`         | 环境变量版本，指定额外的库文件查找路径 |
| `CMAKE_BUILD_PARALLEL_LEVEL` | 指定并行构建的级别                     |
| `CMAKE_GENERATOR`            | 指定 CMake 生成器                      |
| `CC` / `CXX`                 | 指定 C/C++ 编译器                      |
| `CFLAGS` / `CXXFLAGS`        | 指定 C/C++ 编译选项                    |
| `LDFLAGS`                    | 指定链接器选项                         |
| `DESTDIR`                    | 安装时的临时目标目录                   |

> [!WARNING]
>
> 环境变量与 CMake 变量同名时，CMake 变量优先。例如 `CMAKE_PREFIX_PATH` 环境变量会被 CMake 变量覆盖。

---

上述提及的系统变量其实只有少部分会经常用到，因此这里不对每一个变量做详细介绍，这样就太过于复杂了。需要用到时再去查阅资料即可。

## 构建流程简述

​    对于大部门情况，下面介绍的步骤足以应付，这里因为篇幅问题就不介绍更复杂的构建流程。

| 步骤 |      操作      |               命令               |                         说明                         |
| :--: | :------------: | :------------------------------: | :--------------------------------------------------: |
|  1   |  创建构建目录  |    `mkdir build && cd build`     |      使用 Out-of-source 方式，保持源码目录整洁       |
|  2   |  生成构建文件  |            `cmake ..`            | 读取 CMakeLists.txt，生成 Makefile / Ninja / .sln 等 |
|  3   |   编译和构建   |        `cmake --build .`         |               执行实际的编译和链接过程               |
|  4   |  清理构建文件  | `cmake --build . --target clean` |           删除编译产生的中间文件和目标文件           |
|  5   | 重新配置和构建 |  `cmake .. && cmake --build .`   |         CMakeLists.txt 变更后重新生成并编译          |

---

本文仅仅只接触了一些较为简单的CMake的使用，对于一些中小型程序是完全足够的，但对于一些相当大的程序来说，还需要额外地学习一些进阶操作，但目前学习上述这些用法已经足够了。

参考资料：[CMake 教程 | 菜鸟教程](https://www.runoob.com/cmake/cmake-tutorial.html)