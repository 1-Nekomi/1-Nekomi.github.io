---
title: C++中的类静态成员
description: 简述了C++中类的静态成员

date: 2026-09-16T18:07:48+08:00
lastmod: 2026-09-16T18:07:48+08:00
tags:
 - C++
 - 类
categories:
 - C++
math: false
mermaid: false
weight: 1002004004
---

# C++中类静态成员

​    在C语言中我们曾接触过关键字`static`，主要适用于修饰一个变量使其不会成为一个局部变量，可以简单理解为全局变量，但跟全局变量的作用域存在差异。这里就不再详细距离说明。

​    而在C++中，如果我们将某个成员用`static`修饰，则该成员则会成为一个 **不依赖于该类某个具体对象而存在的成员** 。什么意思呢，可以理解为即使我们不实例化一个对象，也可以使用该成员。例如：
~~~c++
#include<iostream>

using namespace std;

class Test{
public:
    static constexpr int a = 10; //类内初始化静态成员
    static int get_a();
};

int Test::get_a(){return a;} //不能用static重复修饰

int main(){
    cout<<Test::get_a()<<endl;
    cout<<Test::a;
    
    return 0;
}
~~~

运行结果如下：
~~~bash
10
10
~~~

可以看到即使没有实例化一个`Test`对象，也是可以直接通过指明作用域来使用静态成员的。

​    当需要给某个静态成员进行初始化时，最好在类外对其进行初始化。如果实在要在类内进行初始化，则只能使用`constexpr`修饰的字面值常量进行初始化，否则会报错。

> [!TIP]
>
> 静态成员也可以使用一个对象来进行访问，像访问正常的成员那样即可。
