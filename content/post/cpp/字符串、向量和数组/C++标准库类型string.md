---
title: C++标准库类型string
description: 介绍了C++中常用的字符串标准库之一string

date: 2026-09-02T15:27:42+08:00
lastmod: 2026-09-02T15:27:42+08:00
tags:
 - c++
 - 字符串
categories:
 - c++
math: false
mermaid: false
weight: 1002002000
---

# C++标准库类型string

​    标准库类型 **string** 表示可变长的字符序列，在使用这个标准库前，需要先`include`相关头文件并`using`标准库声明，如下所示：
~~~c++
#include<string>
using namespace std;

//或者
using std::string;
~~~

## 定义和初始化string对象

​    初始化string对象主要有以下几种方式：

|     定义初始化形式     |            含义             |
| :--------------------: | :-------------------------: |
|      `string s1;`      |          s1为空串           |
|    `string s2(s1);`    |        s2是s1的副本         |
| `string s3("Hello");`  |        s3 = "Hello"         |
| `string s3 = "Hello";` |        s3 = "Hello"         |
|  `string s4(n,'c');`   | s4 = n个'c'字符组成的字符串 |

> [!TIP]
>
> 假设我们使用`=`赋值运算符对string对象进行初始化，本质上是进行了一次 **拷贝初始化** ，将`=`右侧的初始值拷贝到左侧的对象中。如果不使用这种方法，则是进行的 **直接初始化** 。
>
> 如果一个变量有多个初始值，且要进行拷贝初始化，则需要显式地创建一个对象用于拷贝：
> ~~~C++
> string s1 = string(18,'S');
> ~~~
>
> 一般来说这种初始化方式并没有什么必要，可读性和简洁性都不如直接初始化，但其符合C语言中的编程习惯，因此具体编程习惯因人而异。

## string对象的操作

​    string对象的操作主要是用于解决C语言中处理字符串的不安全性以及复杂性，因此其操作如下：
|      操作       |                          含义                          |
| :-------------: | :----------------------------------------------------: |
|     `os<<s`     |               将s写到输出流os中，返回os                |
|     `is>>s`     |  将is中读取字符串并赋值s，字符串以空白为间隔，返回is   |
| `getline(is,s)` |              从is中读取一行赋值s，返回is               |
|   `s.empty()`   |              判断s是否为空，并返回布尔值               |
|   `s.size()`    |                    返回s中字符格式                     |
|     `s[n]`      |          返回s中第n个字符的引用，位置n从0计数          |
|     `s1+s2`     |                 返回s1和s2连接后的结果                 |
|     `s1=s2`     |              用s2中副本代替s1中原来的字符              |
|    `s1==s2`     | 检查s1和s2是否等价，若字符完全一样则相等，对大小写敏感 |
|    `s1!=s2`     |           检查s1和s2是否不等价，对大小写敏感           |
|   `<.<=,>,>=`   |      利用字符在字典中的顺序进行比较，对大小写敏感      |

 ### 读写string对象

   主要可以使用`cin`、`cout`、`getline()`来读写字符串，如下所示：
~~~c++
#include<iostream>
#include<string>
using namespace std;

int main(){
	string s;
    cin>>s;
    cout<<s<<endl;
    
    getline(cin,s);
    cout<<s<<endl;
    
    return 0;
}
~~~

运行结果如下：
~~~bash
$ Hello World
Hello
 World
~~~

从运行结果来看，从cin中读取的字符串会自动将空格视为终结符，这一点需要注意。

### 获取string对象的大小以及判空结果

​    在C语言中，对字符串判定是否为空以及获取字符串长度是很常见的操作，而在c++中string对象自带方法`empty()`、`size()`来实现上述目的。

~~~c++
#include<iostream>
#include<string>
using namespace std;

int main(){
    string s("You can do better.");
    string mp;
    
    cout<<mp.empty()<<endl;
    cout<<s.size()<<endl;
    
    return 0;
}
~~~

运行结果如下：
~~~bash
1
18
~~~

> [!TIP]
>
> 这里的数字1在C/C++中通常代表布尔值`True`。
>
> 对于`size()`方法，其返回的类型为`size_type`，其在string类中有相关声明。其为一个 **无符号类型** 的值且能足够放下任何string对象的大小。
>
> 因此在一条表达式中，如果已经使用了size()方法，最好不要使用int数据类型来与其进行比较或者拷贝，否则如下程序所示：
> ~~~c++
> #include<iostream>
> #include<string>
> using namespace std;
> 
> int main(){
>     string s("Hello World!");
>     int n = -1;
>     
>     cout<< (s.size()>n?1:0) <<endl;
>     
>     return 0;
> }
> ~~~
>
> 只要保证n为负数，上述运行结果始终为`0`(False)。原因是无符号数与有符号数进行比较时，会将有符号数转换为无符号数，这就导致了有可能会变成一个很大的数。
>
> 同理如果用int数据类型来拷贝size_type数据类型，则有可能会导致拷贝了一个负数。具体原理请见计算机组成原理，这里不对其进行介绍。

### 比较string对象

​     对于string对象的比较遵循以下规则：

- 如果两者长度不等，且有一方是另一方的前缀，那么较短字符串小于较长字符串。例如`Hello`小于`Hello World.`；
- 如果两者存在某些位置上的字符不等，不论长度是否相等，返回第一个不等字符对按照字典比较的大小。例如`Hello`小于`Hiya`，比较`e`和`i`的大小得出。

可以编写程序验证上述例子：
~~~c++
#include<iostream>
#include<string>
using namespace std;

int main(){
    string s1("Hello");
    string s2 = s1+" World";
    string s3("Hiya");
    
    cout << (s1<s2?true:false) <<endl;
    cout << (s1<s3?true:false) <<endl;
    
    return 0;
}
~~~

运行结果如下：

~~~bash
1
1
~~~

> [!TIP]
>
> 假设对应不等的字符对不是单纯的数字或者字母，又该怎么判断其大小？
>
> 这个时候就需要根据 **ASCII字符表** 上每个字符的真值进行比较了，相关表这里不给出，请自行检索。

### string对象的加法

​    在上述示例程序中有这么一行代码`string s2 = s1+" World"`，字符串的加法效果是 **将`+`运算符右侧的string对象附加在运算符左侧的string对象末尾** ，如果有多个运算符，则按照正常表达式中的运算符优先级进行运算。例如：
~~~c++
#include<iostream>
#include<string>
using namespace std;

int main(){
    string s = string("Hello") + "World" + " User!";
    cout<<s;
    
    return 0;
}
~~~

运行结果如下：
~~~bash
HelloWorld User!
~~~

> [!WARNING]
>
> 当把string对象和字符（串）字面量混在一条语句中使用时，必须要确保每个`+`运算符两侧的运算对象至少有一个是string对象，否则会报错，例如`string s = "Hello "+"World"`就是错误的。
>
> 这是由于C++需要兼容C语言导致的，如果查看字符串字面值的数据类型，会发现其数据类型为`const char[]`。

## 处理string对象中的字符

​    在`cctype`头文件中声明了一系列可以用来处理string对象中字符的函数，如下所示：
|     函数      |                             含义                             |
| :-----------: | :----------------------------------------------------------: |
| `isalnum(c)`  |                当字符为 **字母或数字** 时为真                |
| `isalpha(c)`  |                   当字符为 **字母** 时为真                   |
| `iscntrl(c)`  |                 当字符为 **控制字符** 时为真                 |
| `isdigit(c)`  |                   当字符为 **数字** 时为真                   |
| `isgraph(c)`  |                 当字符不是空格但可打印时为真                 |
| `islower(c)`  |                 当字符是 **小写字母** 时为真                 |
| `isprint(c)`  |      当字符是 **可打印字符** 时为真（参考ASCII字符表）       |
| `ispunct(c)`  |                 当字符是 **标点符号** 时为真                 |
| `isspace(c)`  | 当字符为 **空白** 时为真（空格、横向制表符、纵向制表符、回车符、换行符、进纸符中的一种） |
| `isupper(c)`  |                 当字符为 **大写字母** 时为真                 |
| `isxdigit(c)` |               当字符为 **十六进制数字** 时为真               |
| `tolower(c)`  |  当字符为 **大写字母** 时输出其对应的小写字母，否则输出原样  |
| `toupper(c)`  |  当字符为 **小写字母** 时输出其对应的小写字母，否则输出原样  |

---

​    string标准库是C++中的一大利器，在处理字符串相关的问题时十分方便快捷。基本算是C++常用标准库之一，因此这里不将其归类于《C++标准库》部分。
