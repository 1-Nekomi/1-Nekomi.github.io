---
title: C++动态内存管理
description: 简述了C++中如何手动管理内存或者通过智能指针来管理内存

date: 2026-10-29T13:51:01+08:00
lastmod: 2026-10-29T13:51:01+08:00
tags:
 - C++
 - 动态内存
categories:
 - C++
math: false
mermaid: false
weight: 1002008000
---

# C++动态内存管理

​    有时候我们希望能够手动控制一个对象的生存周期，就可以使用`new`和`delete`来帮助我们手动控制一个对象的生存周期，例如：
~~~cpp
#include<iostream>

struct Pos{
    std::uint32_t x;
    std::uint32_t y;
    Pos(std::uint32_t X,std::uint32_t Y):x(X),y(Y){std::cout << "Create a Pos: " << x << " " << y << std::endl;}
    ~Pos(){std::cout << "Destroy a Pos: " << x << " " << y<< std::endl;}
};

int main(){
    Pos* p = new Pos(10,2);//new关键字会返回对应对象的指针
    //doing something
    delete p;

    return 0;
}
~~~

运行结果如下：
~~~bash
Create a Pos: 10 2
Destroy a Pos: 10 2
~~~

但上述手动管理内存的操作，有一个非常明显的弊端，那就是一旦`new`了一个对象，就必须在合适的地方对其进行`delete`，否则就会造成 **内存泄漏** ，这是一个比较严重的问题，更多细节读者可自行了解。与之相对的，假设提前`delete`了一个对象，后续对其进行解引用时，会解引用一个空指针，这也是一个比较严重的问题。

上面可供我们动态使用的内存，叫做动态内存，也称为堆内存。为了更安全地使用堆内存，标准库提供了两种智能指针来帮助我们更好地管理堆对象，如下表所示：
|     指针     |                 说明                 |
| :----------: | :----------------------------------: |
| `shared_ptr` | 允许多个指针指向同一个对象的智能指针 |
| `unique_ptr` |           独占所指向的对象           |

> [!Tip]
>
> 标准库还定义了一个名为`weak_ptr`的伴随类，其是一种弱引用，指向`shared_ptr`所指向的对象

智能指针都声明在头文件`memory`中。

## 手动管理

虽然有智能指针帮助管理堆内存，但这也不代表我们不需要了解如何进行手动管理，在某些需要极端性能优化的情况，具备能够手动管理本就不多的动态内存的能力十分重要。

上述简单说明了如何使用`new`和`delete`关键字来手动管理堆内存，这里不再赘述如何使用，而是关注一下平时使用是会遇到的一些问题。

### auto类型

假设我们提供了括号包围的初始化器，那么就可以直接使用auto来推断我们需要分配的对象类型，例如：
~~~cpp
#include<iostream>
#include<string>

int main(){
    std::string s("Hello");
    auto *p = new auto{s};
    auto *p1 = new auto{"World"};

    std::cout << *p << " " << *p1 << std::endl;

    return 0;
}
~~~

运行结果如下：
~~~bash
Hello World
~~~

但是并不建议大规模采用这种写法，因为程序中的对象类型数量一旦多起来，经常性地使用auto推断会让代码可读性明显下降。

### const对象

在构造一个动态const对象时，必须显式初始化，例如：
~~~cpp
#include<iostream>
#include<string>

int main(){
    const std::string *p = new const std::string("Hello World");

    std::cout << *p << std::endl;

    return 0;
}
~~~

运行结果如下：
~~~bash
Hello World
~~~

### 分配失败

在C语言中，如果使用`malloc`函数分配失败，会返回一个空指针。在C++中也可以返回空指针，但默认会抛出`std::bad_alloc`异常，例如：
~~~cpp
int *p1 = new int; //假设分配失败，抛出std::bad_alloc异常
int *p2 = new (nothrow) int; // 假设分配失败，会返回空指针
~~~

第二种形式被称为 **定位new** ，其允许我们向new传递额外的参数，而上述的`nothrow`就是标准库定义的一个对象，告知new在分配失败时不必抛出异常。

## 智能指针操作

智能指针能够帮我们自动管理对象的生命周期，智能指针也是一种模板类型，其声明形式如下所示：
~~~cpp
ptr_type<type> p_name;
~~~

其中`ptr_type`为智能指针类型，`type`为这个指针所指向的数据类型，`p_name`为智能指针的变量名。

下面的操作，两种智能指针均支持：

|                    操作                    |                     含义                      |
| :----------------------------------------: | :-------------------------------------------: |
| `shared_ptr<T> sp`<br />`unique_ptr<T> up` |       空智能指针，可以指向类型为T的对象       |
|                    `p`                     | 将p作为一个条件，若其指向一个对象，则返回true |
|                    `*p`                    |               解引用p获得其对象               |
|                  `p->mem`                  |         获取mem成员，等价于`(*p).mem`         |
|                 `p.get()`                  |                获取p保存的指针                |
|        `swap(p,q)`<br />`p.swap(q)`        |                 交换指针p和q                  |

## shared_ptr

该智能指针所支持的操作如下表所示：

|          操作           |                             含义                             |
| :---------------------: | :----------------------------------------------------------: |
| `make_shared<T> (args)` | 返回一个`shared_ptr`，指向一个动态分配类型为T的对象，使用args初始化此对象 |
|  `shared_ptr<T> p(q)`   | p是`shared_ptr q`的拷贝<br />此操作会递增q中的计数器<br />q中的指针必须能够转换为`T*` |
|         `p = q`         | p和q都是`shared_ptr`，所保存的指针必须能够互相转换<br />此操作会递减p的引用计数，递增q的引用计数 |
|      `p.unique()`       |       若`p.use_count == 1`，则返回true，否则返回false        |
|     `p.use_count()`     | 返回与p共享对象的智能指针数量<br />执行速度可能较慢，主要用于调试 |

### make_shared函数

这种方法是最安全的分配和使用方法，其使用方法也很简单，如下所示：
~~~cpp
#include<iostream>
#include<string>
#include<memory>

int main(){
    std::shared_ptr<std::string> p = std::make_shared<std::string> ("Hello,World!");
    
    std::cout << *p << std::endl;

    return 0;
}
~~~

运行结果如下：
~~~cpp
Hello,World!
~~~

### 引用计数

每个`shared_ptr`指针都附带一个属性： **引用计数** ，这个计数表示这个指针所指向的对象还有多少个其他的`shared_ptr`指针指向。因此拷贝操作一定会产生一次计数递增，例如下面的程序片段：

~~~cpp
std::shared_ptr<int> p1 = std::make_shared<int>(50);
std::shared_ptr<int> p2 = p1;
~~~

上述操作会导致p1指针的引用计数递增。假设p2原先指向的另外一个对象，那么其数量会发生什么变化？我们可以试试：

~~~cpp
#include<iostream>
#include<memory>

int main(){
    std::shared_ptr<int> p1 = std::make_shared<int>(100);
    std::shared_ptr<int> p2 = std::make_shared<int>(1024);

    auto p3 = p2;
    auto p4 = p2;

    std::cout << p1.use_count() << " " << p2.use_count() << std::endl;

    p2 = p1;

    std::cout << p1.use_count() << " " << p2.use_count() << std::endl;

    return 0;
}
~~~

运行结果如下：
~~~cpp
1 3
2 2
~~~

很明显，p2的引用计数递减了，p1的引用计数递增了。要理解的话也相当好理解，把上述程序抽象成两个池子，池子A住着三只青蛙，池子B住了一只青蛙，后面池子A有一只青蛙跳到了池子B，自然池子A的数量就少了一只青蛙，池子B多了一只青蛙。

当一个`shared_ptr`指针的引用计数归0后，会自动销毁指向的动态对象，这样一来就不需要自己再去手动释放对象了，也就避免了内存泄漏的问题。

### 与new配合使用

`shared_ptr`指针在于`new`配合使用时必须使用直接初始化形式，不能使用拷贝形式的初始化，例如：

~~~cpp
//错误的定义形式
std::shared_ptr<int> p = new int(50);
//正确的定义形式
std::shared_ptr<int> p(new int(50));
~~~

在使用函数返回`shared_ptr`指针也需要额外注意这一点，例如：
~~~cpp
//错误的形式
std::shared_ptr<int> getmem(int num){
    return new int(num);
}

//正确的形式
std::shared_ptr<int> getmem(int num){
    return std::shared_ptr<int>(new int(num));
}
~~~

### 定义和更改`shared_ptr`的其他办法

智能指针默认使用`delete`来释放动态对象，而`delete`默认会调用对象的析构函数，假设我们不想让智能指针通过`delete`来释放对象，那么就需要我们自行提供对应的方法来代替`delete`。因此更改的操作如下表所示：

|          方法           |                             含义                             |
| :---------------------: | :----------------------------------------------------------: |
|  `shared_ptr<T> p(q)`   | p管理内置普通指针q所指向的对象<br />q必须指向`new`分配的内存，且能够转换为T*类型 |
|  `shared_ptr<T> p(u)`   |         p从`unique_ptr u`接管对象的所有权，并将u置空         |
| `shared_ptr<T> p(q,d)`  | p接管内置普通指针q所指向对象的所有权<br />q必须指向`new`分配的内存，且能够转换为T*类型<br />p将可调用对象d代替`delete` |
| `shared_ptr<T> p(p2,d)` | p2和p均为`shared_ptr`，p是p2的拷贝<br />p将可调用对象d代替`delete` |
|       `p.reset()`       |        若p指向唯一对象，则会释放指向的对象，并将p置空        |
|      `p.reset(q)`       |                若p指向唯一对象，则会令p指向q                 |
|     `p.reset(q,d)`      |  若p指向唯一对象，则会令p指向q，并将可调用对象d代替`delete`  |

> [!WARNING]
>
> 最好不要将普通指针和智能指针进行混用，极有可能会导致一些难以预料的问题，例如：
> ~~~cpp
> #include<iostream>
> #include<memory>
> 
> int getnum(std::shared_ptr<int> p){
>     return *p;
> } 
> 
> int main(){
>     int *p(new int(1024));
>     //getnum(x); //错误，普通指针无法转换为智能指针类型
>     std::cout << getnum(std::shared_ptr<int>(p)) << std::endl;
> 
>     //无法预料的运行结果
>     std::cout << *p << std::endl;
> 
>     return 0;
> }
> ~~~
>
> 上述的运行结果是不确定的，读者可自行尝试。具体原因就是因为智能指针和普通指针混用引起的问题。
>
> 由于函数`getnum`接收的是一个`shared_ptr`指针的拷贝，在执行函数的过程中，智能指针的引用计数一直为1，而执行完函数后，智能指针因为超出作用域被销毁，因此引用计数变为0，自动销毁了内存中的对象，但此时普通指针p还指向了那一块内存，若此时对其解引用，就会导致解引用了一个野指针，导致运行结果无法预测。
>
> 与上述问题类似的还有下面这个程序：
> ~~~cpp
> #include<iostream>
> #include<memory>
> 
> int process(std::shared_ptr<int> p){
>     return *p;
> }
> 
> int main(){
>     std::shared_ptr<int> p(new int(1024));
>     int *q = p.get();
>     
>     std::cout << process(std::shared_ptr<int>(q)) << std::endl;
> 
>     std::cout << *p << std::endl;
> 
>     return 0;
> }
> ~~~
>
> 运行这段程序，除了运行结果不可预测以外，还出现了另外一个错误：
>
> ~~~txt
> free(): double free detected in tcache 2
> Aborted (core dumped)
> ~~~
>
> 根据第一个例子，请读者自行分析这段程序，这里不再赘述。

## 智能指针和异常

在异常发生时，一般来说函数内的代码都无法全部执行完成，这就导致了需要手动释放的资源可能没有被正确释放，如下面的代码所示：
~~~cpp
#include<iostream>
#include<memory>

int main(){
    int *p(new int(1024));

    try{
        int *q = p;
        throw std::runtime_error("Error!");
        delete q;
    }catch(std::runtime_error err){
        std::cout << err.what() << std::endl;
    }

    std::cout << *p << std::endl;

    return 0;
}
~~~

运行结果如下：
~~~cpp
Error!
1024
~~~

对于智能指针就不存在这种情况，这里就不再举例说明。

对于一些没有析构函数的类而言，假设我们需要释放其所使用的资源，必定需要使用另一种函数来帮助我们释放资源，例如：
~~~cpp
#include<iostream>
#include<memory>

struct Pos{
    int x = 0;
    int y = 0;
    Pos(int x,int y):x(x),y(y){std::cout << "Pos(" << x << "," << y << ")" << std::endl;}
    bool deletePos(){
        std::cout << "Delete the Pos(" << x << "," << y << ")" << std::endl;
        return true;
    }
};

int main(){
    try{
        std::shared_ptr<Pos> q(new Pos(1024,1111));
        throw std::runtime_error("Error!");
        q->deletePos();
    }catch(std::runtime_error err){
        std::cout << err.what() << std::endl;
    }

    return 0;
}
~~~

运行结果如下：
~~~txt
Pos(1024,1111)
Error!
~~~

## unique_ptr

于`shared_ptr`不同的是，`unique_ptr`是独占其指向的对象，并且也没有类似于`make_shared`这样的标准库函数，因此定义一个`unique_ptr`指针的时候需要绑定到一个`new`返回的指针上，不支持普通的拷贝和赋值操作。如下所示：
~~~cpp
unique_ptr<int> p(new int(1024));
~~~

`unique_ptr`类能够进行的操作如下表所示：

|          操作          |                             含义                             |
| :--------------------: | :----------------------------------------------------------: |
|   `unique_ptr<T> u`    |                空`unique_ptr`，可以指向类型T                 |
|  `unique_ptr<T,D> u`   | 空`unique_ptr`，可以指向类型T<br />会用可调用对象D来代替`delete` |
| `unique_ptr<T,D> u(d)` | 空`unique_ptr`，可以指向类型T<br />用类型为D的可调用对象d来代替`delete` |
|     `u = nullptr`      |                    释放u指向的对象，置空u                    |
|     `u.release()`      |             放弃u对指针的控制权，返回指针，置空u             |
|      `u.reset()`       |                       释放u指向的对象                        |
|      `u.reset(q)`      |             释放u指向的对象<br />令u指向q的对象              |
|   `u.reset(nullptr)`   |                  释放u指向的对象<br />置空u                  |

> [!TIP]
>
> `unique_ptr`不能拷贝和赋值存在一个例外，假设一个`unique_ptr`即将被销毁，那么就可以对其进行拷贝和赋值，例如：
>
> ~~~cpp
> #include<iostream>
> #include<memory>
> 
> std::unique_ptr<int> clone(int num){
>     return std::unique_ptr<int> (new int(num));
> }
> 
> std::unique_ptr<float> clone(float num){
>     std::unique_ptr<float> ret(new float(num));
>     return ret;
> }
> 
> int main(){
>     std::unique_ptr<int> p1 = clone(1024);
>     std::unique_ptr<float> p2 = clone((float)65.536);
> 
>     std::cout << *p1 << " " << *p2 << std::endl;
> 
>     return 0;
> }
> ~~~
>
> 运行结果如下：
> ~~~txt
> 1024 65.536
> ~~~
>
> 可以看到上述程序是可以运行的，这是因为当编译器发现返回的对象即将被销毁时，会执行一种特殊的拷贝，在后续我们会接触到这种拷贝。

## weak_ptr

`weak_ptr`是一种不控制所指向对象生命周期的智能指针，它仅仅只是指向一个`shared_ptr`管理的对象（不会改变`shared_ptr`的引用计数），实现弱共享。一旦`shared_ptr`引用计数归0，不论这个对象是否有`weak_ptr`指向，都会销毁对象，因此使用时需要注意这一点，避免解引用野指针。

其支持的操作如下表所示：

|        操作         |                             含义                             |
| :-----------------: | :----------------------------------------------------------: |
|   `weak_ptr<T> w`   |             空`weak_ptr`，可以指向类型为T的对象              |
| `weak_ptr<T> w(sp)` | 与`shared_ptr sp`指向相同对象的`weak_ptr`，T必须能转换为sp指向的类型 |
|       `w = p`       | w与p共享对象<br />p可以是`shared_ptr`和`weak_ptr`的其中一个  |
|     `w.reset()`     |                            置空w                             |
|   `w.use_count()`   |                与w共享对象的`shared_ptr`数量                 |
|    `w.expired()`    |        若`w.use_count() == 0`返回true，否则返回false         |
|     `w.lock()`      | 如果`w.expired == true`，返回空`shared_ptr`，否则返回一个指向w的对象的`shared_ptr` |

创建`weak_ptr`时，如果要初始化，必须使用`shared_ptr`类型进行初始化，否则会产生错误，例如：
~~~cpp
 //false
std::weak_ptr<int> w(new int(1024));

//true
auto p = std::make_shared<int>(1024);
std::weak_ptr<int> w(p);
~~~

### 访问对象

不推荐直接通过`weak_ptr`访问对象，因此这有可能会解引用一个野指针，最安全的访问方式应该是通过`w.lock()`方式来访问一个对象，例如：
~~~cpp
if(std::shared_ptr<int> p = w.lock()){
    //p和w共享对象
}
//p被销毁
~~~

---

上面介绍了C++中所有动态内存管理的手段，实际上`shared_ptr`已经足以应对绝大部分情况，至于其他的智能指针，只需要在某些特殊情况（例如需要严格保证内存安全）下知道怎么使用即可。

