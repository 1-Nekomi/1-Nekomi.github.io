---
title: lambda表达式
description: 简述了C++中的lambda表达式相关概念和用法

date: 2026-10-07T15:02:14+08:00
lastmod: 2026-10-07T15:02:14+08:00
tags:
 - C++
 - lambda
categories:
 - C++
math: false
mermaid: false
weight: 1002007000
---

# lambda表达式

​    lambda表达式是C++中一种可调用对象，我们目前除了lambda表达式以外，接触过的可调用对象只有函数和函数指针。

​    在正式开始介绍lambda表达式前，需要先了解 **谓词（predicate）** 这个概念。谓词是一个可以调用的表达式，在C语言中我们接触过一个函数`qsort`，其原型如下：
~~~C
void qsort(void *base, size_t nitems, size_t size, int (*compar)(const void *, const void *));
~~~

其中第三个参数在C++中就被描述为一个谓词，其本质是一个可调用的函数指针。需要注意的是在使用该函数时，只需要传递函数指针即可，不要调用函数。下面是一个简单的示例：
~~~c
#include <stdio.h>
#include <stdlib.h>

// 定义一个包含五个整数的数组
int values[] = { 88, 56, 100, 2, 25 };

// 比较函数，用于比较两个整数
int cmpfunc (const void * a, const void * b)
{
   return ( *(int*)a - *(int*)b );
}

int main()
{
   int n;

   // 输出排序之前的数组内容
   printf("排序之前的列表：\n");
   for( n = 0 ; n < 5; n++ ) {
      printf("%d ", values[n]);
   }

   // 使用 qsort 函数对数组进行排序，不要在第三个参数处调用函数
   qsort(values, 5, sizeof(int), cmpfunc);

   // 输出排序之后的数组内容
   printf("\n排序之后的列表：\n");
   for( n = 0 ; n < 5; n++ ) {
      printf("%d ", values[n]);
   }
  
   return 0;
}
~~~

谓词分为 **一元谓词（unary predicate）** 和 **二元谓词（binary predicate）** ，区分是几元谓词只需要判断其接受几个参数即可。例如上面的`qsort`函数中的参数就是一个二元谓词。

​    由于谓词的限制，传递给算法的谓词必须严格接受一个或者两个参数，但对于更多数量的参数，函数指针谓词就无能为力了，例如对于`find_if`函数，该函数可以查找第一个满足条件的元素，接受三个参数：两个迭代器，用于表示元素范围；一个一元谓词用于描述条件。例如：
~~~c++
#include<iostream>
#include<vector>
#include<algorithm>

using namespace std;

//找到第一个大于10的元素
bool simple(int a){
    return a > 10;
}

int main(){
    vector<int> ls{1,3,11,4,5,22};
    auto it = find_if(ls.begin(),ls.end(),simple);

    cout<< *it;
    return 0;
}
~~~

运行结果是`11`，但是假设面对一个string数组，我们想要找到满足一定长度的string对象，可以看到至少要传递一个string对象和一个长度计数值，而`find_if`只能使用一元谓词，因此如果编译下面的程序会报错：
~~~C++
#include<iostream>
#include<vector>
#include<string>
#include<algorithm>

using namespace std;

//找到第一个符合长度len的字符串s
bool simple(string s,int len){
    return s.size() == len;
}

int main(){
    vector<string> ls{"Hello","World"};
    auto it = find_if(ls.begin(),ls.end(),simple);

    cout<< *it;
    return 0;
}
~~~

这是由于我们无法传递长度计数值len所导致的，面对这种情况使用函数指针谓词就无能为力了，只能使用lambda表达式。下面就正式开始介绍lambda表达式是如何解决这个问题的。

## 概述

​    lambda表达式可以理解成一个没有标识符的内联函数，因此一个lambda表达式具有返回类型、一个参数列表、一个函数体，其形式如下：
~~~C++
[capture list] (parameter list) -> return type {function body}
~~~

其中`capture list`是一个lambda所在函数中定义的局部变量的列表（一般为空），`parameter list`、`return type`、`function body`分别表示参数列表、返回类型、函数体。其中参数列表和返回类型是可以忽略的，但必须永远包含捕获列表和函数体，例如：
~~~c++
auto test = []{return 1024;}
~~~

## 向lambda捕获和传递参数

​    lambda要使用参数，可以通过捕获自己所在函数中定义的局部变量作为参数，或者传递参数列表。其中传递参数列表和正常的函数无异，例如：

~~~c++
[](const string &s1,const string &s2){
    return s1.size() > s2.size();
}
~~~

而对于捕获函数局部变量，lambda只能捕获那些在函数体内明确指明的局部变量，例如对于上述我们所提及的`find_if`处理string对象数组所涉及的问题，我们可以通过lambda表达式来解决：

~~~c++
#include<iostream>
#include<vector>
#include<string>
#include<algorithm>

using namespace std;

int main(){
    vector<string> ls{"Hello","World"};
    int len = 5;
    auto it = find_if(ls.begin(),ls.end(),
                [len](const string s){return s.size() == len;});

    cout<< *it;
    return 0;
}
~~~

> [!WARNING]
>
> lambda只能捕获函数体内的局部变量，且该局部变量的声明必须在lambda表达式前。下面两段程序均无法通过编译：
> ~~~c++
> #include<iostream>
> #include<vector>
> #include<string>
> #include<algorithm>
> 
> using namespace std;
> 
> int main(){
>     vector<string> ls{"Hello","World"};
>     
>     auto it = find_if(ls.begin(),ls.end(),
>                 [len](const string s){return s.size() == len;}); //无法捕获声明位于lambda表达式之后的局部变量
>     int len = 5; // error
>     cout<< *it;
>     return 0;
> }
> ~~~
>
> ~~~C++
> #include<iostream>
> #include<vector>
> #include<string>
> #include<algorithm>
> 
> using namespace std;
> 
> int len = 5; // error
> 
> int main(){
>     vector<string> ls{"Hello","World"};
>     
>     auto it = find_if(ls.begin(),ls.end(),
>                 [len](const string s){return s.size() == len;}); //无法捕获全局变量
> 
>     cout<< *it;
>     return 0;
> }
> ~~~
>
> 对于全局变量，lambda表达式中是可以直接访问的，因此不需要对其进行捕获。

---

基本的lambda表达式的基本用法就如上所示，可以看出lambda表达式要用起来的话还是非常简单的，为了更好地理解lambda表达式，下面会介绍lambda的相关原理和一些进阶用法。

## lambda捕获和返回

​    当我们定义了一个lambda表达式时，编译器会生成一个 **与lambda对应的新的未命名的类类型** ，这意味着假设我们对一个变量使用lambda表达式初始化的话，也会定义一个从lambda生成的类型的对象。

这也说明了我们使用lambda初始化一个变量，该变量本质上会被初始化成一个对应的函数指针，例如：
~~~C++
#include<iostream>

using namespace std;

int main(){
    int (*t)() = []()->int {return 1024;};

    cout << t() << endl;

    return 0;
}
~~~

但是假设lambda表达式存在捕获值，则无法隐式转换成一个函数指针，此时只能使用`auto`类型：
~~~c++
#include<iostream>

using namespace std;

int main(){
    int val = 1024;

    auto t = [val]()->int {return val;};

    cout << t() << endl;

    return 0;
}
~~~

### 隐式捕获

​    而捕获值除了值捕获和引用捕获以外，还存在一个隐式捕获。对于值捕获和引用捕获，基本用法和注意事项和函数中传递参数基本无异，参考学习即可，这里不再赘述。

​    对于隐式捕获，假设我们不想显式列出lambda函数体中所用到的局部变量，则可以让编译器自行推断我们所用到的变量，只需要在`capture list`中只写一个`&`或者`=`，其中`&`告诉编译器采用引用捕获方式，`=`告诉编译器采用值捕获方式。例如：
~~~c++
auto it = find_if(ls.begin(),ls.end(),
                [=](const string s){return s.size() == len;}); //值捕获方式
~~~

当然，也可以和原来的方式组合使用，来分配不同局部变量的捕获方式：
~~~c++
[ < = | & >, names... ] (...)  -> type {function body}
~~~

只要给定`=`或者`&`，就给该lambda表达式分配了默认的捕获方式，例如：
~~~c++
for_each(words.begin(),words.end(),
        [=,c](const string& s){os << s << c;});
// c为值捕获，os为隐式捕获
~~~

需要额外注意的是， **后续显式给出的局部变量捕获方式不能与给定的默认捕获方式相同** 。

### 可变lambda

​    对于一个值捕获方式的lambda表达式，一般不会修改被捕获变量的值，假设我们需要修改一个通过值捕获方式获得的变量值，则需要加上`mutable`关键字（回忆一下，这个关键字我们在哪个地方也用到过？），其形式如下：
~~~c++
[capture list] (parameter list) mutable -> type {function body}
~~~

下面是一个简单的示例程序：
~~~c++
#include<iostream>

using namespace std;

int main(){
    int val = 1024;

    auto t = [val]() mutable ->int  {return ++val;};

    cout << t() << endl;
    cout << val << endl;

    return 0;
}
~~~

运行结果如下：
~~~bash
1025
1024
~~~

假设我们去掉`mutable`关键字修饰，则会产生报错，可以自行尝试。

假设我们是通过引用捕获方式捕获的局部变量，则情况会有些不同，例如：
~~~C++
#include<iostream>

using namespace std;

int main(){
    int val = 1024;

    auto t = [&val]() mutable ->int  {return ++val;};

    val = 0;
    cout << t() << endl;
    cout << val << endl;

    return 0;
}
~~~

运行结果为：
~~~bash
1
1
~~~

此时就算我们去掉`mutable`关键字修饰，也不会产生报错。

综上可以看出`mutable`关键字就是针对的值捕获方式下要修改变量的情况。

### 指定返回类型

在上述的例子中我们很少显式指明lambda表达式的返回类型，一般都是交给编译器自行推断，但是在某些情况下，编译器的推断会出现错误，例如：
~~~c++
auto factorial = [](int n) -> int {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
};
~~~

对于上述情况，由于编译器无法推断递归的返回类型，此时就必须指明返回类型，假设不指明则编译器会默认这个lambda表达式返回void。类似的还有下面这个例子：
~~~c++
auto f = [](bool flag) {
    if (flag)
        return 1;      // int
    else
        return 2.5;    // double
};
~~~

可以自行修改使这个lambda表达式正确。

---

到此为止，lambda表达式大部分用法都介绍完了，lambda的最主要用法就是用来拓展泛型算法中谓词的参数量，假设没有捕获局部变量，使用函数指针会更好，如果捕获了局部变量，除了lambda表达式，也可以使用参数绑定的方式来替代lambda，这种情况一般用于函数体非常复杂的情况，用lambda表达式会导致泛型算法函数的调用语句十分臃肿。后续会介绍这种方法。