---
title: IO类
description: 简述C++标准库中的IO类

date: 2026-09-18T13:55:29+08:00
lastmod: 2026-09-18T13:55:29+08:00
tags:
 - C++
 - IO
categories:
 - C++
math: false
mermaid: false
weight: 1002005000
---

# IO类

​    IO类主要是用于帮助处理字符相关数据的，是C++标准库中较为重要的一类，其中有三个头文件包含了大部分的IO库类型，如下表所示：
|   头文件   |                             类型                             |
| :--------: | :----------------------------------------------------------: |
| `iostream` | `istream`、`wistream`从流中读取数据<br />`ostream`、`wostream`向流中写入数据<br />`iostream`、`wiostrem`读写流 |
| `fstream`  | `ifstream`、`wifstream`从文件中读取数据<br />`ofstream`、`wofstream`向文件中写入数据<br />`fstream`、`wfstream`读写文件 |
| `sstream`  | `istringstream`、`wistringstream`从string读取数据<br />`ostringstream`、`wostringstream`向string写入数据<br />`stringstream`、`wstringstream`读写string |

其中最前面带有`w`的类型是为支持宽字符`wchar_t`而设立的，以此类推，同样存在`wcout`、`wcin`、`wcerr`等用于支持宽字符的IO库设施。

上述IO设施的使用与`cin`、`cout`这些IO设施的使用方法一致，因此这里不再赘述。

> [!WARNING]
>
> IO对象是不存在拷贝或者赋值操作的，因此下面的代码在编译时会产生错误：
> ~~~c++
> ofstream out1,out2;
> out1 = out2; //错误：不能对流对象赋值
> ifstream in(ifstream); //错误：不能初始化ifstream对象
> ifstream out3 = in(ifstream); //错误：不能拷贝流对象
> ~~~

## 条件状态

​    IO类定义了一些函数和标志来帮助我们访问和操纵流的条件状态(condition state)，这有助于进行程序的调试，如下表所示：
|        条件         |                      状态                      |
| :-----------------: | :--------------------------------------------: |
| `std::ios::iostate` | 一种机器无关类型，提供了表达条件状态的完整功能 |
| `std::ios::badbit`  |        指出 **流已崩溃** ，不可恢复错误        |
| `std::ios::failbit` |      指出 **一个IO操作失败** ，可恢复错误      |
| `std::ios::eofbit`  |     指出 **流到达了文件结束** ，可恢复错误     |
| `std::ios::goodbit` |    指出 **流未处于错误状态** ，此值保证为0     |
|      `s.eof()`      |             若`eofbit`置位返回true             |
|     `s.fail()`      |            若`failbit`置位返回true             |
|      `s.bad()`      |             若`badbit`置位返回true             |
|     `s.good()`      |               若流有效则返回true               |
|     `s.clear()`     |     重置所有状态位，恢复流为有效，返回void     |
|  `s.clear(flags)`   |            重置给定状态位，返回void            |
| `s.setstate(flags)` |           将给定状态位置位，返回void           |
|    `s.rdstate()`    |              返回流当前的条件状态              |

当一个流产生了错误时，在其上所有后续的IO操作都会失败，只有当流处于无错误状态时才能保证后续的IO操作正常进行，如下面的例子所示：
~~~c++
#include<iostream>

int main() {
    int a;
    std::cin >> a; //输入“ABC”

    std::cout << std::cin.fail() << '\n';//检查cin流的状态

    std::cin.clear();
    if(std::cin.good())
        std::cin >> a; //输入10

    std::cout << a << '\n';

    return 0;
}
~~~

运行结果如下：

~~~bash
$ ABC
1
0
~~~

可以发现即使使用了`clear()`方法来重置流状态，后续的读入语句依旧没能够正确执行，这是由于输入缓冲区中还残留着我们第一次的输入`ABC`，需要清除掉输入缓冲区中残留的数据后才会恢复正常，后续会介绍到IO缓冲区相关的处理手段。

> [!TIP]
>
> 如果需要自行查询某些状态位的情况，可以使用`rdstate()`方法读出`ioteate`类型数据后用位运算读取，例如：
> ~~~C++
> #include<iostream>
> 
> int main() {
>     int i = 0;
>     std::cin >> i;
> 
>     std::ios::iostate state = std::cin.rdstate();
> 
>     std::cout << (state & std::ios::badbit) << std::endl; //如果对应位被置位，则输出true
>     std::cout << (state & std::ios::failbit) << std::endl;
>     std::cout << (state & std::ios::eofbit) << std::endl;
>     std::cout << (state & std::ios::goodbit) << std::endl;
> 
>     return 0;
> }
> ~~~
>
> 运行结果视输入而定，可自行尝试运行。
>
> 与此同时，一个IO语句可以视为条件语句，可以用于判断一个流的状态，例如：
> ~~~c++
> #include<iostream>
> 
> int main() {
>     int i = 0;
>     while(std::cin >> i)
>         std::cout << i << std::endl;
> 
>     return 0;
> }
> ~~~
>
> 当输入非数字数值时程序就会退出`while`循环，同样可以尝试自行运行测试。

## 管理缓冲区

​    在进行IO操作的时候，一般都会设置缓冲区来缓和IO设备与处理器之间的速度不匹配的矛盾，但经过上面的一些例子我们了解到，有时候缓冲区如果不及时清理反而会对我们的程序运行造成干扰，因此有时候等不到系统为我们自动清理，我们自己就必须清理缓冲区。

### 输出缓冲区管理

​    输出流一般先将数据写入缓冲区，等缓冲区满、显式刷新、程序结束时才写入设备。

#### 显式刷新

显式刷新有下面几种操作：

|     操作     |              说明              |
| :----------: | :----------------------------: |
| `os.flush()` | 强制把流缓冲区内容写入底层设备 |
| `std::flush` |   操纵符，等价于`os.flush()`   |
| `std::endl`  |    操纵符，插入`'\n'`后刷新    |
| `std::ends`  |    操纵符，插入`'\0'`后刷新    |

例如：

~~~c++
#include <iostream>
#include <ostream>

int main() {
    std::cout << "hello" << std::flush;   // 立即输出 hello
    std::cout << "world" << std::endl;    // 输出 world 并换行、刷新
    std::cout << "end" << std::ends;      // 输出 end 和一个 '\0'，并刷新
}
~~~

运行结果如下：
~~~bash
helloworld
end
~~~

#### 自动刷新

​    如果想要在每次输出操作后都刷新缓冲区，则可以使用`unitbuf`操纵符。

|       操作       |                             说明                             |
| :--------------: | :----------------------------------------------------------: |
|  `std::unitbuf`  |                  设置流为每次输出后自动刷新                  |
| `std::nounitbuf` |                         取消自动刷新                         |
|    `os.tie()`    | 获取/设置绑定的 **输出流** ，输入操作前会自动刷新绑定的输出流 |

对于`tie()`方法，有两个重载的版本：

1. 一个版本不带参数，返回指向输出流`ostream`的指针。如果本对象关联到一个输出流，则返回的就是指向这个流的指针，如果未关联任何输出流，则返回空指针。
2. 一个版本带参数，接收一个指向`ostream`流的指针，将自己关联到该流上，若传递空指针`nullptr`则会解除原来的绑定。

> [!TIP]
>
> 默认情况下，`std::cin`和`std::cout`绑定
>
> `std::cerr`默认设置了`unitbuf`
>
> `std::clog`有缓冲

每个流最多关联到一个`ostream`流，但一个`ostream`流可以同时关联到多个流。需要注意的是，只有具有输入操作的流才能触发自动刷新的效果。

#### 底层缓冲区访问

​    可以更改输出流底层的缓冲区，操作如下：
|         操作          |                             说明                             |
| :-------------------: | :----------------------------------------------------------: |
|     `os.rdbuf()`      |               返回关联的缓冲区指针`streambuf*`               |
| `os.rdbuf(streambuf)` | 接收一个缓冲区指针，并将该缓冲区设置为新的底层缓冲区，同时会返回之前关联到缓冲区指针。可用于重定向 |

下面是一个简单的运用例子：

~~~c++
std::ofstream fout("log.txt");
std::streambuf* old = std::cout.rdbuf(fout.rdbuf()); // cout 重定向到文件
std::cout << "写入文件\n";
std::cout.rdbuf(old); // 恢复
~~~

#### 写入操作

​    下面这些操作将数据放入缓冲区，但不一定会立即写入设备。

|       操作        |                    说明                    |
| :---------------: | :----------------------------------------: |
|   `os.put(ch)`    |                写入一个字符                |
| `os.write(buf,n)` | 将另一个缓冲区buf中的n个字符写入输出缓冲区 |

### 输入缓冲区管理

​    主要分为读取、放回、窥视、丢弃、清状态、定位这几种管理手段，下面依次介绍。

#### 读取操作

​    部分读取操作会让缓冲区中的字符被取出，下面没有刻意说明的操作均会取出缓冲区。

|          操作           |                 说明                 |
| :---------------------: | :----------------------------------: |
|      `is.get(ch)`       |            读取一个字符。            |
|       `is.get()`        |    返回读取的字符（`int_type`）。    |
|  `is.getline(buf, n)`   |          读取一行到缓冲区。          |
|    `is.read(buf, n)`    |          读取 `n` 个字符。           |
|  `is.readsome(buf, n)`  |   读取一些立即可用的字符，不阻塞。   |
|       `is.peek()`       |       返回下一个字符但不读出。       |
|      `is.gcount()`      | 返回最近一次无格式输入读取的字符数。 |
| `std::getline(is, str)` |      读取一行到 `std::string`。      |
|        `std::ws`        |        操纵符，跳过前导空白。        |

需要注意，对于缓冲区buf，其类型最好是char数组，也可以使用其他类型，但基本都过于复杂，因此这里不提倡。

#### 放回和窥视

​    如果读出了缓冲区但想将读出的字符保留在缓冲区中，可以进行放回。

| 操作             | 说明                     |
| :--------------- | :----------------------- |
| `is.putback(ch)` | 把字符放回输入流。       |
| `is.unget()`     | 放回最后读取的字符。     |
| `is.peek()`      | 查看下一个字符，不提取。 |

#### 丢弃字符

​    在之前的例子中，我们可以发现如果不及时清除输入缓冲区中残留的数据，即使输入流能正常工作了，程序也无法按照预期结果运行，因此需要丢弃输入缓冲区中的字符。

| 操作                  | 说明                                              |
| :-------------------- | :------------------------------------------------ |
| `is.ignore(n, delim)` | 丢弃最多 `n` 个字符，或直到遇到 `delim`字符停止。 |
| `std::ws`             | 跳过前导空白。                                    |

因此对于上面的例子，将其改写为：
~~~c++
#include<iostream>
#include<limits>

int main() {
    int a;
    std::cin >> a; //输入“ABC”

    std::cout << std::cin.fail() << '\n';//检查cin流的状态

    std::cin.clear();
    // 丢弃缓冲区中的无效输入，直到换行符
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    if(std::cin.good())
        std::cin >> a; //输入10

    std::cout << a << '\n';

    return 0;
}
~~~

这样一来就可以cin就可以正常进行工作了。

> [!TIP]
>
> 其中的`std::numeric_limits<std::streamsize>::max()`用于查询C++流的整数类型最大值。如果将类型`std::streamsize`换成其他类型也可以用于查询其他数据类型的最大值。

> [!WARNING]
>
> `ignore`操作必须在`clear`操作之后，否则缓冲区中无效输入不会被清除。

#### 底层缓冲区访问

​    与输出缓冲区访问没有区别，只是从访问输出缓冲区变成了访问输入缓冲区，这里就不再赘述。

## 流随机访问

​    对于大部分流，我们可以使用seek函数和tell函数来随机访问流中的数据或者决定下一次读写的位置，这两个函数都各有两个版本：g版本（获取数据）支持输入流，p版本（放置数据）支持输出流。

|                      函数                      |                             说明                             |
| :--------------------------------------------: | :----------------------------------------------------------: |
|         `is.tellg()`<br />`os.tellp()`         |              返回一个输入/输出流标记的当前位置               |
|      `is.seekg(pos)`<br />`os.seekp(pos)`      | 将输入/输出流中的标记重定位到指定位置`pos`上，其一般与tell函数配合使用 |
| `is.seekg(off,from)`<br />`os.seekp(off,from)` | 将输入/输出流中的标记重定位到自`from`开始偏移`off`字节的位置上<br />其中`from`可以是下面的值之一：<br />`std::ios::beg`,流开始位置<br />`std::ios::cur`，流当前位置<br />`std::ios::end`，流结尾位置 |

其中对于只有一个参数的seek函数，其主要是用于后续返回的作用，例如：
~~~c++
std::streampos old = is.tellg();
is.seekg(0,std::ios::end);//跳到结尾
... //进行一些操作
is.seekg(old);
~~~

---

下面针对不同头文件中的IO类型举出一些简单的例子进行说明。

## iostream

该头文件中对于`(w)istream`和`(w)ostream`两种类型已经定义了例如`cin`、`cout`、`wcin`等IO设施，因此我们如果再次使用类型定义一个IO设施会导致重复定义错，因此只能定义相关IO设施的引用，例如：
~~~c++
#include<iostream>

int main(){
    std::istream& input = std::cin;
    std::ostream& output = std::cout;

    int a;
    input >> a;
    output << a;

    
    return 0;
}
~~~

而对于`(w)iostream`这种类型，一般需要配合诸如`stringstream`这种派生类进行使用，例如：

~~~c++
#include<iostream>
#include<sstream>

int main() {
    std::stringstream ss;

    // 向字符串流中写入 "42 hello"
    // 此时缓冲区内容为 "42 hello"，写指针位于末尾
    ss << "42 hello";

    // 将 stringstream 对象绑定到 iostream 引用
    // stringstream 继承自 iostream，因此既支持输入也支持输出
    std::iostream& io = ss;               // iostream

    // 将读指针移动到流的开头（偏移 0）
    // seekg 用于设置输入（读）位置，g 代表 get
    io.seekg(0);

    int x;          
    std::string s;

    // 从流中读取数据：先读整数，再读字符串
    // "42 hello" 中的 42 被读入 x，hello 被读入 s
    // 读取后流到达末尾，eofbit 被设置
    io >> x >> s;

    // 清除流的状态标志（如 eofbit）
    // 因为上面读到末尾后流状态不再是 good，不清除会影响后续输出
    io.clear();

    // 将写指针移动到流的末尾（偏移 0，从末尾算起）
    // seekp 用于设置输出（写）位置，p 代表 put
    io.seekp(0, std::ios::end);

    // 向流中追加字符串 " world"
    io << " world";

    // ss.str() 返回缓冲区中的字符串副本
    std::cout << ss.str() << '\n';

    return 0;
}
~~~

运行结果如下：
~~~bash
42 hello world
~~~

## fstream

​    该头文件中定义了用于文件IO操作的类型和函数，下面是该头文件特有的操作：

|         语句         |                            说明                            |
| :------------------: | :--------------------------------------------------------: |
|     `fstream f;`     |            创建一个`fstream`类型的未绑定文件流             |
|   `fstream fs(s);`   |     创建一个`fstream`类型的文件流，并将其绑定在文件s上     |
| `fstream fs(s,mode)` | 创建一个`fstream`类型的文件流，并以`mode`模式绑定在文件s上 |
|     `fs.open(s)`     |             打开名为s的文件，并将fs与文件s绑定             |
|     `fs.close()`     |                     关闭与fs绑定的文件                     |
|    `fs.is_open()`    |  返回一个bool值，指出与fs关联到文件是否成功打开且尚未关闭  |

> [!TIP]
>
> 对于`fstream`类型，其所接收的文件名可以是string类型，也可以是C风格字符串指针，且对于该类型的构造函数，都是 **explicit** 禁用隐式转换的，因此只能使用直接初始化形式。

如果有C语言的文件IO经验，上面的语句应该都是非常好懂的，下面是一个简单的示例：
~~~c++
#include<iostream>
#include<fstream>
#include<string>

int main() {
    std::ofstream fout("1.txt");
    if(fout.is_open()){
        fout << "Hello World";
    }
    fout.close();

    std::string s;
    std::ifstream fin("1.txt");
    if(fin.is_open()){
        fin >> s;
    }
    fin.close();
    
    std::cout << s << std::endl;

    return 0;
}
~~~

运行结果如下：

~~~bash
Hello

~~~

可以发现我们写入的`"Hello World"`最后只读出了`"Hello"`，这里可以参考之前提到的输入缓冲区中的读取操作，更改上述代码中的某一行来完整读取写入内容，这里就不给出答案了，请读者自行思考。

> [!TIP]
>
> 当`fstream`相关类型的对象因离开作用域而被销毁时，与其关联的文件也会被自动取消关联。

#### 文件模式

​    在上述的语句中有一个`mode`参数，如果接触过C语言中`fopen()`函数，应该会明白这个参数是什么意思。这里就不再赘述，只介绍C++中的文件模式：
|     模式      |                           说明                           |
| :-----------: | :------------------------------------------------------: |
|   `ios::in`   |                            读                            |
|  `ios::out`   |                            写                            |
|  `ios::app`   |                每次写操作均定位至文件末尾                |
|  `ios::ate`   |                 打开后立即定位至文件末尾                 |
| `ios::trunc`  | 截断文件，等价于清空文件内容，如果文件不存在则会创建文件 |
| `ios::binary` |                 二进制形式打开文件进行IO                 |

可以使用位运算`|`来同时设定模式，但需要注意对于输入流不能以写相关的模式打开文件，以此类推输出流不能以读相关的模式打开文件。指定文件模式需要注意如下限制：

- 只能对ofstream或fstream对象设置 **out** 模式
- 只能对ifstream或fstream对象设置 **in** 模式
- 只有当 **out** 模式被设定时才能设定 **trunc** 模式
- 只要 **trunc** 模式没有被设定，就可以设定 **app** 模式。在 **app** 模式下即使没有显式指定 **out** 模式，文件也会以输出的方式打开
- 默认情况下，如果不指定 **app** 模式，则 **out** 模式会截断文件。也可以附加 **in** 模式来同时进行文件读写，从而阻止截断文件
- **ate** 和 **binary** 模式可用于任何类型的文件流对象

> [!Tip]
>
> 每次调用不带`mode`参数的open函数时，模式都会被隐式设置为**输出和截断** 。

## sstream

​    sstream主要是用于向string中进行IO操作，其特有的操作如下表所示：
|      操作       |                 说明                  |
| :-------------: | :-----------------------------------: |
|  `sstream st`   |  st是一个未绑定的`stringstream`对象   |
| `sstream st(s)` | st保存了一个`string`类型的s的一个拷贝 |
|   `st.str()`    |     返回了st所保存的`string`拷贝      |
|   `st.str(s)`   | 将`string`类型的s拷贝到st中，返回void |

同样的，其构造函数也是`explicit`禁用隐式转换的。下面是一个较为复杂的例子，可以稍微多花点时间进行理解：
~~~c++
#include<iostream>
#include<sstream>
#include<vector>
#include<string>

using namespace std;

struct PersonInfo{
    string name;
    vector<string> phones;
};

int main() {
    string line,word;
    vector<PersonInfo> people;
    while(getline(cin,line)){
        PersonInfo info;
        istringstream record(line); //使用istringstream
        record >> info.name; //读取姓名

        while(record >> word)
            info.phones.push_back(word); //读取电话号码

        people.push_back(info);//加入名单
    }

    for(const auto &pp : people){
        ostringstream phones; //使用ostringstream
        for(const auto &nums : pp.phones){
            phones << " " << nums; //将数的字符串形式存入
        }

        cout << pp.name << " "
             << phones.str() << endl; //输出信息
    }

    return 0;
}
~~~

运行结果如下：
~~~bahs
morgan 11111111 22222222
drow 22313441 231824714
les 12341723 124137234
morgan  11111111 22222222
drow  22313441 231824714
les  12341723 124137234
~~~

---

​    总体来说IO类在C++中的某些场景应用得比较多，大致了解其中的用法有助于更好地处理IO相关的操作。
