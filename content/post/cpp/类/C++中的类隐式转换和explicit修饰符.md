---
title: C++中的类隐式转换和explicit修饰符
description: 介绍了C++中有关类隐式转换和如何通过explict抑制这种转换

date: 2026-09-16T17:37:46+08:00
lastmod: 2026-09-16T17:37:46+08:00
tags:
 - C++
 - 类
 - 数据类型
categories:
 - C++
math: false
mermaid: false
weight: 1002004003
---

# C++中的类隐式转换和explicit修饰符

​    对于普通的数据类型我们知道有时候会存在一些隐式的数据类型转换，对于类有时候也会有隐式转换，例如下面这段代码：
~~~C++
#include <iostream>

class MyInt {
public:
    MyInt(int v) : value(v) {}   // 非 explicit
    int value;
};

void printMyInt(MyInt m) {
    std::cout << m.value << std::endl;
}

int main() {
    MyInt a = 10;        // OK：隐式转换 int -> MyInt
    printMyInt(20);      // OK：隐式转换 int -> MyInt
    return 0;
}
~~~

在上述的代码中，常量`10`按理来说应该是一个int数据类型，但是编译这段代码会发现实际上并没有产生报错，这是由于 **编译器将这个int数据类型隐式转换为了MyInt类对象** ，具体的做法就是生成一个临时的MyInt对象并传递构造函数字面量`10`参数进行初始化，再拷贝回`a`对象。

​    有时候为了避免隐式转换带来的麻烦，可以使用`explicit`修饰符来禁用构造函数的隐式转换，具体做法只需要在构造函数前加上`explicit`修饰符即可，如下所示：
~~~c++
class MyInt {
public:
    explicit MyInt(int v) : value(v) {}   // 禁止隐式转换
    int value;
};

void printMyInt(MyInt m) {
    std::cout << m.value << std::endl;
}

int main() {
    // MyInt a = 10;       // 错误：不能隐式转换
    MyInt a(10);           // OK：直接初始化
    MyInt b{10};           // OK：列表初始化

    // printMyInt(20);     // 错误：不能隐式转换
    printMyInt(MyInt(20)); // OK：显式构造临时对象
    printMyInt(static_cast<MyInt>(20)); // OK：显式转换

    return 0;
}
~~~

隐式转换被禁用后，只能通过直接初始化或者列表初始化来初始化对象，不能通过拷贝的形式来对对象进行初始化。

对于 **单参数构造函数** 最好使用`explicit`修饰符来禁用隐式类型转换，避免代码变得不自然或者出现歧义。

在后面接触到转换函数时，同样可以使用`explicit`修饰符来禁用其中的隐式转换。