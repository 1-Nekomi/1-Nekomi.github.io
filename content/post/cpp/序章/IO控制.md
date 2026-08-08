---
title: I/O控制
description: 主要介绍了cpp与c中的IO接口差别，以及cpp的接口定义和调用规则

date: 2024-03-02T15:32:00+08:00
lastmod: 2026-08-03T22:39:00+08:00
tags:
 - c++
 - IO
categories:
 - c++
weight: 1002000000
---

# I/O控制

​	C++的I/O接口与C略有区别，请自行回忆在C中实现I/O的函数原型以及使用方法。

## 操作符以及相应关键字

​	C++的I/O主要由三个关键字和两个操作符组合而成的：**cin、cout、<<、>>、endl**，下面依次介绍意义

|  名  |              意义              |
| :--: | :----------------------------: |
| cin  |      读取，对象默认为键盘      |
| cout |      输出，对象默认为屏幕      |
|  <<  |           插入操作符           |
|  >>  |           抽取操作符           |
| endl | 执行‘\n'（换行），但不等同于\n |

使用举例：

```c++
#include<iostream>
using namespace std;
int main(){
	int a;
	cin>>a;
	cout<<"a is "<<a<<endl;
	return 0;
}
```

​	注意：第二句的"using namespace std"是不可省略的，其中namespace表示**标识符的各种可见范围**，C++标准程序库中的所有标识符都被定义到了一个名为std的namespace中，如果不使用std，则cin和cout是无法使用的。

## I/O常见控制符

​	用控制符可以对I/O的格式进行控制，其位于头文件 iomanip 中，常见控制符如下所见：

|     控制符      |        描述         |
| :-------------: | :-----------------: |
|       dec       |     置基数为10      |
|       hex       |     置基数为16      |
|       oct       |      置基数为8      |
|   setfill(c)    |     填充字符为c     |
| setprecision(n) | 设显示小数精度为n位 |
|     setw(n)     |   设域宽为n个字符   |
|      fixed      |   固定的浮点显示    |
|   scientific    |      指数表示       |
|      left       |       左对齐        |
|      right      |       右对齐        |
|     skipws      |    忽略前导空白     |
|    uppercase    | 十六进制数大写输出  |
|    lowercase    | 十六进制数小写输出  |

下面举些简单例子来说明：

### 控制浮点数数值显示

​	主要用到的控制符有：**setprecision(n) , fixed , scientific**

```c++
#include<iostream>
#include<iomanip>
using namespace std;

int main(){
    float num = 22.0/7;
    cout<<num<<endl;//默认输出6位有效数字
    cout<<setprecision(4)<<num<<endl;//更改为输出4位有效数字
    cout<<fixed<<setprecision(6)<<num<<endl;//固定输出6位小数 
    cout<<scientific<<setprecision(5)<<num<<endl;//科学计数法
    cout<<setprecision(6);//恢复默认
    return 0;
}
```

setprecision控制符的使用比较灵活，一般用于**实型数的输出和读取**。实型数一般代指小数。

①在*普通表示*的输出中，其代表**有效位数**；

②在*确定表示*的输出中，其代表**小数位数**；

③在*指数形式*的输出中，其代表**小数位数**。



### 设置值的输出宽度

​	主要用到的控制符有：**setw(n)**，用于设置输出的宽度。

```c++
float num = 3.1415926;
cout<<setw(5)<<num<<endl
```

这样就限制了值的输出宽度为5位。如果输出的字符比限制宽度要少，则会在左边输出空格，例如：

```c++
int a = 10,b = 10;
cout<<setw(8)
    <<a
    <<b<<endl;
```

输出结果为：

```c++
------1010
    
```

（“-”表示空格，只作理解用。）我们会发现只有a输出是按照宽度为8进行输出的，b没有，如果想要b也按照这种格式进行输出，则需要在b前方也加入控制符：

```c++
int a = 10,b = 10;
cout<<setw(8)
    <<a<<setw(8)
    <<b<<endl;
```

输出结果为：

```c++
------10------10
    
```

### 输出八进制数和十六进制数

​	用到的控制符有：**hex、oct、dec**，其分别对应**十六进制数、八进制数、十进制数**的显示。

例如：

```c++
#include<iostream>
#include<iomanip>
using namespace std;

int main(){
    int a = 1314;
    cout<<dec<<a<<endl//十进制
        <<hex<<a<<endl//十六进制
        <<oct<<a<<endl;//八进制
    return 0;
}
```

### 设置填充字符

​	用到的控制符有：**setw(n)、setfill(c)**,setw可以用来确定输出宽度，setfill可以确定setw所规定的字符，简单来说就是**将setw默认的空格替换成其他字符**。

例如：

```c++
#include<iostream>
#include<iomanip>
using namespace std;

int main(){
	char s = 'H';
    char *p = &s;
    cout<<setfill('*')
        <<setw(1)<<*p<<endl
        <<setw(2)<<*p<<endl
        <<setw(3)<<*p<<endl;
    return 0;
}
```

运行结果为：

```c++
H
*H
**H
    
```

### 左右对齐输出

​	用到的控制符：**left、right、setw(n)**，可用于控制输出对齐。

例如：

```c++
#include<iostream>
#include<iomanip>
using namespace std;

int main(){
	int a = 1,b = 2,c = 3;
	cout<<left
		<<setw(5)
		<<a<<b<<c
		<<endl;
	cout<<right
		<<setw(5)
		<<a<<b<<c
		<<endl;	
    return 0;
}
```

输出结果为：

```c++
----123
1----23
    
```

### 强制显示小数点和符号

​	用到的操作符有：**showpoint、showpos**，showpoint可以用于强制显示非实型数的小数点，showpos用于显示正数符号（+）。

~~~c++
#include<iostream>
#include<iomanip>
using namespace std;

int main(){
	cout<<10.0/5<<endl;
	cout<<showpoint
		<<10.0/5<<endl;
	cout<<showpos
		<<10<<" "<<-20<<endl;
    return 0;
}
~~~

输出结果为：

```c++
2
2.00000
+10 -20  
    
```



实际上关于I/O这部分还有很多内容，后面会根据C中的printf和scanf来详细说明。