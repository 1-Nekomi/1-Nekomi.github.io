---
title: C++异常处理
description: 简述了C++中异常处理的机制

date: 2026-09-04T21:07:11+08:00
lastmod: 2026-09-04T21:07:46+08:00
tags:
 - C++
 - 异常
categories:
 - C++
math: false
mermaid: false
weight: 1002015000
---

# C++异常处理

作为一个可以进行OOP编程的语言，C++也能够进行异常处理，异常处理能够帮助我们在应对反常的程序行为时正确地进行处理，关于C++中的相关机制在这里做个简单的介绍。

## throw表达式

​    一般形式为：
~~~C++
throw execption(message)
~~~

下面是一个简单的示例：
~~~c++
#include<iostream>
using namespace std;

int main(){
    int nums[] = {1,-1,2,3,4};
    for(int num : nums){
        if(num < 0)
            throw runtime_error("列表不能存放负数");
    }
    
    return 0;
}
~~~

运行结果如下：
~~~bash
terminate called after throwing an instance of 'std::runtime_error'
  what():  列表不能存放负数
Aborted (core dumped)
~~~

可以看到顺利抛出了`std::runtime_error`异常并终止了程序。

## try-catch块

​    `try`块内写程序执行代码，`catch`用于捕获异常，块内写处理异常的代码。一般形式如下：
~~~c++
try{
    statements
}catch(exception-declaration){
    statements
}catch(...){
    ...
} //...
~~~

下面是一个简单的示例：
~~~c++
#include<iostream>
using namespace std;

int main(){
    int lval,rval;
    try{
        cin >> lval >> rval;
        if(!rval) throw runtime_error("除数不能为0");
        int num = lval/rval;
        cout<< num ;
    }catch(runtime_error err){
        cout << err.what()
             << " 重新输入除数" << endl;
        cin >> rval;
        cout<< lval / rval <<endl;
    }
    
    return 0;
}
~~~

运行结果如下：
~~~bash
$ 10 0
除数不能为0 重新输入除数
$ 2
5
~~~

> [!TIP]
>
> 在捕获了异常并声明了异常数据变量后，可以使用`what()`方法来获取异常的信息，该方法会返回`const char*`格式的字符串，内容为抛出异常时附带的message。
>
> 同时，当没有匹配的catch块时，程序会调用标准库函数 **terminate** 来负责终止程序的执行过程。

## 标准异常

​    C++中有一组标准异常用于报告标准库函数遇到的问题，这些异常也可以用于用户的程序中使用，如下表所示：
|     异常类型      |       头文件        |                      含义                      |
| :---------------: | :-----------------: | :--------------------------------------------: |
|    `exception`    | exception/stdexcept |                  最常见的问题                  |
|  `runtime_error`  |      stdexcept      |               运行时检测到的问题               |
|   `range_error`   |      stdexcept      |  运行时错误：生成的结果超出了有意义的值域范围  |
| `overflow_error`  |      stdexcept      |              运行时错误：计算上溢              |
| `underflow_error` |      stdexcept      |              运行时错误：计算下溢              |
|   `logic_error`   |      stdexcept      |                  程序逻辑错误                  |
|  `domain_error`   |      stdexcept      |        逻辑错误：参数对应的结果值不存在        |
|  `invalid_error`  |      stdexcept      |               逻辑错误：无效参数               |
|  `length_error`   |      stdexcept      | 逻辑错误：试图创建一个超出该类型最大长度的对象 |
|  `out_of_range`   |      stdexcept      |       逻辑错误：使用一个超出有效范围的值       |
|    `bad_alloc`    |         new         |               分配堆内存空间失败               |
|    `bad_cast`     |      type_info      |        `dynamic_cast`转换为引用类型失败        |

> [!WARNING]
>
> 只能使用默认初始化的方式来定义`execption` 、`bad_alloc` 、`bad_cast`对象。其他类型均使用string对象或者C风格字符串初始化对象。
>
> 对于没有设置初始值的异常类型，其成员函数`what()`返回的具体内容由编译器决定。



> [!WARNING]
>
> 该文章尚未完全编写完成，部分内容存在缺失。 
>
> -2026-09-07