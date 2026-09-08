---
title: C++中的函数返回
description: 介绍了C++中函数返回与C语言之间的区别

date: 2026-09-08T22:49:55+08:00
lastmod: 2026-09-08T22:49:55+08:00
tags:
 - C++
 - 函数
categories:
 - C++
math: false
mermaid: false
weight: 1002003001
---

# C++中的函数返回

​    该文主要介绍在函数返回上与C语言的一些细微差别，至于其他概念和用法在C语言中有过接触，这里就不再赘述。
## 引用返回左值

   在之前的博客中，我们大致了解了什么叫做 **左值** ，如果想不起来了请看这个博客：

{{<postLinkCard path="/post/cpp/基础类型/处理类型" cover="auto" >}}

如果让函数返回一个引用，则该引用是一个左值，可以直接位于表达式等号的左侧，例如：
~~~c++
#include<iostream>
#include<string>
using namespace std;

char &get_val(string &str,string::size_type id){
    return str[id];
}

int main(int argc,char** argv){
    string s("Hello World");
    get_val(s,0) = 'h';
    cout<< s <<endl;

    return 0;
}
~~~

运行结果如下：
~~~bash
hello World

~~~

虽然C语言中也可以将函数返回值作为左值使用，例如：
~~~C
#include <stdio.h>
#include<string.h>
#include<malloc.h>

int *get_p(const size_t si){
    int *p = (int*)malloc(sizeof(int)*si);
    memset(p,0,si);
    return p;
}

int main(){
    printf("%c",(get_p(10)[0] = 'h'));

    return 0;
}
~~~

运行结果为`h`。

但很明显，这样做的后果只会是内存泄漏。在C语言中函数调用表达式的结果（即返回值整体）本身始终是右值（rvalue），无论其类型是指针还是非指针。假设类型存在底层类型，例如结构体、指针、联合体等，则可以整体作为左值使用，但返回的右值会在表达式结束后消亡，因此不具有实际运用价值。

## 列表初始化返回值

​    从C++11开始，函数可以返回花括号包围的值列表，若列表为空，则执行默认初始化，否则返回的值由函数的返回类型决定。例如：
~~~C++
#include<iostream>
#include<string>
#include<vector>
using namespace std;

vector<string> get_info(const bool chs){
    if(chs)
        return {"Yes","Hello!"};
    return {"No","World!"};
}

int main(int argc,char** argv){
    vector<string> info = get_info(true);
    cout<< info[0] << info[1];

    return 0;
}
~~~

运行结果如下：
~~~bash
YesHello!
~~~

## 尾置返回类型

​    在之前的C语言博客中，我们介绍了函数如何返回数组指针，这在C++中同样适用，博客如下：
{{<postLinkCard path="/post/C/指针/5.多重指针和指针函数、指针数组" cover="auto" >}}

但在C++11新标准后中有更简单的表达形式，例如下面是两种等价的函数：
~~~C++
//C
int (*func(int i))[10];

//C++
auto func(int i) -> int(*)[10];
~~~

> [!TIP]
>
> 在C语言中如果要返回数组指针也不一定要使用上述第一种方法，也可以使用`typedef`声明转换类型后再返回，例如：
> ~~~c
> typdef int Arr[10];
> 
> Arr* func(int i);
> ~~~

上述程序段都声明了一个返回含有10个整数的数组的指针。

> [!WARNING]
>
> 对于尾置返回类型，函数前面的`auto`类型不可替换（`decltype(auto)`除外），否则会因为冲突问题产生报错。
>
> 这里的`auto`类型并不起到推理的作用，其在这起到了 **占位符** 的作用。

---

总体来说，C++中的函数返回值相比C语言丰富了一点，但总体和C语言中的并无太大差异，更多的是优化C语言中本来就过于冗杂的声明形式。