---
title: C++类概述
description: 简单说明了C++中的类相关概念，配合了一些简单的例子进行说明

date: 2026-09-14T18:29:26+08:00
lastmod: 2026-09-16T17:27:19+08:00
tags:
 - C++
 - 类
 - 概念
categories:
 - C++
math: false
mermaid: false
weight: 1002004000
---

# C++类概述

​    C++是一门典型的OOP语言，因为也具有类机制，因为通过学习python的类有了一些基础，因此这里只简单介绍一下C++中类相关的概念，下面是一个简单的类声明形式：
~~~c++
class Test{
public:
    int a,b;
    int add();
    bool set_ab(int& a,int& b);
};
~~~

上述是一个简单的类声明，下面简单介绍一些C++中有关于类的概念。

## this指针和const成员函数

​    当利用对象调用其中的方法时，我们可以使用this指针来指代这个调用方法的对象本身，从而使用其中的一些成员变量。

> [!TIP]
>
> this指针在使用的过程中并不需要显式地指出，除非形参名和成员变量名相同，例如：
> ~~~C++
> #include<iostream>
> #include<cassert>
> 
> using namespace std;
> 
> class Test{
> public:
>     int a,b;
>     Test(int a,int b) {this->a = a; this->b = b;}
>     Test& add(Test& rs);
> };
> 
> Test& Test::add(Test& rs){
>     a += rs.a;
>     b += rs.b;
>     return *this;
> }
> 
> int main(){
>     Test rs1(10,2);
>     Test rs2(5,6);
>     rs2.add(rs1);
> 
>     cout<< rs2.a << endl << rs2.b;
> 
>     return 0;
> }
> ~~~
>
> 运行结果如下：
> ~~~bash
> 15
> 8
> ~~~
>
> 可以看到在类`Test`中，构造函数中的形参列表由于与两个成员变量同名，为了区分它们，就需要使用this指针，但是对于成员函数`add`，由于不存在这种情况，因此就可以隐藏this指针隐式使用成员变量，对成员函数也是同理。

​    而一般来说，this指针一般都是指向的非常量的对象，那么这里有个问题：对于一个常量版本的对象，当对象调用方法时，使用this指针能让其调用普通的成员函数吗？

​    答案是不能，因为非常量指针不能指向一个常量对象，这是显而易见的。

​    为了解决这个问题，可以在函数声明体后加上`const`修饰符，一般形式如下：
~~~C++
type function_name( ... ) const { ... }
~~~

而这种成员函数被称为 **常量成员函数** ，被这种形式声明定义的函数，this指针是指向一个常量版本的对象的，不能更改对象其中的成员。除此之外，常量成员函数还可以进行下面操作：

- 调用**静态成员函数**；
- 读取 public 数据成员；
- 修改 `mutable` 数据成员。（后续介绍）

> [!TIP]
>
> 上述问题中this指针不能调用普通成员函数除了上面提到的原因以外，还有另外一个原因，那就是 **常量对象，以及常量对象的引用或指针都只能调用常量成员函数** 。

## 构造函数

​    构造函数相当于告诉编译器该类的初始化是如何进行的，等于定义了一个初始化方法，当定义对象时会自动调用构造函数，构造函数的声明形式一般如下：
~~~c++
class_name( ... ) { ... }
~~~

需要以类名进行命名才算构造函数。如果我们不显式地定义构造函数，编译器会为我们自动生成一个默认的构造函数执行默认初始化，当然也可以显式地指出我们需要编译器来为我们生成一个默认构造函数，形式如下：
~~~c++
class_name( ... ) = default;
~~~

### 构造函数初始值列表

​    对于下面的构造函数：

~~~c++
Test(const int& a,const int& b):a(a),b(b) { }
~~~

其等价于上面介绍隐式this指针代码中的`Test(int a,int b) {this->a = a; this->b = b;}`,利用这种形式可以省略构造函数主体中给成员变量赋值的语句，让构造函数主体中用来干其他事情。

对于上面新出现的部分，我们称其为 **构造函数初始化列表** ，其一般形式如下：
~~~c++
class_name( ... ) : mem_var(expr),... { ... }
~~~

### 委托构造函数

​    构造函数也是允许重载的，当重载了构造函数后，就可以委托其他构造函数来帮助初始化，不需要再重新编写一套初始化代码，例如：
~~~c++
class Test{
public:
    int a,b,c;
    Test(const int a,const int b,const int c):a(a),b(b),c(c) {}
    Test(const int a,const int b):Test(a,b,0) {}
    Test(const int a):Test(a,0) {}
    Test():Test(0) {}
    
};
~~~

其中只有第一个构造函数Test是自己进行初始化，剩下三个重载的构造函数都是委托了第一个Test构造函数来帮助自己进行初始化。同样的，委托构造函数也可以委托“委托构造函数”来帮助自己进行初始化，不一定要委托具有自行初始化能力的构造函数，例如上述第三个Test构造函数就委托了第二个Test构造函数来帮助自己进行初始化。

当委托构造函数将初始化工作交给对应的构造函数后，会先执行对应构造函数的初始化条件以及函数体代码，然后再将执行层层下递，例如：
~~~c++
#include<iostream>

using namespace std;

class Test{
public:
    int a,b,c;
    Test(const int a,const int b,const int c):a(a),b(b),c(c) {cout<<"one"<<endl;}
    Test(const int a,const int b):Test(a,b,0) {cout<<"two"<<endl;}
    Test(const int a):Test(a,0) {cout<<"three"<<endl;}
    Test():Test(0) {cout<<"four"<<endl;}
    
};

int main(){
    Test t{};

    cout<<t.a<<endl<<t.b<<endl<<t.c<<endl;
    
    return 0;
}
~~~

运行结果为：
~~~bash
one
two
three
four
0
0
0

~~~

可以看到整体的执行流程应该是:

~~~
Test(a,b,c) -> Test(a,b) -> Test(a) -> Test()
~~~

根据上述的运行结果可以尝试自行推理程序整体的运行顺序。

## 拷贝、赋值、析构

​    对于类的对象，除了初始化，还需要 **拷贝、赋值、析构** 三种常见的操作，下面依次介绍。

### 拷贝和赋值

​    假设我们不重载运算符，那么编译器会自动生成一个用于拷贝的默认行为，以下面的程序片段为例：
~~~c++
#include<iostream>
#include<cassert>

using namespace std;

class Test{
public:
    int a,b;
    Test(int a,int b):a(a),b(b) {}
    Test& add(Test& rs);
};

Test& Test::add(Test& rs){
    a += rs.a;
    b += rs.b;
    return *this;
}

int main(){
    Test rs1(10,2);
    Test rs2 = rs1;
    rs2.add(rs1);

    cout<< rs2.a << endl << rs2.b;

    return 0;
}
~~~

运行结果如下：
~~~bash
20
4
~~~

在上面的程序中有这么一条语句`Test rs2 = rs1;`，其等价于下面的语句集合：

~~~c++
rs2.a = rs1.a;
rs2.b = rs1.b;
~~~

这就是编译器为我们自动生成的默认拷贝行为，可以看出编译器生成的默认拷贝行为只是简单地将对象中的成员变量进行了拷贝操作。

在后续我们学习了运算符重载后，就可以自定义拷贝行为。

### 析构

​     对于一个类，如果使用了`new`实例化了一个对象，那么就需要使用`delete`关键字释放对象所占用的内存，否则会造成内存泄露。

​    当我们使用了`delete`关键字释放对象时，会自动调用类中的 **析构函数** ，而析构函数的声明形式如下：
~~~c++
~class_name( ... ) { ... }
~~~

以下面的程序为例：
~~~c++
#include<iostream>
#include<cassert>

using namespace std;

class Test{
public:
    int a,b;
    Test(int a,int b):a(a),b(b) {}
    ~Test(){cout<<"Delete a Test object.";}
};

int main(){
    Test* rs1 = new Test(20,1);
    delete rs1;

    return 0;
}
~~~

运行结果如下：
~~~bash
Delete a Test object.
~~~

## 访问控制与封装

​    在C++中有三种访问控制： **public、private、protected** ，下表详细说明了各个访问控制的作用：

| 访问位置            | `public` | `protected` | `private` |
| :------------------ | :------- | :---------- | :-------- |
| 本类成员函数/友元   | 可访问   | 可访问      | 可访问    |
| 派生类成员函数/友元 | 可访问   | 可访问      | 不可访问  |
| 类外部普通代码      | 可访问   | 不可访问    | 不可访问  |

在后面我们会逐渐接触上述的访问控制符号。

> [!TIP]
>
> 在C++中可以同时使用`class`和`struct`关键字声明定义类，其区别仅仅只是使用class声明的类成员默认是`private`的，而使用struct声明的类成员默认是`public`的。

### 友元

​    对于某些函数或者类，如果实在需要访问特定类对象中被限制的成员，一个方法是在被访问类中 **新增用于专门访问限制成员的方法** ，另一个方式就是在被访问类中 **针对该类或函数声明一个友元** 。

以下面的程序片段为例：
~~~c++
#include<iostream>
#include<cassert>

using namespace std;

class Test{
    int a,b;
    friend void get_ab(const Test& t);
public:
    Test(int a,int b):a(a),b(b) {}
    ~Test(){cout<<"Delete a Test object.";}
};

void get_ab(const Test& t){
    cout<< t.a << endl << t.b << endl;
}

int main(){
    Test* rs1 = new Test(20,1);
    get_ab(*rs1);
    delete rs1;

    return 0;
}
~~~

运行结果如下：
~~~bash
20
1
Delete a Test object.
~~~

可以看到函数`get_ab()`能够直接访问Test对象`rs1`中的成员，假设我们在main函数中新增一条语句`cout << rs1->a;`，就会产生报错：
~~~bash
main.cpp: In function ‘int main()’:
main.cpp:21:18: error: ‘int Test::a’ is private within this context
   21 |     cout << rs1->a;
      |                  ^
main.cpp:7:9: note: declared private here
    7 |     int a,b;
      |         ^

~~~

可以看到对于非友元函数或类，直接访问成员会导致程序崩溃。

---

上面就是C++中最基本的概念，了解了上面的概念后就可以着手写一些较为简单的类，但是涉及到例如继承多态、运算符重载、类类型等则需要更进一步地学习。