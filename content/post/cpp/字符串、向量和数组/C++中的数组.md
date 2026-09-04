---
title: C++中的数组
description: 简单说明了C++中数组相比C语言数组的区别

date: 2026-09-04T15:25:25+08:00
lastmod: 2026-09-04T15:25:25+08:00
tags:
 - C++
 - 数组
 - 指针
categories:
 - C++
math: false
mermaid: false
weight: 1002002003
---

# C++中的数组

​    在C++中的数组和C语言数组在操作上存在一些细微区别，为避免后续编程过程中的歧义，这里对其进行说明。

## 标准库函数begin()和end()

​    在C语言中假设我们想要得到尾指针，需要知道数组的长度，否则可能会使指针悬空进而导致一些意想不到的问题。

​    而C++中提供了标准库函数`begin()`和`end()`来获取一个数组的头指针和尾指针的下一个位置。例如：
~~~c++
#include<iostream>
using namespace std;

int main(){
    int nums[] = {1,2,-1,2,3,-4,5};
    //找到所有负数元素并输出值
    
    for(int* p = begin(nums);p != end(nums) && p < end(nums);p++)
        if(*p < 0)
        	cout<< *p << endl;
    
    return 0;
}
~~~

运行结果如下：
~~~bash
-1
-4
~~~

在上述代码片段中我们并没有显式地使用数组长度这一参数，这让数组操作更加安全。

## 指针运算

​    在C语言中我们接触了一部分指针的运算操作，而在C++中指针支持类似于迭代器的运算，例如计算两个指针的距离：

~~~C++
#include<iostream>
using namespace std;

int main(){
    int nums[] = {1,2,3,4,5};
    auto n = end(nums) - begin(nums);
    
    cout<< n <<endl;
    
    return 0;
}
~~~

运行结果如下：
~~~bash
5
~~~

刚好是数组`nums`的长度。而在C语言中这种操作是也是可行的，但安全性并没有那么高，在C语言中上述程序片段等价于：
~~~C
#include<stdio.h>

int main(){
    int nums[] = {1,2,3,4,5};
    int *bp = &nums[0],*ep = &nums[5];
    int p = (int)(ep-bp);

    printf("%d",p);

    return 0;
}
~~~

运行结果同上。

> [!TIP]
>
> 在C++中两个指针运算的结果类型是`ptrdiff_t`，类似于`size_t`类型，其定义在头文件`cstddef`的机器相关的类型中，该类型是一个 **带符号** 的数据类型。

---

 C++中与C语言数组操作的区别主要就体现在安全性这一方面，可能还存在其他方面的异常，如果影响比较大，后续会在该文章中继续补充。