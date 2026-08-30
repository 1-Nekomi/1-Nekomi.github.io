---
title: const限定符
description: 简述了C++中const限定符的用法和相关注意事项

date: 2026-08-30T14:07:40+08:00
lastmod: 2026-08-30T14:07:40+08:00
tags:
 - C++
 - 常量
categories:
 - C++
math: false
mermaid: false
weight: 1002001001
---

# const限定符

​    const限定符的作用在C语言中已经有涉及到，在C语言中的作用是 **修饰一个变量使其值不能被改变** ，而C++中其作用大致与C语言中的一样，但是存在一定的差异。

> [!TIP]
>
> const限定符在C语言中并不能代表常量，非常经典的例子就是使用const修饰变量作为数组长度：
> ~~~c
> #include<stdio.h>
> 
> int main(){
>     const int len = 10;
>     int num[len] = {1,2,3,4,5,6,7,8,9,10};
>     return 0;
> }
> ~~~
>
> 运行结果如下：
> ~~~bash
> cmain.c: In function ‘main’:
> cmain.c:5:5: error: variable-sized object may not be initialized
>     5 |     int num[len] = {1,2,3,4,5,6,7,8,9,10};
>       |     ^~~
> 
> ~~~
>
> 可以看到编译器提示了错误，提示“变量长度不能被初始化”，因此C语言中const修饰的数据类型并不是严格意义上的常量，而是 **限制只读的变量** 。
>
> 而在C++中，该问题并不会出现，可以同样使用上述程序进行编译，会发现编译器并没有提出任何报错，这说明在C++中const修饰的数据类型成为了严格意义上的常量。

## const的局限性

​    默认情况下， **const修饰的对象只在本文件内有效** 。举个例子，当我们在其中一个文件创建了一个const修饰的对象：

~~~c++
// file.cpp
const int Buffer_size = 1024;
~~~

此时存在另一个文件内想要使用这个对象，按理来说需要使用`extern`修饰：

~~~c++
// main.cpp
#include<iostream>
using namespace std;

extern const int Buffer_size;

int main(){
    cout<<Buffer_size<<endl;
    return 0;
}
~~~

我们此时运行程序会发现编译工具对我们报告了一个错误：
~~~bash
/usr/bin/ld: CMakeFiles/MyProject.dir/src/main.cpp.o: warning: relocation against `Buffer_size' in read-only section `.text'
/usr/bin/ld: CMakeFiles/MyProject.dir/src/main.cpp.o: in function `main':
main.cpp:(.text+0xa): undefined reference to `Buffer_size'
/usr/bin/ld: warning: creating DT_TEXTREL in a PIE
~~~

可以发现编译器没有在外部文件发现变量`Buffer_size`的定义，这是因为对于C++而言，const修饰的对象仅作用于文件内，当进行编译时，编译器会将const修饰的对象名用常量进行替换。

​    但凡事均有例外，假设有一个被const修饰的对象其初始值并不是一个常量表达式，且确实需要进行共享，那又该怎么做？其实只需要在用`extern`修饰即可，例如：
~~~c++
// file.cpp
#include<random>

int get_random_int(int min, int max) {
    static std::mt19937 gen(std::random_device{}());
    return std::uniform_int_distribution<int>{min, max}(gen);
}

//该常量可以被其他文件访问
extern const int Buffer_size = get_random_int(1,6);
~~~

上面主要是利用随机数引擎获取一个随机数，看不看得懂并不重要。此时我们再利用编译工具编译`main.cpp`和`file.cpp`后运行，就不会产生错误了，且程序也能够正常运行。

## 对const的引用

​    引用同样适用于const修饰的对象，但是对常量的引用不能被用作修改它所绑定的对象：
~~~c++
const int ci = 1024;
const int &r1 = ci; //正确：引用及其对应的对象都是常量
r1 = 42; //错误：r1是对常量的引用
int &r2 = ci; //错误：试图让一个非常量引用指向一个常量对象
~~~

> [!TIP]
>
> 对const的引用可以简述为 **常量引用**， 但注意引用本身不是对象，严格意义上这种简述是错误的。

​    我们之前提到过引用的类型必须与其所引用对象的类型一致，但是对于常量引用则存在例外：

- 在初始化常量引用时允许用 **任意表达式** 作为初始值
- 允许为一个常量引用绑定 **非常量对象、字面量、一般表达式**

例如：
~~~c++
int i = 1024;
const int &r1 = i; //允许将const int&绑定到一个普通int对象
const int &r2 = 1024; //常量引用
const int &r3 = r1 * 2; //常量引用
int &r4 = r1 * 2; //错误：r4是一个普通的非常量引用
~~~

为了理解为什么存在这种例外，可以通过一个简单的例子进行理解：
~~~c++
double dval = 3.14;
const int &r1 = dval;
~~~

进行编译会发现此时编译器没有进行报错，也没有进行警告。这是因为为了保证r1绑定一个整数，编译器实际上会定义一个 **临时量对象** 进行强制类型转换，并将r1绑定在这个临时量对象上，因此实际代码如下：
~~~c++
double dval = 3.14;
const int temp = dval;
const int &r1 = temp;
~~~

但假设引用并不是常量，那么则会发生报错，也就回到了我们原来说的“引用的类型必须与其所引用对象的类型一致”的情况。

​    既然存在常量引用可以绑定非const对象的情况，那么就可能存在非const对象被意外修改的情况，例如：
~~~c++
#include<iostream>
using namespace std;

int i = 42;
const int &r1 = i;

int main(){
    i = 1024;
    cout<<r1<<endl;
    return 0;
}
~~~

运行结果如下：
~~~bash
1024
~~~

因此将常量引用绑定到非常量对象上这种编程方法并不是很推荐，虽然C++并没有显式地将这种情况定义为非法，但可能会导致程序上的歧义和异常。

## const指针

​    const也可以用来修饰指针。主要有两种修饰方式：

1. 放在数据类型前，用于说明指针指向的是数据常量，例如：
   ~~~c++
   const int i = 2049;
   const int j = 1024;
   const int *p = &i;
   
   *p = 42; //错误，不能给*p赋值
   p = &j; //正确，可以更改指针p的值
   ~~~

2. 放在指针名前，用于说明指针是常量，例如：
   ~~~c++
   int i = 2047;
   int j = 512;
   int *const p = &i;
   
   *p = 1024; //正确，可以修改*p的值
   p = &j; //错误，不能更改p的值
   ~~~

> [!WARNING]
>
> 如果想要定义指针常量，那么`*`号一定要放在`const`修饰符前，否则如下例所示的情况就是错误的：
> ~~~c++
> int const *p = &i;
> ~~~
>
> 实际上这种形式等价于：
> ~~~c++
> const int *p = &i;
> ~~~
>
> 总结一下可以理解为`const` 在 `*` 左边修饰数据，在 `*` 右边修饰指针本身。
>
> 这关系到了 **顶层const** 和 **底层const** 的概念，用指针简单来说，前者表示指针 **本身是个常量** ，后者表示指针 **所指的对象是一个常量** 。而顶层const对任何数据类型都适用，底层const则与指针、引用这种复合类型的基本类型部分有关（引用没有必要用，因为引用值本身无法被修改）。

## constexpr和常量表达式

​    **常量表达式（const expreesion）** 是指值不会改变并且在编译过程中就能得到计算结果的表达式。例如：
~~~c++
const int num1 = 21; //常量表达式
const int num2 = num1+10; //常量表达式
int num3 = 111; //非常量表达式
const int num4 = get_num(); //非常量表达式
~~~

是否是常量表达式关键就在于 **等式左边是否被const修饰，且等式右边的值是否能在编译过程中就确定** 。

### constexpr变量

​    在一个较为复杂的系统中，想要分辨一个初始值是否是常量表达式是比较困难的，在C++11新标准中，允许将变量声明为 **constexpr** 类型以便 **由编译器来验证变量的值是否是一个常量表达式 **。声明为constexpr的变量一定是一个常量，且必须使用表达式初始化，例如：
~~~c++
constexpr int da = 1111;
constexpr int dat = da + 2;
constexpr int data = size(); //当size()函数为constexpr函数时才是正确的声明语句。
~~~

关于 **constexpr函数** 在后续会介绍到，这里先按下不表。

而想要把变量声明为constexpr变量，则需要保证变量的数据类型是 **字面值类型** ，也就是比较简单，值也显而易见的数据类型。例如算术类型、引用和指针就属于字面值类型，而类、IO库、string类型就不属于字面值类型，也无法被声明为constexpr变量。

> [!WARNING]
>
> 尽管指针和引用可以声明为constexpr变量，但初始值受到了严格限制，例如一个constexpr指针的初始值只能是 **nullptr、0、存储在某个固定地址的对象** 。

---

总体来说，const限定符在C++中的作用比C语言的要多不少，但实际上很多东西在工程开发中也比较难用到，可以仅作为了解。