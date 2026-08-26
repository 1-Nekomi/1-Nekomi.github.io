---
title: NumPy和Matplotlib
description: 简单介绍深度学习中常用的第三方库Numpy、Matplotlib的基础用法

date: 2026-08-26T16:26:29+08:00
lastmod: 2026-08-26T18:29:06+08:00
tags:
 - 深度学习
 - python
 - numpy
 - matplotlib
 - 第三方库
categories:
 - python
math: false
mermaid: false
weight: 1003003001
---

# Numpy和Matplotlib

在进行深度学习的实验时，Numpy和Matploylib是两个比较常用的第三方库，其中Numpy是用于 **数组和矩阵的运算** ，Matplotlib是用于 **绘制图形和数据的可视化** 。下面简单介绍这两种第三方库的使用。

## Numpy

### 生成数组

​    使用`array()`方法可以生成Numpy数组，该方法接收一个 **Python列表** 作为参数，生成NumPy数组（numpy.ndarray）。

~~~python
import numpy as np

x = np.array([1.0,2.0,3.0])
print(x)
print(type(x))
~~~

运行结果如下：

~~~bash
[1. 2. 3.]
<class 'numpy.ndarray'>
~~~

### 算术运算

​    对于Numpy数组运算，遵循对应元素的运算，例如：
~~~python
import numpy as np

x = np.array([1.0,2.0,3.0])
y = np.array([2.0,4.0,6.0])
print(x+y)
print(x-y)
print(x*y)
print(x/y)
~~~

运行结果如下：
~~~bash
[3. 6. 9.]
[-1. -2. -3.]
[ 2.  8. 18.]
[0.5 0.5 0.5]
~~~

> [!WARNING]
>
> 对于上述运算，必须要保证参与运算的数组元素个数要一致。

同时数组也可以参与广播运算，后续会对广播机制进行介绍。

### N维数组

​     Numpy不仅可以生成一维数组（向量），还可以生成多维数组。例如生成一个二维数组（矩阵）：
~~~python
import numpy as np

A = np.array([[1,2],[3,4]])
print(A)
print(A.shape)
print(A.dtype)
~~~

运行结果如下：
~~~bash
[[1 2]
 [3 4]]
(2, 2)
int64
~~~

多维数组可以简单视为矩阵，但这个时候还是只能进行对应元素之间的运算，例如：
~~~python
import numpy as np

A = np.array([[1,2],[3,4]])
B = np.array([[3,0],[0,6]])
print(A + B)
print(A * B)
~~~

运行结果如下：
~~~bash
[[ 4  2]
 [ 3 10]]
[[ 3  0]
 [ 0 24]]
~~~

注意上述运算不等同于矩阵运算，可以自行进行纸笔运算验证。

同样，多维数组也可以基于广播机制进行标量运算，会在后续的广播机制介绍部分涉及。

### 广播

​    之前介绍Numpy中的数组部分时，不管是一维还是多维数组，均可以利用广播机制进行标量运算，如下面程序所示：
~~~python
import numpy as np

A = np.array([1.0,2.0,3.0])
B = np.array([[2.0,4.0],[6.0,8.0]])
print(A*2)
print(B/2)
~~~

运行结果如下：
~~~bash
[2. 4. 6.]
[[1. 2.]
 [3. 4.]]
~~~

实际上广播机制就是 **将参与运算的标量/维度更小的数组拓展为与参与运算且维度更大的数组相同维度大小** ，因此上述程序等价于：
~~~python
import numpy as np

A = np.array([1.0,2.0,3.0])
B = np.array([[2.0,4.0],[6.0,8.0]])
C = np.array([2.0,2.0,2.0])
D = np.array([[2.0,2.0],[2.0,2.0]])
print(A/C)
print(B/D)
~~~

可以看到运行结果与第一段程序无异。

假设参与的是两个数组，但其中一个数组维度大于另一个数组，一样可以利用广播机制参与运算：
~~~python
import numpy as np

A = np.array([[1,2],[3,4]])
B = np.array([10,20])
print(A*B)
~~~

运行结果如下：
~~~bash
[[10 40]
 [30 80]]
~~~

根据广播机制的本质，可以尝试写出上述程序的等价形式，这里就不再赘述。

### 访问元素

​    元素的索引从0开始，对元素的访问可以像C语言中那样进行访问，例如：
~~~python
import numpy as np

X = np.array([[51,55],
              [14,19],
              [0,4]])
print(X[0]) # 第0行
print(X[2][1]) # (2,1)的元素

for row in X:
    print(row)
    
for row in X:
    for element in row:
        print(element)
~~~

运行结果如下：
~~~bash
[51 55]
4
[51 55]
[14 19]
[0 4]
51
55
14
19
0
4
~~~

上述访问均通过索引进行访问的，也可以 **使用数组/列表访问各个元素**，也就是标记法，例如：

~~~python
import numpy as np

X = np.array([[51,55],
              [14,19],
              [0,4]])

print(X[[0,1]]) # 获取第0、1行的元素

X = X.flatten() # 将X转换为一维数组
print(X[np.array([0,2,4])]) # 获取索引为0、2、4的元素

print(X[X>15]) # 获取大于15的元素
~~~

运行结果如下：
~~~bash
[[51 55]
 [14 19]]
[51 14  0]
[51 55 19]
~~~

> [!TIP]
>
> 上述的`flatten()`方法可以将多维数组展开为一维数组。
>
> 对于最后一种形式`X[X>15]`，首先对X数组进行逻辑判断运算，会返回布尔类型的数组，例如：
> ~~~python
> import numpy as np
> 
> X = np.array([[51,55],
>               [14,19],
>               [0,4]])
>          
> print(X>15)
> ~~~
>
> 运行结果如下：
> ~~~bash
> [[ True  True]
>  [False  True]
>  [False False]]
> ~~~
>
> 最后再利用这个数组对X进行标记，取出布尔值为`True`的元素，就可以达到取出X数组中大于15的元素的目的了。

## Matplotlib

### 绘制简单图形

​    可以使用matplotlib中的pyplot模块绘制图形，例如绘制一个sin函数曲线：
~~~python
import numpy as np
import matplotlib.pyplot as plt

# 生成数据
x = np.arange(0,6,0.1) # 以0.1为单位，生成0到6的一维数组
y = np.sin(x)

# 绘制图形
plt.plot(x,y)
plt.show()
~~~

运行结果如下图所示：
![sin函数图形](/images/unit/1003003001/1.png)

> [!NOTE]
>
> 在上述程序中使用了`arange()`方法来生成一个一维数组。
>
> 使用了`sin()`方法来生成一个与x数组维度相同且经过sin函数计算后的数组y
>
> 将横坐标数据（x数组）和纵坐标数据（y数组）传递给`plot()`方法就能画出标准的sin函数图形。

### pyplot的功能

​    在上述程序中我们尝试加入cos函数图形，并使用pyplot的添加标题和x轴标签名等其他功能：
~~~python
import numpy as np
import matplotlib.pyplot as plt

# 生成数据
x = np.arange(0,6,0.1) # 以0.1为单位，生成0到6的一维数组
y1 = np.sin(x)
y2 = np.cos(x)

# 绘制图形
plt.plot(x,y1,label='sin')
plt.plot(x,y2,linestyle='--',label='cos')

plt.xlabel('x')
plt.ylabel('y')
plt.title('sin & cos')

plt.legend()
plt.show()
~~~

运行结果如下：
![sin函数和cos函数图形](/images/unit/1003003001/2.png)

> [!NOTE]
>
> 在上述程序中的`legend()`方法一般用于让设置的标签参数`label`生效，假设没有使用这个方法，则放置的标签可能不会生效。
>
> 具体表现就是图中用于注释线条含义的框框没了，可以自行运行比较差异。

### 显示图像

​    pyplot还提供了用于显示图像的方法`imshow()`，还可以使用`matplotlib.image`模块中的`imread()`方法读入图像，例如：
~~~python
import matplotlib.pyplot as plt
from matplotlib.image import imread

img = imread('test.png')
plt.imshow(img)

plt.show()
~~~

运行结果如下面所示，其中图像为自己设置的：
![测试图像](/images/unit/1003003001/3.png)

---

​    本文只介绍了最简单的使用形式，假设需要了解更多可以去阅读《利用Python进行数据分析》这本书，该书中对NumPy进行了简单易懂的总结。可以通过下面的链接下载原书pdf。

{{<externalLinkCard title="Z-Library" link="https://zh.z-library.sk/book/Yv3DNQb2Om/利用python进行数据分析-原书第2版.html" cover="https://zh.z-library.sk/img/footer/Y@2x.png">}}