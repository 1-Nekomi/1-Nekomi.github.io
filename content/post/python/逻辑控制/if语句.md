---
title: if语句
description: 介绍了python中的if语句，配合一些简单的例子进行说明

date: 2026-08-20T22:12:50+08:00
lastmod: 2026-08-20T22:12:50+08:00
tags:
 - python
 - if语句
categories:
 - python
math: false
mermaid: false
weight: 1003001000
---

# if语句

​    python中的if语句与C语言中的if语句略有不同，主要集中在关键字和语句表现形式上，下面对其进行简单描述。

​    最简单的if语句如下所示：
~~~python
cars = ['audi','bmw','subaru','toyota']

for car in cars:
    if car == 'bmw':
        print(car.upper())
    else:
        print(car.title())
~~~

运行结果如下：

~~~bash
Audi
BMW
Subaru
Toyota
~~~

> [!TIP]
>
> 上述if语句中的`else`代码块在编码的时候可以忽略，因此最简单的if语句结构只有一个if逻辑判断行。

如果第一个条件判定失败，需要判定第二个条件，则可以使用`if-elif-else`结构，例如：

~~~python
age = 12
if age < 4:
    print('cost $0')
elif age < 18:
    print('cost $25')
else:
    print('cost $40')
~~~

运行结果如下：
~~~bash
cost $25
~~~

其中`elif`代码块理论上可以存在无限个，但`if`和`else`代码块在整个结构中只能存在一个。

参与if语句最重要的成分就是 **布尔表达式** ，其通过逻辑判断最终返回一个布尔值(True/False)，if语句就会根据该布尔值决定执行跳转。

而python中几个布尔运算符主要有`==`,`!=`,`>`,`<`,`>=`,`<=`。

## 多个条件

​    一般来说if判断都是可以同时判断多个条件的，在python中， **求并** 运算使用关键字`and`， **求或** 运算使用关键字`or`，例如：

~~~python
age1 = 10
age2 = 22

if age1>14 and age2<39:
    print(True)
else:
    print(False)
    
if age1<14 or age2<39:
    print(True)
else:
    print(False)
~~~

可以自行判断上述代码片段的运行结果。

## 检查列表中的特定值

​    可以在if语句中穿插关键字`in`来检查列表中是否存在某个特定值，在关键字`in`前加上关键字`not`来检查列表中是否不存在某个特定值，例如：
~~~python
topping = ['mushroom','onions','pineapple']
if 'onions' in topping:
    print(True)
else:
    print(False)
    
if 'pineapple' not in topping:
    print(True)
else:
    print(False)
~~~

同样可以自行判断上述代码片段的运行结果。

## 检查列表非空

​    当 **布尔表达式为列表名** 时，表达式会根据列表是否为空返回布尔值。例如:
~~~python
cars = []
if cars:
    print('list is not empty')
else:
    print('list is empty')
~~~

运行结果如下：
~~~bash
list is empty
~~~

可以看到非空时会返回`True`，否则返回`False`。

---

总体而言，python的if语句和C语言中的if语句存在一定程度的区别，但还是很好理解其在python中的用法的。