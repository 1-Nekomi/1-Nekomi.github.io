---
title: C++中的类型显式转换
description: 简述了C++中强制类型转换的几种类型

date: 2026-09-04T16:49:41+08:00
lastmod: 2026-09-04T16:49:41+08:00
tags:
 - c++
 - 类型
categories:
 - c++
math: false
mermaid: false
weight: 1002001003
---

# C++中的类型显式转换

​    在C语言中我们可以通过强制类型转换让某些变量或者表达式的数据类型发生变化，其一般形式如下：
~~~
(type) expr
~~~

而在C++中既兼容C语言这种形式，也多了另一种强制类型转换形式：

~~~
cast_name<type>(expr)
~~~

其中`cast_name`为 **static_cast、dynamic_cast、const_cast、reinterpret_cast** 中的一种。

## static_cast

​    对于任何明确定义的类型转换，只要其不包含底层const，均可以使用`static_cast`来进行类型转换。例如：
~~~c++
double s = static_cast<double>(p) / i;
~~~

## dynamic_cast

​    该类型转换主要用于**处理多态类型**的运行时类型转换运算符，其使用限制如下：

- 基类中必须包含虚函数
- 仅用于指针或引用
- 必须存在继承关系

其包含两种用途：

1.  **向下转型** ：将基类指针/引用转为派生类指针/引用。
2.  **交叉转型** ：在多重继承中，将某个基类指针转换为另一个兄弟基类指针。

用法例如：
~~~c++
//转换为指针
Base* b = new Derived();
Derived* d = dynamic_cast<Derived*>(b);

//转换为引用
Derived& d = dynamic_cast<Derived&>(*b);
~~~

> [!TIP]
>
> 如果指针转换失败会返回`nullptr`，如果引用转换失败会抛出`std::bad_cast`异常。

## const_cast

​    改变运算对象的底层const,例如：
~~~c++
const char *p;
char *pc = const_cast<char*>(p);
~~~

去掉底层const之后，编译器就不会阻止对对象进行写操作了，但需要注意如果对象本身就是一个常量，对其写操作会导致未定义的行为。例如：
~~~c++
#include<iostream>
using namespace std;

int main(){
    const char* p = "Hello World";
    char *pc = const_cast<char*>(p);
    
    pc[0] = 'h';
    cout<< pc <<endl;
    
    return 0;
}
~~~

运行后会提示`Segmentation fault (core dumped)`，这就是典型的段错误（可自行检索了解），如果我们将程序修改为：
~~~c++
#include<iostream>
using namespace std;

int main(){
    char s[] = {"Hello World"};
    const char* p = s;
    char *pc = const_cast<char*>(p);
    
    pc[0] = 'h';
    cout<< pc <<endl;
    
    return 0;
}
~~~

此时运行结果就为：
~~~bash
hello World
~~~

## reinterpret_cast

​    该类型转换一般为运算对象的位模式提供较低层次上的重新解释，例如：
~~~c++
int *ip;
char *pc = reinterpret_cast<char*>(ip);
~~~

实际上`pc`指向的还是一个int对象，假设将其当作字符对象指针进行使用的话可能会出现一些问题。

---

在编程的过程中，其实并不推荐过多地使用类型显式转换，这会导致一定程度上的程序语义混乱，并会引发一些难以排查的问题。