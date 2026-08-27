---
title: 用Python调用C/C++代码
description: 简述了如何使用Python来调用用C/C++编写的代码

date: 2026-08-27T16:24:20+08:00
lastmod: 2026-08-27T16:24:20+08:00
tags:
 - Python
 - C
 - C++
 - 跨语言编程
categories:
 - python
math: false
mermaid: false
weight: 1003004001
---

# 用Python调用C/C++代码

​    Python具有很方便的语法，有时候为了测试或者调用C/C++的代码，我们不得不写较为复杂的测试或者调用主体文件，而python本身就是用C语言编写的，因此python能直接理解C语言的库并调用，但对于C++，则需要用到一些第三方库。

下面是主流的几种方法：
|    方法    |                   适用场景                    |               优点                |                     缺点                      |
| :--------: | :-------------------------------------------: | :-------------------------------: | :-------------------------------------------: |
|  `ctypes`  |         调用现有的、简单的C/C++动态库         |   无需额外工具，Python原生内置    | 处理复杂数据结构较为繁琐，且无法直接调用C++类 |
|  `Cython`  |  需要将C/C++代码集成到Python中以优化性能瓶颈  | 性能较高，可无缝结合Python和C代码 |           有独特语法，学习成本较高            |
| `pybind11` | 现在C++项目首选，尤其是需要暴露复杂C++接口时  |  语法现代，简洁，对C++特性支持好  |               需要引入第三方库                |
|   `SWIG`   | 大型项目，需要为同一份C++代码生成多种语言代码 |       功能强大，支持语言多        |        接口文件语法较复杂，学习成本高         |
|   `CFFI`   |       需要比`ctype`更强大的C交互能力时        | 设计干净，处理复杂C数据结构更优雅 |               需要引入第三方库                |

由于篇幅以及笔者本人的原因，这里只介绍前三种方式，后两种方式可能会在以后单独提及。

## ctypes

​    ctypes是python标准库的一部分，可以直接加载C/C++编译好的 **动态链接库（Windows `.dll`，Linux `.so`）** ，并调用其中的函数。

> [!TIP]
>
> 虽然明面上说ctypes也能调用C++代码，但实际上只能调用采用了`extern "C"`模式编译的C++代码，因此无法调用类。

操作步骤如下：

1. 编写C/C++代码：
   ~~~C++
   // example.cpp
   
   #include<iostream>
   
   extern "C"{
       int add(int a,int b){
           return a+b;
       }
       void greet(const char* name){
           std::cout << "Hello," << name << "!" << std::endl;
       }
   }
   ~~~

2. 编译成动态库：
   ~~~bash
   # Linux/macOS
   $ g++ -shared -fPIC -o libexample.so example.cpp
   # Windows
   $ g++ -shared -o example.dll example.cpp 
   ~~~

3. 接着在python中调用：使用`ctypes.CDLL()`方法来调用函数

   ~~~python
   # main.py
   
   import ctypes
   
   lib = ctypes.CDLL('./libexample.so') # Windows改为 .dll
   result = lib.add(10,20)
   print(result)
   
   lib.greet.argtypes = [ctypes.c_char_p]
   lib.greet(b"World")
   ~~~

   运行结果如下：
   ~~~bash
   30
   Hello,World!
   ~~~

## Cython

​    Cython是Python的超集，它允许在python代码中直接声明C类型和调用C函数，它会将`.pyx`文件编译成C代码，再编译成Python拓展模块。可以利用方式对计算密集的部分进行优化。

操作步骤如下：

1. 安装Cython：
   ~~~bash 
   $ pip install cython
   ~~~

2. 编写C++代码：
   ~~~C++
   // exmath.h
   #ifdef __cplusplus
   extern "C" {
   #endif
   
   int add(int a, int b);
   
   #ifdef __cplusplus
   }
   #endif
   
   // exmath.cpp
   #include"exmath.h"
       
   extern "C"{
       int add(int a,int b){return a+b;}
   }
   ~~~
   
3. 编写Cython接口文件`math_cython.pyx`，声明并封装C++函数：
   ~~~python
   # math_cython.pyx
   
   cdef extern from "exmath.h":
       int add(int a, int b)
   
   def py_add(int a,int b):
       return add(a,b)
   ~~~

4. 编写`setup.py`来编译模块：
   ~~~python
   # setup.py
   from setuptools import setup, Extension
   from Cython.Build import cythonize
   
   ext_modules = {
       Extension(
           name='math_cython',
           sources=["math_cython.pyx","exmath.cpp"],
           language='C++',
       )
   }
   setup(ext_modules=cythonize(ext_modules))
   ~~~

5. 执行命令编译：
   ~~~bash
   $ python setup.py build_ext --inplace
   ~~~

   > [!TIP]
   >
   > 若在Linux上可以能会出现编译错误，一般是由于缺少`python3-dev`库导致的，安装后可能会解决问题。

6. 导入使用：
   ~~~python
   # main.py
   import math_python
   
   print(math_python.py_add(3,4))
   ~~~

   运行结果如下：
   ~~~bash
   7
   ~~~

用这种方法可能会折腾一阵子，导致开发效率不及ctypes，因此该方法在日常使用中并不推荐使用。

## pybind11

​    这是一个轻量级的头文件库，主要专注于C++与python之间交互，它语法简洁，能很好地处理C++的类、函数重载等复杂特性，Pytorch等经典项目也在用它。

操作步骤：

1. 安装pybind11：
   ~~~bash
   $ pip install pybind11
   ~~~

2. 编写C++代码并绑定：
   ~~~c++
   // example.cpp
   #include<pybind11/pybind11.h>
   #include<string>
   namespace py = pybind11;
   
   int add(int a,int b){
       return a+b;
   }
   
   class Pet {
       std::string name;
   
       // 构造函数
       Pet(const std::string &name) : name(name) {}
   
       // 成员函数
       void setName(const std::string &name_) { name = name_; }
       const std::string &getName() const { return name; }
   };
   
   //使用 PYBIND11_MODULE 宏创建模块
   // 绑定函数
   PYBIND11_MODULE(example, m){
       m.doc() = 'pybind11 example module';
       m.def("add",&add,"A  function that adds two numbers");
   }
   
   // 绑定类
   PYBIND11_MODULE(example, m) {
       // 使用 py::class_ 绑定 Pet 类
       py::class_<Pet>(m, "Pet")
           // 绑定构造函数
           .def(py::init<const std::string &>())
           // 绑定成员函数
           .def("setName", &Pet::setName)
           .def("getName", &Pet::getName);
   }
   ~~~

3. 使用setuptools进行编译：
   ~~~python
   # setup.py
   from setuptools import setup, Extension
   import pybind11
   
   ext_modules = [
       Extension(
           'example',                     # 模块名（Python import 时使用）
           sources=['example.cpp'],       # 源文件列表
           include_dirs=[
               pybind11.get_include(),    # pybind11 头文件路径
               # 如果还有自定义头文件，在这里添加
           ],
           language='c++',
           extra_compile_args=['-std=c++11', '-O3'],  # 或 -std=c++14/17
           extra_link_args=[],
       ),
   ]
   
   setup(
       name='example',
       ext_modules=ext_modules,
       # 如果使用较新的 setuptools，可能需要：
       # zip_safe=False,
   )
   ~~~

   ~~~bash
   $ python setup.py build_ext --inplace
   ~~~

4. 导入使用：
   ~~~python
   # main.py
   import example as ex
   
   print(ex.add(4,1))
   
   dog = ex.Pet('Jack')
   print(dog.getName())
   dog.setName('John')
   print(dog.getName())
   ~~~

   运行结果如下：
   ~~~bash
   5
   Jack
   John
   ~~~

对于pybind，其复杂度虽然和Cython差不多（大部分是由编译工具setuptools引入的），但由于其可以处理C++的类等机制，因此比Cython更值得学习。同时pybind对众多c++特性也有很好的支持，但这里不再列出，待以后学习c++的过程中单独列出。

---

综合来看，学习ctypes和pybind11已经能够应付绝大部分python调用C/C++的场景，因此学习这两个工具是性价比较高的方式。

