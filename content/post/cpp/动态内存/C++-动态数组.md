---
title: C++-动态数组
description: 说明了在C++中如何通过手动管理或者智能指针管理动态数组，保证内存安全

date: 2026-10-31T15:23:20+08:00
lastmod: 2026-10-31T15:23:20+08:00
tags:
 - C++
 - 动态内存
 - 数组
categories:
 - C++
math: false
mermaid: false
weight: 1002008001
---

# 动态数组

在之前接触过的例子中，我们大多数都是使用的单个动态对象来进行演示，但有时候很难遇到只需要一个动态对象的情况，例如对象池这种需要大规模创建动态对象且具体对象数量难以确定的情况。虽然也可以直接使用一个for循环配合一个`new`语句来逐个创建，但这样创建开销和销毁开销都会比较大。

> [!Tip]
>
> 为了减少不必要的开销，其实更推荐使用标准容器而不是动态数组，如果不熟练的话动态数组极其容易导致内存泄露。

## 使用new和delete

`new`和`delete`同样可以一次性创建和销毁动态数组，例如：

~~~cpp
//分配一个长度为10的int数组
int *p = new int[10]；
    
//销毁动态数组
delete[] p;
~~~

当然也可以使用类型别名来简化创建的流程：
~~~cpp
//使用类型别名
using IntArr = int[10];
int *p = new IntArr;

delete[] p;
~~~

不难注意到，与单独一个对象相比，`delete`关键字后面需要跟上一个`[]`来说明本次销毁的是一个数组。

> [!TIP]
>
> 允许创建长度为0的动态数组，但不允许解引用，例如：
> ~~~cpp
> char arr[0]; //error
> char *cp = new char[0]; //合法，不允许解引用
> ~~~

初始化分为下面几种形式：

~~~cpp
int *p = new int[10];		//未初始化
int *p = new int[10]();		//初始化为0
int *p = new int[10]{1};	//第一个元素为1，其余为0
~~~

对于其他类型，不同类型的初始化方式均由自己的构造函数来决定。

## 使用智能指针

要管理动态数组的话，只能使用`unique_ptr`指针来管理，例如：
~~~cpp
std::unique_ptr<int[]> up(new int[10]);
~~~

当一个`unique_ptr`指向一个动态数组时，无法使用`.`和`->`成员运算符，但我们可以使用`[]`下标运算符来访问其中的元素，与常规的数组使用形式无异，这里不再赘述。

指向动态数组的`unique_ptr`除了常规操作以外还支持下表的操作：
|           操作           |                            含义                             |
| :----------------------: | :---------------------------------------------------------: |
|  `unique_ptr<int[]> u`   | 空`unique_ptr`，可以指向一个动态分配的数组，数组元素类型为T |
| `unique_ptr<int[]> u(p)` |    u指向指针p所指的动态分配的数组，p必须能够转换为类型T*    |
|          `u[i]`          |               访问u指向的数组中下标为i的元素                |

标准库中`shared_ptr`并不支持管理动态数组，但如果实在想要通过`shared_ptr`来管理动态数组的话，就必须自己支持删除器，例如：
~~~cpp
std::shared_ptr<int[]> p(new int[10] , [](int *p){delete[] p;})
~~~

## allocator类

对于`new`语句，内存分配和对象构造两个操作几乎是同时进行的，但是如果我们只想暂时拿一块内存，按需构造一定数量的对象，进而实现内存分配和对象构造分离。与此类推还有`delete`的内存返还和对象销毁。

`allocator`类支持进行上述操作，其定义在头文件`memory`中。`allocator`也是一个模板类，必须指明其可以分配的对象类型。其提供一个类型感知的内存分配方式，所分配的内存是未构造、原始的内存。

其支持的操作如下表所示：
|         操作          |                             含义                             |
| :-------------------: | :----------------------------------------------------------: |
|   `allocator<T> a`    |       一个名为a的`allocator`对象，可以为类型T分配内存        |
|    `a.allocate(n)`    | 分配长度为n个T类型对象的原始内存<br />返回一个T*类型指针，指向分配内存的起始地址 |
|  `a.deallocate(p,n)`  | 释放从T*类型指针p开始的长度为n个T类型对象的内存<br />p必须是由`allocate`返回的指针，n必须是p创建时所要求的大小<br />之后必须对每个在这块内存中创建的对象调用`destroy` |
| `a.construct(p,args)` | 用于在p指向的内存构造一个T类型对象<br />p必须是一个T*类型的指针<br />args传递给T类型的构造函数的参数 |
|    `a.destroy(p)`     |         对p指向的对象执行析构函数<br />p为T*类型指针         |

下面是一个简单使用`allocator`类的例子：
~~~cpp
#include<iostream>
#include<memory>
#include<string>

#define SIZE 10

int main(){
    std::allocator<std::string> a;
    auto const p = a.allocate(SIZE);

    auto q = p;
    a.construct(q++,"Hello");       //构造"Hello"
    a.construct(q++,5,'1');         //构造"11111"
    a.construct(q++);               //空string

    for(auto i = p;i!=q;i++)
        std::cout << *i << std::endl;

    while(q!=p) a.destroy(--q); //逐个释放构造的对象
    a.deallocate(p,SIZE); //释放内存

    return 0;
}
~~~

运行结果如下：
~~~txt
Hello
11111

~~~

需要注意的是在调用`deallocate`释放内存前，需要先使用`destroy`来销毁构造在这个内存上的对象，否则则有可能导致内存泄漏（具体原因可自查）。

### 拷贝和填充未初始化的内存

假设我们只是想把一些对象拷贝到这个内存中（类型匹配），那么标准库也提供了一批算法来在未初始化内存中创建对象，如下表所示：
|              操作              |                             含义                             |
| :----------------------------: | :----------------------------------------------------------: |
|  `uninitialized_copy(b,e,b2)`  | 从迭代器b和e指出的输入范围内拷贝元素到迭代器b2指定的未初始化内存中<br />b2指向的内存必须足够大，能够容纳下对应的元素拷贝 |
| `uninitialized_copy_n(b,n,b2)` |     从迭代器b指向的元素开始，拷贝n个元素到b2指向的内存中     |
|  `uninitialized_fill(b,e,t)`   |       在迭代器b和e指定的内存范围中创建值为t的对象拷贝        |
| `uninitialized_fill_n(b,n,t)`  | 从迭代器b指向的内存地址开始创建n个对象，每个对象的值均为t<br />b指向的内存必须足够大，能够容纳下对应的元素拷贝 |

上述操作均会返回一个指向最后一个构造对象后的位置的指针或者迭代器。

例如：

~~~cpp
#include<iostream>
#include<memory>
#include<string>
#include<vector>

#define SIZE 10

int main(){
    std::allocator<int> a;
    std::vector<int> s{1024,65536,1111};
    auto p = a.allocate(s.size()*2); //分配两倍大小的s内存空间

    auto q = std::uninitialized_copy(s.begin(),s.end(),p);

    auto r = std::uninitialized_fill_n(q,s.size(),1024); //将剩余元素初始化为1024

    for(auto i = p;i!=q;i++)
        std::cout << *i << " ";
    std::cout << std::endl;
    
    for(auto i = p;i!=r;i++)
        std::cout << *i << " ";
    std::cout << std::endl;

    return 0;
}
~~~

运行结果如下：
~~~txt
1024 65536 1111 
1024 65536 1111 1024 1024 1024 
~~~

---

关于动态数组的内容，实际上只需要重点掌握`allocator`类即可，其他的可以仅作一个简单的了解学习。