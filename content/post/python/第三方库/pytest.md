---
title: pytest
description: 介绍python中用于测试代码的第三方库pytest的用法

date: 2026-08-25T17:09:44+08:00
lastmod: 2026-08-25T17:25:27+08:00
tags:
 - pytest
 - python
 - 测试
 - 第三方库
categories:
 - python
math: false
mermaid: false
weight: 1003003000
---

# pytest

​    `pytest`是用于测试代码的 **第三方库（third-party package）**，要使用它，需要先通过python的包管理器`pip`来进行安装：
~~~bash
# 升级pip
python -m pip install --upgrade pip

# 安装pytest
python -m pip install pytest
~~~

上述操作最好在虚拟环境中进行，关于虚拟环境的描述，请参考以下博客：

{{<postLinkCard path="/post/python/其他/python中的虚拟环境" cover="auto" >}}

## 测试函数

​    下面是个简单的函数：
~~~python
# name_func.py
def get_formatted_name(first, last):
    """生成格式规范的姓名"""
    full_name = f"{first} {last}"
    return full_name.title()
~~~

上述函数用于将名和姓合并成姓名，并将首字母大写。

按照原来的方法，如果我们要测试这个函数需要为其配套编写测试代码块来保证其正常工作。但这样实在是太繁琐，而pytest为我们提供了方便的自动测试。

### 单元测试和测试用例

​    测试方法多种多样，一种最简单的测试方法是 **单元测试（unit test）** ，用于核实函数某方面没问题。**测试用例（test case）** 是一组单元测试，需要考虑多方面的输入结果。

​    对于pytest，我们需要编写一个测试函数，它会调用要测试的函数，并使用`assert`语句做出有关返回值的断言，以上面的`get_formatted_name()`函数为例：
~~~python
# test_name.py
from name_func import get_formatted_name

def test_first_name():
    formatted_name = get_formatted_name('janis', 'joplin')
    assert formatted_name == 'Janis Joplin'
~~~

> [!WARNING]
>
> 需要注意的是，用于测试函数的py文件和函数需要以`test_`开头，当运行pytest时，pytest会寻找所有以`test_`开头的py文件并运行其中所有以`test_`开头的测试函数。

接着我们打开终端用pytest运行`test_name.py`文件：
~~~bash
$ pytest
======================================= test session starts =======================================
platform win32 -- Python 3.12.6, pytest-9.1.1, pluggy-1.6.0
rootdir: D:\Coding\Python-Study
collected 1 item

test_name.py .                                                                               [100%]

======================================== 1 passed in 0.01s ========================================
~~~

可以看到pytest会显示测试平台、python版本、pytest版本、工作目录、测试项目、测试文件、最终通过测试数量、测试消耗时间等信息，这可以帮助我们收集相关信息。

### 测试失败的情况

假设测试失败了会怎么样？我们以上述的`get_formatted_name()`函数为例：
~~~python
# name_func.py
def get_formatted_name(first, middle , last):
    """生成格式规范的姓名"""
    full_name = f"{first} {middle} {last}"
    return full_name.title()
~~~

再次运行pytest：
~~~bash
$ pytest
======================================= test session starts =======================================
platform win32 -- Python 3.12.6, pytest-9.1.1, pluggy-1.6.0
rootdir: D:\Coding\Python-Study
collected 1 item

test_name.py F                                                                               [100%]

============================================ FAILURES =============================================
_________________________________________ test_first_name _________________________________________

    def test_first_name():
>       formatted_name = get_formatted_name('janis', 'joplin')
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
E       TypeError: get_formatted_name() missing 1 required positional argument: 'last'

test_name.py:5: TypeError
===================================== short test summary info =====================================
FAILED test_name.py::test_first_name - TypeError: get_formatted_name() missing 1 required positional argument: 'last'
======================================== 1 failed in 0.06s ========================================
~~~

其中我们只需要关注第19行的`FAILED`就可以了，其他信息都是用来辅助描述错误信息的。

对于上述没有通过的测试，一般都是优先修改函数而不是修改测试样例，如果我们将函数`get_formatted_name()`修改成如下：
~~~python
# name_func.py
def get_formatted_name(first, last, middle=''):
    """生成格式规范的姓名"""
    if middle:
        full_name = f"{first} {middle} {last}"
    else:
        full_name = f"{first} {last}"
    return full_name.title()
~~~

在运行测试就不会发生错误了：
~~~bash
$ pytest
======================================= test session starts =======================================
platform win32 -- Python 3.12.6, pytest-9.1.1, pluggy-1.6.0
rootdir: D:\Coding\Python-Study
collected 1 item

test_name.py .                                                                               [100%]

======================================== 1 passed in 0.01s ========================================
~~~

而为了测试修改后的函数是否正常，可以新增测试：
~~~python
# test_name.py
from name_func import get_formatted_name

def test_first_name():
    ...

def test_middle_name():
    formatted_name = get_formatted_name(first='janis',middle='mozart',last='joplin')
    assert formatted_name == 'Janis mozart Joplin'
~~~

运行测试：
~~~bash
$ pytest
======================================= test session starts =======================================
platform win32 -- Python 3.12.6, pytest-9.1.1, pluggy-1.6.0
rootdir: D:\Coding\Python-Study
collected 2 items

test_name.py .F                                                                              [100%]

============================================ FAILURES =============================================
________________________________________ test_middle_name _________________________________________

    def test_middle_name():
        formatted_name = get_formatted_name(first='janis',middle='mozart',last='joplin')
>       assert formatted_name == 'Janis mozart Joplin'
E       AssertionError: assert 'Janis Mozart Joplin' == 'Janis mozart Joplin'
E
E         - Janis mozart Joplin
E         ?       ^
E         + Janis Mozart Joplin
E         ?       ^

test_name.py:10: AssertionError
===================================== short test summary info =====================================
FAILED test_name.py::test_middle_name - AssertionError: assert 'Janis Mozart Joplin' == 'Janis mozart Joplin'
=================================== 1 failed, 1 passed in 0.06s ===================================
~~~

可以看到有一个测试因为断言失败而导致测试失败，但这并不能说明一定是函数的问题，也有可能是测试用例设计得不当导致的测试失败，在不同情况下需要具体分析。

## 测试类

​    在测试函数时我们使用了`assert`语句，但只使用了其中一种断言，测试中常用的断言语句如下表所示：
|               断言               |         用途         |
| :------------------------------: | :------------------: |
|         `assert a == b`          |    断言两个值相等    |
|         `assert a != b`          |    断言两个值不等    |
|            `assert a`            | 断言a的布尔值为True  |
|          `assert not a`          | 断言a的布尔值为False |
|   `assert <element> in <list>`   |   断言元素在列表中   |
| `assert <element> not in <list>` |  断言元素不在列表中  |

要测试类与测试函数还是存在少许区别，下面编写一个帮助管理匿名调查的类：
~~~python
# survey.py
class AnonymousSurvey:
    """收集匿名调查问卷的答案"""

    def __init__(self, question,):
        """存储一个问题，并为存储答案做准备"""
        self.question = question
        self.responses = []

    def show_question(self):
        """显示调查问卷"""
        print(self.question)

    def store_response(self, new_respondes):
        """存储单份调查答卷"""
        self.responses.append(new_respondes)

    def show_results(self):
        """显示收集到的所有答卷"""
        print("Survey result:")
        for result in self.responses:
            print(f"- {result}")
~~~

为了测试`AnonymousSurvey`类，我们要验证如果用户只提供一个答案，这个答案也能被妥善存储：
~~~python
# test_survey
from survey import AnonymousSurvey

def test_store_single_response():
    """测试单个答案会被妥善存储"""
    question = 'What language did you first learn to speak?'
    language_survey = AnonymousSurvey(question)
    language_survey.store_response('English')
    assert 'English' in language_survey.responses
~~~

运行测试，结果如下：
~~~bash
$ pytest
======================================= test session starts =======================================
platform win32 -- Python 3.12.6, pytest-9.1.1, pluggy-1.6.0
rootdir: D:\Coding\Python-Study
collected 1 item

test_survey.py .                                                                             [100%]

======================================== 1 passed in 0.01s ========================================
~~~

### 夹具

​    在我们测试`AnonymousSurvey`类时编写了一个测试用例，但是要想测试一个体量较大的类，需要编写许多测试用例，假设每个测试用例中都实例化一个`AnonymousSurvey`对象，那么会导致测试开销过大。这个时候可以使用 **夹具（fixture）** 来帮助我们搭建测试环境，例如对于上述测试用例，我们可以编写夹具：
~~~python
# test_survey
import pytest
from survey import AnonymousSurvey

@pytest.fixture
def language_survey():
    """一个可供所有测试函数使用的AnonymousSurvey类"""
    question = 'What language did you first learn to speak?'
    language_survey = AnonymousSurvey(question)
    return language_survey

def test_store_single_response(language_survey):
    """测试单个答案会被妥善存储"""
    language_survey.store_response('English')
    assert 'English' in language_survey.responses
~~~

> [!TIP]
>
> 其中`@pytest.fixture`是一种 **装饰器（decorator）**，装饰器一般放在函数定义前面，**本质上是一个高阶函数，它接收一个函数作为参数，并返回一个新的函数** ，用于拓展原函数的功能。

运行测试，结果同上。可以看到不论我们写多少个类的测试用例，都可以使用夹具来为我们提前搭建测试需要的类对象，以减少测试过程中消耗的时间和空间开销。

---

总体来看，pytest是一个较为实用的第三方库工具，能够很方便地让我们完成一系列测试并得到测试数据，在python中还有其他很多有用的第三方库工具，可以在参与项目的过程中留意。
