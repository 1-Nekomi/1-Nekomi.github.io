---
title: C++中的成员函数进阶
description: 介绍了C++中的关于类成员函数的一些进阶操作

date: 2026-09-16T14:25:00+08:00
lastmod: 2026-09-16T14:25:00+08:00
tags:
 - C++
 - 类
 - 成员
categories:
 - C++
math: false
mermaid: false
weight: 1002004001
---

# C++中的成员函数进阶

​    对于C++中的类，我们目前已经知晓了一些最基本的写法，涉及到其他比较进阶的操作，就需要另外进行说明，对于类中的成员函数，可以对其声明内联`inline`、对其进行重载，除此之外还有一些细节上的操作需要详细说明。

> [!TIP]
>
> 对于定义在类内部的成员函数是 **自动inline** 的，当然也可以在类内部显式声明内联函数，同样地也可以在类的外部修饰函数声明。
>
> 最好的办法是在类的外部修饰函数声明，可以增强代码的可读性。

## 可变数据成员

​    有时候如果需要修改类中的某个数据成员，但通过前面的学习不难注意到：const成员函数是无法修改类中的数据成员的，那么如果实在需要进行修改又该怎么做？

​    可以在声明数据成员的时候用`mutable`修饰，被`mutable`修饰的数据成员可以被一个const成员函数修改，例如：
~~~c++
#include<iostream>

using namespace std;

class Test{
public:
    mutable int a;
    Test() = default;
    void change_a(const int a) const{this->a = a;} 
};

int main(){
    const Test t{};
    t.change_a(10);
    cout<< t.a <<endl;
    
    return 0;
}
~~~

运行结果如下：
~~~bash
10
~~~

假设我们将`mutable`修饰符删除，就会产生报错：
~~~bash
main.cpp: In member function ‘void Test::change_a(int) const’:
main.cpp:9:46: error: assignment of member ‘Test::a’ in read-only object
    9 |     void change_a(const int a) const{this->a = a;}
      |                                      ~~~~~~~~^~~

~~~

## 返回*this的成员函数

​    在成员函数中如果通过this指针返回调用方法的对象本身，那么就可以再进行一次方法调用，例如：
~~~c++
#include<iostream>

using namespace std;

class Test{
public:
    int a;
    Test() = default;
    Test &getTest(){return *this;}
    void change_a(const int a) {this->a = a;} 
};

int main(){
    Test t{};
    t.getTest().change_a(188);
    cout<<t.a<<endl;
    
    return 0;
}
~~~

其中上述的语句`t.getTest().change_a(100);`等价于：
~~~C++
Test &temp = t.getTest();
temp.change_a(188);
~~~

两者运行结果均为：
~~~bash
188
~~~

> [!WARNING]
>
> 需要注意的是，如果等价语句写成：
> ~~~c++
> Test temp = t.getTest();
> temp.change_a(188);
> ~~~
>
> 则运行结果则为`0`，这是由于临时对象使用了一个对象类型而不是引用类型，从而进行了拷贝操作，后续的更改并没用作用在对象`t`身上。

那么这里就有一个问题了，对于常量对象调用的常量成员函数，其this指针返回的类型是常量还是变量？为了验证这个问题，我们不妨写一段代码进行验证：

~~~c++
#include<iostream>

using namespace std;

class Test{
public:
    int a;
    Test() = default;
    auto &getTest(){return *this;}
    const Test& tryTest() const {cout<< "const Test"<<endl; return *this;}
    Test& tryTest() {cout<< "Test" <<endl; return *this;} 
};

int main(){
    const Test t{};
    t.tryTest();
    
    return 0;
}
~~~

运行结果为：
~~~bash
const Test
~~~

可以看到返回的是常量类型。在上述代码中用到了成员函数的重载，其规则和普通的函数重载并无二异，因此按照函数的重载进行编码就很难出错。

