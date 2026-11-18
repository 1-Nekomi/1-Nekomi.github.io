---
title: C++——拷贝、赋值与销毁
description: 介绍了C++中拷贝、赋值、销毁三种操作的一些注意事项

date: 2026-11-18T14:32:53+08:00
lastmod: 2026-11-18T14:32:53+08:00
tags:
 - C++
 - 拷贝控制
categories:
 - C++
math: false
mermaid: false
weight: 1002009000
---

# 拷贝、赋值与销毁

对于一个类，这个类一般都会存在对象拷贝、移动、赋值和销毁的行为，而上述这些行为由 **拷贝构造函数（copy constructor）、拷贝赋值运算符（copy-assignment operator）、移动构造函数（move constructor）** 和 **析构函数（destructor）** 控制。

而拷贝和移动构造函数说明了 **用同类型的对象初始化本对象时会进行的操作** ；拷贝和移动赋值运算符说明了 **将一个对象赋予同类型的另一个对象时会进行的操作** ；析构函数定义了 **当此类型对象销毁时会做什么** 。

对于一些复杂的类，上述行为必须由人来手动定义，而不是使用编译器提供的默认行为，否则可能会导致一些灾难性的后果。

## 拷贝构造函数

若一个构造函数满足 **第一个参数是同类型对象引用，且任何额外参数都有默认值** ，则该函数为拷贝构造函数，例如：
~~~cpp
class Foo{
    Foo();			// 默认构造函数
    Foo(const Foo&);// 拷贝构造函数
}；
~~~

第一个参数最好使用`const`进行修饰，且必须使用引用类型，否则编译器不会将其视为拷贝构造函数。拷贝构造函数 **不能被`explicit`修饰** ，因为其在以下几种情况下会被隐式调用。

### 合成拷贝构造函数

如果我们没有主动定义拷贝构造函数，编译器会为我们生成一个默认拷贝构造函数。如果我们主动定义了拷贝构造函数，编译器会为我们合成一个拷贝构造函数。

对某些类而言，合成拷贝构造函数主要是为了 **阻止拷贝该类类型的对象** （例如防止将一个string对象错误拷贝到char*对象），其会将参数的成员逐个拷贝到正在创建的对象中。

每个成员的类型决定了它的拷贝方式：

- 若为类类型，则使用其拷贝构造函数进行拷贝
- 若为内置类型，则直接拷贝
- 若为数组类型，则会用合成的拷贝构造函数逐元素拷贝一个数组元素类型的成员；若数组元素是类类型，则会用元素的拷贝构造函数来进行拷贝

下面是一个简单的例子：
~~~cpp
#include<iostream>
#include<string>

class Foo{
public:
    Foo(std::string sd,uint32_t p,double f): s(sd),price(p),flo(f){}
    Foo(const Foo&);

    std::string s;
    uint32_t price;
    double flo;
};

Foo::Foo(const Foo& src):
    s(src.s),
    price(src.price),
    flo(src.flo){
    std::cout << "Copy" << std::endl;
}

int main(void){
    Foo f("Hello",1024,655.36);
    Foo copy = f;

    std::cout << copy.s << " " << copy.price << " " << copy.flo << std::endl;

    return 0;
}
~~~

运行结果如下所示：
~~~txt
Copy
Hello 1024 655.36
~~~

可以看到我们自己定义了`Foo`类的拷贝行为，且拷贝构造函数被隐式调用了。

### 拷贝初始化

可以由上面的例子的值，我们可以自己控制拷贝行为，以保证资源的高效利用，如果我们用`explicit`修饰拷贝构造函数，则会导致`=`拷贝初始化的行为未定义，从而造成程序歧义。

拷贝初始化除了会在用`=`定义变量的时候发生，也会在以下情况下发生：

- 将一个对象作为实参传递给一个非引用类型的形参
- 从一个返回类型为非引用类型的函数返回一个对象
- 用花括号列表初始化一个数组中的元素或一个聚合类中的成员
- 某些类类型分配对象时，例如初始化标准库容器或者调用`insert`或者`push`成员时，容器会对其元素进行拷贝初始化

但是假设我们用`explicit`修饰了拷贝构造函数，也不会导致其失效，只会导致部分拷贝行为失效，例如：
~~~cpp
vector<int> v1(10); 	//true
vector<int> v2(v1);		//false
vector<int> v2 = 10;	//false

void fun(vector<int>);	//fun函数
fun(10); 				//false
fun(vector<int>(10));	//true
~~~

因此如果想要使用`explicit`修饰的构造函数，就必须类似于上述最后一行代码那样显式构造对象。

## 拷贝赋值运算符

可以通过 **重载`=`运算符** 的方式来定义拷贝赋值运算符，如果类没有定义拷贝赋值运算符，编译器会为该类合成一个。如下所示：

~~~cpp
#include<iostream>
#include<string>

class Foo{
public:
    Foo(std::string sd,uint32_t p,double f): s(sd),price(p),flo(f){}
    Foo& operator=(const Foo&);

    std::string s;
    uint32_t price;
    double flo;
};

Foo& Foo::operator=(const Foo& src){
    this->s = src.s;
    this->price = src.price;
    this->flo = src.flo;

    return *this;
}

int main(void){
    Foo f("Hello",1024,655.36);
    Foo copy = f;

    std::cout << copy.s << " " << copy.price << " " << copy.flo << std::endl;

    return 0;
}
~~~

运行结果如下所示：
~~~txt
Hello 1024 655.36
~~~

关于运算符重载的内容，在后续我们会接触更深层次的内容，这里仅作一些简单的了解即可。

### 合成拷贝赋值运算符

和拷贝构造函数一样，如果我们没有为类定义一个拷贝赋值运算符，那么编译器会提供一个合成拷贝赋值运算符，对于某些类，其主要是用于 **禁止该类型对象的赋值** 。

拷贝赋值运算符会将右侧运算符的每个非static成员赋予左侧运算对象的对应成员，且会返回一个指向左侧运算对象的引用。

## 析构函数

析构函数主要负责 **释放对象使用的资源，并销毁对象的非static数据成员** ，其不存在返回值，也不接收任何参数：
~~~cpp
class Foo{
public:
    ~Foo(){ ... }
};
~~~

因此析构函数无法被重载，一个类中有且仅有一个析构函数。

析构函数一般是用于帮助我们完成一些资源的释放以及部分收尾工作， **它并不直接参与销毁对象的工作** ，其在以下情况会被隐式调用：

- 变量离开其作用域时被销毁
- 使用`delete`关键字销毁堆对象
- 当一个对象被销毁进而导致其成员被销毁
- 容器被销毁时，其元素被销毁
- 位于表达式中的临时对象被销毁时

### 合成析构函数

当一个类没有定义其自己的析构函数时，编译器会自动生成一个合成析构函数。对于某些类，其被用于 **阻止该类型的对象被销毁** 。

## 三/五法则

原则如下：

1. 如果一个类需要析构函数，则其一定也需要拷贝构造函数和拷贝赋值运算符
2. 如果一个类需要拷贝操作，则其一定也需要赋值操作，反之也亦然

要理解第一条原则，我们不妨来看这么一个例子：

~~~cpp
#include<iostream>
#include<string>

class Foo{
public:
    Foo(std::string sd): s(new std::string(sd)){}
    ~Foo(){ delete s; }

    std::string *s;
};

Foo fun(Foo f){
    Foo temp = f;
    return temp;
}

int main(void){
    Foo f = fun(Foo("Hello"));

    std::cout << *f.s << std::endl;

    return 0;
}
~~~

在上述程序中的`fun`函数返回时，其中的变量`temp`和`f`都会被销毁，但是编译器合成的拷贝构造函数一般是浅拷贝，也就是指针形式的拷贝，这两个变量实际上是指向的同一块内存，从而会导致释放了同一块内存，进而造成了错误。

这段程序自然是无法正常运行的，但如果我们新增一个拷贝构造函数，上述程序就能顺利运行：
~~~cpp
#include<iostream>
#include<string>

class Foo{
public:
    Foo(std::string sd): s(new std::string(sd)){}
    Foo(const Foo& src){ //new
        this->s = new std::string(*src.s);
    }
    ~Foo(){ delete s; }

    std::string *s;
};

Foo fun(Foo f){
    Foo temp = f;
    return temp;
}

int main(void){
    Foo f = fun(Foo("Hello"));

    std::cout << *f.s << std::endl;

    return 0;
}
~~~

要理解第二点，还是以上述的程序为例，这次我们改为这样：
~~~cpp
#include<iostream>
#include<string>

class Foo{
public:
    Foo(std::string sd): s(new std::string(sd)){}
    Foo(const Foo& src){ //new
        this->s = new std::string(*src.s);
    }
    ~Foo(){ delete s; }

    std::string *s;
};

Foo fun(Foo f){
    Foo temp = f;
    return temp;
}

int main(void){
    //new
    Foo a("Hello");
    Foo b("World");
    
    b = a;

    std::cout << *b.s << std::endl;

    return 0;
}
~~~

运行后，由于执行的是编译器的合成拷贝赋值运算符，因此原来b所指向的那一块内存不会被正常释放（值为`World`），从而导致了内存泄漏，而且由于b和a指向了同一块内存，还会因为多次释放同一块内存导致程序崩溃。因此我们还需要补充一个拷贝赋值运算符，完整且正确的类如下所示：
~~~cpp
class Foo{
public:
    Foo(std::string sd): s(new std::string(sd)){}

    Foo(const Foo& src){ //new
        this->s = new std::string(*src.s);
    }

    Foo& operator=(const Foo& rhs) { //new
        if (this != &rhs) {
            std::string* new_s = new std::string(*rhs.s);
            delete s;
            s = new_s;
        }
        return *this;
    }

    ~Foo(){ delete s; }

    std::string *s;
};
~~~

因此编写类的过程中注意上述的三五法则是非常重要的，可以避免很多因浅拷贝所引起的问题。

## default版本

为了提高程序的可读性以及更好地遵循三五法则，可以将拷贝构造函数、拷贝赋值运算符、析构函数的声明都写出来，在其后加上`=default`，向编译器说明使用合成版本的相关函数或运算符，例如：

~~~cpp
class Foo{
public:
    std::string *s;
    
    Foo(std::string sd): s(new std::string(sd)){}
    Foo(const Foo&) = default;
    Foo& operator=(const Foo&);
    ~Foo() = default;
};

Foo& Foo::operator=(const Foo&) = default;
~~~

这样也方便我们检查该类是否很好地遵循了三五法则。

> [!Tip]
>
> 如果在类内使用`default`标识，那么编译器会将该函数直接声明为内联函数，如果不希望使用内联函数，应该在类外使用`default`版本。

## delete版本

如果想要显式地阻止某些行为，那么可以将相关的函数使用`delete`标识，例如：
~~~cpp
class Foo{
public:
    int number;
    
    Foo(int n):number(n){}
    Foo(const Foo&) = delete; //阻止拷贝
    Foo& operator=(const Foo&) = delete; //阻止赋值
    ~Foo() = default; //使用合成的析构函数
};
~~~

这样同样可以提高类的可读性。

> [!WARNING]
>
> `delete`标识必须出现在函数第一次声明的地方，因此无法在类外对函数进行标识。

`delete`标识可以作用于任何函数之上，但其最主要的作用还是控制类的拷贝、赋值、销毁行为，毕竟阻止一个莫须有的函数行为并没有多大的意义。

同时，析构函数最好不要使用`delete`标识，虽然编译器并没有阻止这种行为，但删除析构函数会导致大部分销毁行为异常，例如：
~~~cpp
#include<iostream>

class Foo{
public:
    int number;
    
    Foo(int n):number(n){}
    ~Foo() = delete;
};

int main(void){
    Foo f(1024);
    Foo *t = new Foo(1024);
    delete t;  

    return 0;
}
~~~

其中上述语句`Foo f(1024);`和`delete t`均无法通过编译，给出的理由均是`类Foo的析构函数被删除`，这说明如果析构函数被删除，我们将无法定义该类的对象和临时对象，只能构建堆对象，但我们也无法释放堆对象，这会造成内存泄漏，所以析构函数最好不要使用`delete`标识。

> [!tip]
>
> 编译器也有可能会合成出一些被`delete`标识的函数，如果一个类满足以下任意条件，则编译器将这些合成的成员定义为删除的函数：
>
> - 类中某个成员的析构函数是删除的或者无法访问（private），该类的合成析构函数为删除的
> - 类的某个成员的拷贝构造函数或析构函数是删除的或者无法访问，该类的合成拷贝构造函数为删除的
> - 类的某个成员的拷贝赋值运算符是删除的或者无法访问，或者类有一个const/引用成员，该类的合成拷贝赋值运算符为删除的
> - 类的某个成员的析构函数是删除的或者无法访问，或者类有一个没有类内初始化器的引用成员，或者类有一个没有类内初始化器且其类型未显式定义默认构造函数的const成员，该类的默认构造函数为删除的
>
> 本质上这些规则是在说明 **如果一个类有数据成员不能默认构造、拷贝、赋值或销毁** ，则对应的成员函数会被定义为删除的。针对不同原则，其背后都有对应的理由，这里读者可以自行思考。

在C++11标准前，如果要达到与`delete`标识类似的效果，则可以使用private来控制成员函数的访问性，对外屏蔽掉接口，且不定义它们就可以了。

但是对于某些函数假设只声明不定义可能会导致一些问题，因此新标准后使用`delete`是更好的选择。

---

这部分内容不算难，但对于理解后续的内容是至关重要的，涉及到了我们如何通过拷贝、赋值和销毁这些行为来高效地利用资源并实现一些类似于引用计数这样的功能。
