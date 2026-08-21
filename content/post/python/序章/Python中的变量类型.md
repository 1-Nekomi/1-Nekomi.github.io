---
title: Python中的变量类型
description: 介绍了python中常见的几种变量类型：变量、数、字符串等

date: 2026-08-18T15:46:04+08:00
lastmod: 2026-08-18T15:46:04+08:00
tags:
 - python
 - 变量
categories:
 - python
math: false
mermaid: false
weight: 1003000000
---

# Python中的变量类型

​    在python中的每一个 **变量（variable）** 都指向一个 **值（value）**，例如对于下面的程序片段：
~~~python
message = “Hello World.”
print(message)
~~~

`message`变量就指向了一个值`"Hello World."`,在python中变量的命名规则如下：

- 变量名只能包含 **字母、数字、和下划线** （在Python3中，变量名还可以包含其他Unicode字符，例如中文字符，但不推荐），且只能以 **字母或下划线** 开头。
- 变量名 **不能包含空格** 。
- **关键字和函数名** 不能用作变量名。
- 变量名最好具有可读性。

上述规则中第四条并不是必须满足的，只是为了更好维护代码而为之，前三条为必要条件。

在给变量赋值的时候，可以一次性同时赋值，例如：
~~~python
x,y,z=1,2,3
print(x,y,z)
~~~

下面简单介绍Python中常见的几种变量类型。

## 字符串


​    **字符串（string）** 就是有顺序的字符序列，在python中，字符串可以用单引号`'`或者双引号`"`来囊括：
~~~python
message1 = 'Hello'
message2 = "World"
~~~

### 修改字符串的大小写

​    字符串变量类型自带几个常用的方法，各方法作用如下：

| 方法名    | 作用                               |
| --------- | ---------------------------------- |
| `title()` | 将 **每个单词的首字母** 更改为大写 |
| `upper()` | 将 **字符串中所有字母** 更改为大写 |
| `lower()` | 将 **字符串中所有字母** 更改为小写 |

可以编写代码片段进行试验：
~~~python
message = "hello world."
print(message.title())
print(message.upper())
print(message.lower())
~~~

### 在字符串中使用变量

​    在python中，假设字符串中有一些随时会变动的值，就可以在字符串插入变量，例如：
~~~python
first_name = "hello"
last_name = "world"
full_name = f"{first_name} {last_name}"
print(full_name)
~~~

类似于`full_name`这种字符串被称为 **f字符串**，`f`是format（设置格式）的简写。

### 删除空白和前缀

​    对于计算机而言，字符串`'python'`和`'python '`完全不一样，计算机会将 **空格** 也视为一个字符，因此在一些特殊场景需要删除空白，而python为字符串变量类型也提供了方法来删除字符串左端和右端多余的空白：

| 方法       | 作用               |
| ---------- | ------------------ |
| `rstrip()` | 删除 **右端** 空白 |
| `lstrip()` | 删除 **左端** 空白 |

~~~python
message = ' python '
message = message.rstrip()
message = message.lstrip()
print(message)
~~~

​    对于部分字符串，例如URL前缀`https://`，需要使用方法`removeprefix()`来进行删除，例如：
~~~python
Nurl = 'https://github.com'
print(Nurl.removeprefix('https://'))
~~~

## 数

​    **整数** 的计算包含以下几种：
~~~python
num1 = 2
num2 = 3
print(num1+num2) #加
print(num1-num2) #减
print(num1*num2) #乘
print(num1/num2) #除
print(num1%num2) #取余
print(num1**num2) #乘方
~~~

**浮点数**的运算大致类似，这里就不再赘述，但需要注意对于 **除法** 和 **任意包含了浮点数的算式** ，其结果始终为浮点数。

​    在书写很大的数时，可以使用 **下划线** 来将位分组，使其 **清晰易读**：
~~~python
num = 14_000_000_000
print(num)
~~~

打印时不会打印下划线，这种表示方法既适用于整数，也适用于浮点数。


---

总体来说，python相比c语言的变量并没有多大的区别，只是操作变量会更加方便，实际上除了上述介绍到的，python中的很多地方相当灵活，原则上只要符合预期要求，都可以使用。
