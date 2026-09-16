---
title: C++中的友元进阶
description: 详细介绍了C++中有关友元的进阶操作和相关原理

date: 2026-09-16T15:42:58+08:00
lastmod: 2026-09-16T15:42:58+08:00
tags:
 - C++
 - 友元
 - 类
categories:
 - C++
math: false
mermaid: false
weight: 1002004002
---

# C++中的友元进阶

​    我们知道如果一个函数或者类想要访问另一个类中的非公有成员，则需要将该函数或者类声明为友元，但是之前只是简单介绍了有这么一个情况，且只举出了函数友元的例子，并没有举类友元的例子，因此这里做一个补充的同时也详细说明友元的其他细节上的操作。

## 类友元

​    对于类友元，分为两种情况：

- 声明类为友元
- 声明类的某一部分成员函数为友元

### 声明类为友元

对于这种情况就简单很多了，只需要像声明函数友元那样声明类友元即可，被声明为友元的类中的所有成员函数均可以访问对应类的非公有成员，例如：
~~~C++
#include<iostream>

using namespace std;

class Get;

class Test{
    int a = 10,b = 100;
    friend Get;

public:
    Test() = default;
};

class Get{
public:
    Get() = default;
    int get_a(Test& t){return t.a;}
    int get_b(Test& t){return t.b;}
};

int main(){
    Test t{};
    Get g{};

    cout<<g.get_a(t)<<endl<<g.get_b(t);
    
    return 0;
}
~~~

运行结果为：
~~~bash
10
100
~~~

> [!tip]
>
> 在上述代码中，存在这么一个语句`class Get;`，如果有C语言的经验，就会明白这里是在进行 **前向/前置声明** ，避免在`Test`类中将`Get`声明为友元时产生未定义行为。

可以看到`Get`类中的所有成员函数都可以访问`Test`类中的非公有成员。

### 声明成员函数友元

假设需要做出限制，只声明某些类中的某些成员函数作为友元，那么就需要在声明友元的时候附上类作用域，一般形式如下：
~~~c++
friend type class_name::function_name( ... );
~~~

下面是一个简单的代码示例：
~~~c++
#include<iostream>

using namespace std;

class Test;

class Get{
public:
    Get() = default;
    int get_a(Test& t);
};

class Test{
    int a = 10,b = 100;
    friend int Get::get_a(Test& t);

public:
    Test() = default;
};

int Get::get_a(Test& t){return t.a;}

int main(){
    Test t{};
    Get g{};

    cout<<g.get_a(t);
    
    return 0;
}
~~~

运行结果为`10`。

> [!WARNING]
>
> 需要注意的是，对于被声明为友元的函数或者类，其定义必须放在友元声明类的后面，否则会被判定为非法行为，例如假设对于上面的代码我们将`get_a()`函数的定义放在`Get`类内，则会产生以下报错：
> ~~~bash
> main.cpp: In member function ‘int Get::get_a(Test&)’:
> main.cpp:10:31: error: invalid use of incomplete type ‘class Test’
>    10 |     int get_a(Test& t){return t.a;}
>       |                               ^
> main.cpp:5:7: note: forward declaration of ‘class Test’
>     5 | class Test;
>       |       ^~~~
> 
> ~~~
>
> 可以看到由于`Test`类此时只是个前置声明，其成员并不清楚有哪些，而`Get`类就擅自直接使用了某个可能不存在的成员变量，于是就产生了错误。同理，如果我们互换`Get`类和`Test`类的位置，对`Get`进行前置声明也是同样的道理，会因为不知道`Get`类中的具体成员而产生报错。
>
> 因此如果要声明一个成员函数友元，最标准的做法应该是：
>
> 1. 首先将需要被声明成员函数友元的类A放在前面，并前置声明需要内置友元声明语句的类B，但此时不能定义类A的成员函数
> 2. 声明类B的成员和友元，同时也可以定义成员
> 3. 定义类A的成员函数
>
> 这里推荐最好将所有类都进行前置声明，这样就可以忽略类的顺序，但是依然要保证 **友元声明语句在友元成员函数定义语句块的前面** 。