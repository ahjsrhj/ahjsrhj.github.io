---

---

# 1. Java对象大小与引用的大小
[来源](http://www.liaohuqiu.net/cn/posts/caculate-object-size-in-java/)

一个实例化的对象在内存中需要存储的信息包括：

- 对象的头部(对象的GC信息，hash值，类定义引用等)
- 对象的成员变量: 包括基本数据类型和引用。 如成员变量是一个引用, 引用了其他对象，被引用的对象内存另外计算。

<!-- more -->

## 1.1 对象的大小

一个对象的大小其中包含:
- 自身的大小
> 直接计算当前对象占用空间大小，包括当前类及超类的基本类型实例字段大小、引用类型实例字段引用大小、实例基本类型数组总占用空间、实例引用类型数组引用本身占用空间大小
- 所引用对象的大小

## 1.2 引用的大小

在32位JVM上，一个对象引用占用4字节，64位上，占8个字节。

> 如果不需要访问超过4G内存，可以通过`-XX:+UseCompressedOops`选项开启指针压缩。从**Java 1.6.0\_23**开始，这个选项默认是开启的。

---

比如下面一个简单的类:
``` java
class MyClass {
	int a;
	Object object;
}
MyClass myClass = new MyClass();
```
创建一个**myClass**实例之后，首先需要在栈空间中分配一个地址空间，即引用，引用的大小视虚拟机平台，32位为4字节，64位为8字节*在开启指针压缩的情况下为4字节*。之后在堆空间中分配对象的类变量信息。本例中包括类的头部+一个int类型数值+一个引用类型。


## 1.3 基本数据类型大小
|    类型     | 大小(位) | 大小(字节) |                    范围                    |
| :-------: | :---: | :----: | :--------------------------------------: |
| boolean\* |   8   |   1    |                true/false                |
|   byte    |   8   |   1    |                -128 - 127                |
|  char\*   |  16   |   2    |                0 - 65535                 |
|   short   |  16   |   2    |              -32768 - 23767              |
|    int    |  32   |   4    |         -2147483648 - 2147483647         |
|   long    |  64   |   8    | -9223372036854775808 - 9223372036854775807 |
|   float   |  32   |   4    |             -3.4E38 - 3.4E38             |
|  double   |  64   |   8    |            -1.7E308 - 1.7E308            |
> 需要注意的是，boolean类型在内存中实际使用的只有一字节的最低位，其余位全置0。因为内存处理以字节(**byte**)为单位，而不是位(**bit**)。char类型从字符型对应的整型数来划分，其表示范围是0 - 65535

## 1.4 对象头部大小
对象头结构如下[来源](http://mail.openjdk.java.net/pipermail/hotspot-runtime-dev/2008-May/000147.html)

mark word|class pointer|array size (opt)|padding
---------|-------------|----------------|-------

> 每个对象都有一个mark work头部，以及一个引用，指向类的信息。在32位JVM上，markword 4个字节，整个头部有8字节大小。



> array size(opt)在对象为数组的时候启用，4字节（4byte）长度。JVM规定对象头（Object Header）长度为2个字（word），在32bit JVM中，一个word长度为4byte，64bit JVM中，长度为8byte



> 在未开启UseCompressedOops的64位JVM上，对象头有16字节大小。



> 在开启UseCompressedOops的64位机器上，引用（class pointer）成了4字节，一共12字节。按照8位对齐，实际占用16字节。

## 1.5 数组内存占用大小
数组在内存中也是以引用形式存在，所以也有对象的头部，数组还有一个记录数组长度的int类型，随后是每一个数组的元素：基本数据类型或引用类型。也按照8字节对齐。
- **32位机器**
> byte[0] 12字节的对象头部(*mark word: 4byte, class pointer: 4byte, array size: 4byte*),对齐后是16字节。实际 byte[0] \~byte[4]都是16字节(每个byte的长度为1byte，byte[0]-byte[4]占用padding长度)。
- **64位+UseCompressedOops**
> byte[0] 16字节的对象头部(*mark word: 8byte, class pointer: 4byte, array size: 4byte*),byte[1] \~byte[8] 24字节大小。
- **64 位-UseCompressedOops**
> byte[0] 20字节的对象头部(*mark word: 8byte, class pointer: 8byte, array size: 4byte*),对齐后是24字节。byte[0] \~ byte[4] 都是24字节。

# 2. 单链表
给定一个单链表，只给出头指针h：
1. 如何判断是否存在环？
2. 如何知道环的长度？
3. 如何找出环的连接点在哪里？
4. 带环链表的长度是多少？

## 2.1 判断一个单链表是否有环

**题目描述:** 输入一个单向链表，判断链表是否有环？

**题目分析:** 

对于这个问题，使用追赶的方法，设置两个头指针`fast` `slow`，每次让`high`移动两个位置，`low`移动一个位置，如果有环的话，两个肯定会有相等的时候，如果high指针最后为空则说明没有环。

``` c
bool isExistLoop(List *head) {
	List *fast = head;
	List *slow = head;
	while (fast != NULL && fast->next != NULL) {
		slow = slow->next;
		fast = fast->next->next;
		if (slow == fast)
			return TRUE;
	}
	return FALSE;
}
```

## 2.2 如何知道环的长度

**题目描述:** 输入一个单链表，如果单链表存在环，环的长度是多少？

**题目分析:** 

首先确定问题1里两个指针相遇的节点，记录下这个节点，之后让其中一个再跑一圈，再次碰撞走过的步数就是环的长度。

``` c
int getLoopLength(List *head) {
	List *fast = head;
	List *slow = head;
	int sum = 0;
	while (fast != NULL && fast->next != NULL) {
		slow = slow->next;
		fast = fast->next->next;
		if (fast == slow)
			break;
	}
	if (fast != slow) return 0;
	do {
		fast = fast->next;
		sum++;
	} while (fast != slow);
	return sum;
}
```
## 2.3 如何找出环的连接点在哪里？

**题目描述:** 输入一个单向链表，判断链表是否有环。如果链表存在环，如何找到环的连接点？

**题目分析:**
首先确定链表有没有环，如果有环的话，让`fast`指针从头节点重新走一遍，走的步长为1，同时让`slow`节点从当前位置继续前进，当两个节点再次相遇时，所在的节点即是环的**连接点**。
有定理如下：
> 碰撞点p到连接点的距离=头指针到连接点的距离，因此，分别从碰撞点、头指针开始走，相遇的那个点就是连接点。

**推导:**  假设从头结点到环连接点的距离为a，从连接点到碰撞点的距离为b，圆周距离为L，那么从两个指针出发到碰撞，两个指针分别走过的路程为:

- `fast` : `a + b + k * L = 2n`
- `slow` : `a + b = n `

又因为`fast`指针所走过的路程为`slow`指针所走路程的2倍：`a + b = k * L = n ` 。所以一个指针从头结点出发，另一个从碰撞点出发，经过n步之后，还可以到达碰撞点。因为b这段距离是在环内走的，所以只有a这段是不同的，当两个指针再次重合时，必然是在连接点。

```c
List* findLoopPoint(List *head) {
	List *fast = head;
	List *slow = head;
	while (fast != NULL && fast->next != NULL) {
		slow = slow->next;
		fast = fast->next->next;
		if (slow == fast)
			break;
	}
	if (fast != slow) return NULL;
  	fast = head;
  	while (fast != slow) {
  		fast = fast->next;
      	slow = slow->next;
    }
  	return fast;
}
```

## 2.4 带环链表的长度是多少？

**题目描述:** 输入一个单向链表，判断链表是否有环。如果链表存在环，链表的长度是多少?

**题目分析:** 

使用问题2中获得的环的长度加上问题三中环的连接点位置，即为链表的长度。

~~代码省略~~



