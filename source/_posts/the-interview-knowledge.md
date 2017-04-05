---
title: 面试的可能知识点总结
date: 2016/04/18 10:33:05
thumbnail: https://o5iqfmxl6.qnssl.com/16-4-23/66383221.jpg
categories:
- 技术
tags:
- Java
- Android
- 对象
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

|                           | mark word | class pointer | array size (opt) | padding |
| :-----------------------: | :-------: | :-----------: | :--------------: | :-----: |
|          **32位**          |   4byte   |     4byte     |    ~~4byte~~     |         |
| **64位+UseCompressedOops** |   8byte   |     4byte     |    ~~4byte~~     |         |
| **64位-UseCompressedOops** |   8byte   |     8byte     |    ~~4byte~~     |         |

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

[参考1](http://wuchong.me/blog/2014/03/25/interview-link-questions/) [参考2](http://blog.sina.com.cn/s/blog_725dd1010100tqwp.html)

给定一个单链表，只给出头指针head：
1. 如何判断是否存在环？
2. 如何知道环的长度？
3. 如何找出环的连接点在哪里？
4. 带环链表的长度是多少？
5. 单链表转置
6. 求链表倒数第k个节点
7. 求链表的中间节点
8. 在O(1)时间删除链表节点

## 2.1 判断一个单链表是否有环

**题目描述:** 输入一个单向链表，判断链表是否有环？

**题目分析:**

对于这个问题，使用追赶的方法，设置两个头指针`fast` `slow`，每次让`high`移动两个位置，`low`移动一个位置，如果有环的话，两个肯定会有相等的时候，如果high指针最后为空则说明没有环。

``` c
bool isExistLoop(Node *head) {
	Node *fast = head;
	Node *slow = head;
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
int getLoopLength(Node *head) {
	Node *fast = head;
	Node *slow = head;
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
Node* findLoopPoint(Node *head) {
	Node *fast = head;
	Node *slow = head;
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

## 2.5 单链表转置

**题目描述：**输入一个单向链表，输出逆序反转后的链表

**题目分析：**

链表的转置是一个很常见、很基础的数据结构题了，非递归的算法很简单，用三个临时指针 pre、head、next 在链表上循环一遍即可。递归算法也是比较简单。

```c
// 单链表的转置，循环方法
Node* reverse(Node *head) {
  	if (head == NULL || head->next == NULL) return head;
  	Node *pre = NULL;
  	Node *next = NULL;
  	while (head != NULL) {
  		next = head->next;
      	head->next = pre;
      	pre = head;
      	head = next;
	}
  	return pre;
}
// 递归方法
Node* reverseByRecursion(Node *head) {
  	if (head == NULL || head->next == NULL) return head;
  	Node *phead = reverseByRecursion(head->next);
  	head->next->next = haed;
  	head->next = NULL;
  	return phead;
}
```

## 2.6 求链表倒数第k个节点

**题目描述：** 给定一个单链表，设计一个时间和空间都高效的算法来找到链表的倒数第k个元素。当k=0时，返回链表的最后一个元素。

**题目分析:**

设置两个指针，指向当前位置的指针和前m个元素的指针。在遍历的时候做统计， 当第一个指针移动m个时，同时移动第二个指针。当链表长度小于m时，如果不进行处理，很容易引起空指针异常。

```c
Node* FindKToLastElement(Node *head, int k) {
  	if (k < 0) return NULL;
  	Node *p1, *p2;
  	p1 = head;
  	for (int i = 0; i< k; i++) {
  		if (p1->next != NULL) {
  			p1 = p1->next;
  		} else {
  			return NULL;
        }
	}
  	p2 = head;
  	while (p1->next != NULL) {
  		p1 = p1->next;
      	p2 = p2->next;
    }
  	return p2;
}
```

## 2.7 求链表的中间节点

**题目描述：**求链表的中间节点，如果链表的长度为偶数，返回中间两个节点的任意一个，若为奇数，则返回中间节点。

**题目分析：**

此题的解决思路和第3题「求链表的倒数第 k 个节点」很相似。可以先求链表的长度，然后计算出中间节点所在链表顺序的位置。但是如果要求只能扫描一遍链表，如何解决呢？最高效的解法和第3题一样，通过两个指针来完成。用两个指针从链表头节点开始，一个指针每次向后移动两步，一个每次移动一步，直到快指针移到到尾节点，那么慢指针即是所求。

```c
Node* theMiddleNode(Node *head) {
  	if (head == NULL) return NULL;
  	Node *slow = head;
  	Node *fast = head;
  	while (fast != null && fast->next != NULL) {
  		fast = fast->next->next;
      	slow = fast->next;
    }
  	return slow;
}
```

## 2.8 在O(1)时间删除链表节点

**题目描述：**给定链表的头指针和一个节点指针，在O(1)时间删除该节点。[Google面试题]

**分析：**

本题与《编程之美》上的「从无头单链表中删除节点」类似。主要思想都是「狸猫换太子」，即用下一个节点数据覆盖要删除的节点，然后删除下一个节点。但是如果节点是尾节点时，该方法就行不通了。

``` c
void deleteRandomNode(Node *cur) {
  	assert(cur != NULL);
	assert(cur->next != NULL);
  	Node pNext = cur->next;
  	cur->data = pNext->data;
  	cur->next = pNext->next;
  	delete next;
}
```



# 3.JAVA

## 3.1 JAVA虚拟机

1. 原子性
2. 可见性
3. 有序性

### 3.1.1 原子性

> ​    原子性就是一个操作（可能是需要多步完成的复合操作）不能被打断，一旦开始执行直到执行完其他线程或多核都必须等待。比如”i++”表达式，就不是原子的，汇编后会发现由三条指令（读取，修改，写入）完成，每一条指令完成后都可能被中断。

由Java内存模型来直接保证的原子性变量操作包括`read`、`load`、`use`、`assign`、`store`和`write`六个，大致可以认为基础数据类型的访问和读写是具备原子性的。如果应用场景需要一个更大范围的原子性保证，Java内存模型还提供了`lock`和`unlock`操作来满足这种需求，尽管虚拟机未把`lock`与`unlock`操作直接开放给用户使用，但是却提供了更高层次的字节码指令`monitorenter`和`monitorexit`来隐匿地使用这两个操作，这两个字节码指令反映到Java代码中就是同步块---`synchronized`关键字，因此在`synchronized`块之间的操作也具备原子性。









## 3.2 Object中的方法

如下，共有9种方法。

```java
public final native Class<?> getClass();
public native int hashCode();
public boolean equals(Object obj) {
        return (this == obj);
}
protected native Object clone() throws CloneNotSupportedException;
public String toString() {
        return getClass().getName() + "@" + Integer.toHexString(hashCode());
}
public final native void notify();
public final native void notifyAll();
public final native void wait(long timeout) throws InterruptedException;
public final void wait(long timeout, int nanos) throws InterruptedException {
    if (timeout < 0) {
		throw new IllegalArgumentException("timeout value is negative");
    }
	if (nanos < 0 || nanos > 999999) {
		throw new IllegalArgumentException("nanosecond timeout value out of range");
	}
	if (nanos > 0) {
		timeout++;
	}
	wait(timeout);
}
public final void wait() throws InterruptedException {
	wait(0);
}
 protected void finalize() throws Throwable { }
```

1. `getClass():` 返回此 Object 的运行时类。 
2. `hashCode():` 返回该对象的哈希值。
3. `equals():` 指示其他某个对象是否与此对象“相等”。 
4. `clone():` 创建并返回此对象的一个副本。
5. `toString():` 返回对象的字符串表示。
6. `notify():` 唤醒在次对象监视器上等待的单个线程*(注意的是在调用此方法的时候，并不能确切的唤醒某一个等待状态的线程，而是由JVM确定唤醒哪个线程，而且不是按优先级)*。
7. `ntifyAll():` 唤醒在此对象监视器上等待的所有线程。 
8. `wait():` 在其他线程调用此对象的 notify() 方法或 notifyAll() 方法，或者超过指定的时间量前，导致当前线程等待。 
9. `finalize():` 当垃圾回收器确定不存在对该对象的更多引用时，由对象的垃圾回收器调用此方法。 










# 4. 排序算法

## 4.1 直接选择排序: _不稳定_

### 4.1.1 说明

<center>**效果图:** ![sort1][] </center>

直接选择排序(Straight Select Sorting) 也是一种简单的排序方法，它的基本思想是：第一次从R[0]~R[n-1]中选取最小值，与R[0]交换，第二次从R[1]~R[n-1]中选取最小值，与R[1]交换，....，第i次从R[i-1]~R[n-1]中选取最小值，与R[i-1]交换，.....，第n-1次从R[n-2]~R[n-1]中选取最小值，与R[n-2]交换，总共通过n-1次，得到一个按排序码从小到大排列的有序序列·





### 4.1.2 代码

```c
void SelectSort(elemtype R[], int n) {
	int i, j, m;
	elemtype t;
	for(i=0; i<n-1; i++) {
		m = i;
		for(j = i+1; j < n; j++) {
			if(R[j] < R[m])
				m = j;
		}
		if(m != i) {
			t = R[i];
			R[i] = R[m];
			R[m] = t;
		}
	}
}
```



### 4.1.3 效率分析

> 在直接选择排序中，共需要进行n-1次选择和交换，每次选择需要进行 n-i 次比较 (1<=i<=n-1),而每次交换最多需要3次移动，因此，总的比较次数C=(n*n - n)/2,总的移动次数 3(n-1).由此可知，直接选择排序的时间复杂度为 O(n2) (n的平方)，所以当记录占用字节数较多时，通常比 直接插入排序的执行速度快些。
>
> 由于在直接选择排序中存在着不相邻元素之间的互换，因此，直接选择排序是一种不稳定的排序方法。

## 4.2 直接插入排序:*稳定*

### 4.2.1 说明

<center>![sort2][]</center>

插入排序的基本方法是：每步将一个待排序的记录按其关键字的大小插到前面已经排序的序列中的适当位置，直到全部记录插入完毕为止。

具体实现有两种方法:

1. 简单方法

               > 首先在当前有序区R[1..i-1]中查找R[i]的正确插入位置k(1≤k≤i-1)；然后将R[k．．i-1]中的记录均后移一个位置，腾出k位置上的空间插入R[i]。

2. 改进的方法

   >一种查找比较操作和记录移动操作交替地进行的方法。具体做法：
   >将待插入记录R[i]的关键字从右向左依次与有序区中记录R[j](j=i-1，i-2，…，1)的关键字进行比较：
   >① 若R[j]的关键字大于R[i]的关键字，则将R[j]后移一个位置；
   >②若R[j]的关键字小于或等于R[i]的关键字，则查找过程结束，j+1即为R[i]的插入位置。
   >关键字比R[i]的关键字大的记录均已后移，所以j+1的位置已经腾空，只要将R[i]直接插入此位置即可完成一趟直接插入排序。


算法中引进的附加记录L[0]称监视哨或哨兵(Sentinel)。哨兵有两个作用：

1. 进人查找(插入位置)循环之前，它保存了L[i]的副本，使不致于因记录后移而丢失L[i]的内容；
2. 它的主要作用是：在查找循环中"监视"下标变量j是否越界。一旦越界(即j=0)，因为L[0].可以和自己比较，循环判定条件不成立使得查找循环结束，从而避免了在该循环内的每一次均要检测j是否越界(即省略了循环判定条件"j>=1")。


### 4.2.2 代码

```c
void InsertSort(SqList &L) {
  	int i, j;
 	for (i = 2; i <= L.leight; i++) {
  		if (L.r[i].key < L.r[i-1].key) {
  			L.r[0] = L.r[i];
      		L.r[i] = L.r[i - 1];
			for (j = i - 2; L.r[0].key < L.r[j].key; j--) {
  				L.r[j+1] = L.r[j];
			}
        }
	}
}
```

### 4.2.3 效率分析

> 从空间来看，直接插入排序仅需要一个记录的辅助空间。
>
> 从时间来看，其时间复杂度为`O(n^2)`。



## 4.3 折半插入排序: *稳定*

### 4.3.1 说明

折半插入排序（binary insertion sort）是对`插入排序`算法的一种改进，由于排序算法过程中，就是不断的依次将元素插入前面已排好序的序列中。由于前半部分为已排好序的数列，这样我们不用按顺序依次寻找插入点，可以采用折半查找的方法来加快寻找插入点的速度。

### 4.3.2 代码

```c
void BInsertSort(SqList &L) {
	for (int i = 2; i <= L.lenght; i++) {
  		L.r[0] = L.r[i];
      	low = 1; high = i - 1;
      	while (low <= high) {
  			m = (low + high) / 2;
          	if (L.r[0].key < L.r[m].key) {
         		//折半区在低半区
  				high = m - 1;
           	} else {
              	//折半区在高半区
  				low = m + 1;
          	}
		}
      	//记录后移
      	for (j = i - 1; j >= high +1; j--) {
  			L.r[j+1] = L.r[j];
        }
      	//插入
      	L.r[high+1] = L.r[0];
	}
}
```

### 4.3.3 效率分析

> 折半插入排序算法是一种稳定的排序算法，比直接插入算法明显减少了关键字之间比较的次数，因此速度比`直接插入排序`算法快，但记录移动的次数没有变，所以折半插入排序算法的时间复杂度仍然为`O(n^2)`，与直接插入排序算法相同。附加空间`O(1)`。
>
> 折半查找只是减少了比较次数，但是元素的移动次数不变，所以时间复杂度为`O(n^2)`。



## 4.4 冒泡排序:*稳定*

### 4.4.1 说明

### <center>![sort4][]</center>

是一种简单的排序算法。它重复地走访过要排序的数列，一次比较两个元素，如果他们的顺序错误就把他们交换过来。走访数列的工作是重复地进行直到没有再需要交换，也就是说该数列已经排序完成。这个算法的名字由来是因为越小的元素会经由交换慢慢**浮**到数列的顶端。

### 4.4.2 代码

```c
void bubble_sort(int a[], int n) {
    int i, j, temp;
    for (j = 0; j < n - 1; j++)
        for (i = 0; i < n - 1 - j; i++) {
            if(a[i] > a[i + 1]) {
                temp = a[i];
                a[i] = a[i + 1];
                a[i + 1] = temp;
            }
        }
}
```

### 4.4.3 效率分析

> 若文件的初始状态是正序的，一趟扫描即可完成排序。所需的关键字比较次数和记录移动次数均达到最小值。所以，冒泡排序最好的时间复杂度为`O(n)`.
>
> 若初始文件是反序的，需要进行`n-1`趟排序。每趟排序要进行`n-i`次关键字的比较`(1≤i≤n-1)`，且每次比较都必须移动记录三次来达到交换记录位置。在这种情况下，比较和移动次数均达到最大值：
>
> <center>![](http://f.hiphotos.baidu.com/baike/s%3D171/sign=f38fc3a1bb389b503cffe455b434e5f1/838ba61ea8d3fd1f846a7b85324e251f95ca5f2a.jpg) </center>
>
> <center>![](http://a.hiphotos.baidu.com/baike/s%3D186/sign=41bfe6dab119ebc4c4787291b427cf79/7af40ad162d9f2d36fa2fd50abec8a136227ccda.jpg) </center>
>
> 冒泡排序的最坏时间复杂度为`O(n^2)`.
> 综上，因此冒泡排序总的平均时间复杂度为`O(n^2)`.



## 4.5 希尔排序:*不稳定*

### 4.5.1 说明

**希尔排序**，也称**递减增量**排序算法，是**插入排序**的一种更高效的改进版本。希尔排序是不稳定排序算法。

希尔排序是基于插入排序的以下两点性质而提出改进方法的：

- 插入排序在对几乎已经排好序的数据操作时，效率高，即可以达到线性排序的效率


- 但插入排序一般来说是低效的，因为插入排序每次只能将数据移动一位

一个更好理解的希尔排序实现：将数组列在一个表中并对列排序（用插入排序）。重复这过程，不过每次用更长的列来进行。最后整个表就只有一列了。将数组转换至表是为了更好地理解这算法，算法本身仅仅对原数组进行排序

希尔排序通过将比较的全部元素分为几个区域来提升插入排序的性能。这样可以让一个元素可以一次性地朝最终位置前进一大步。然后算法再取越来越小的步长进行排序，算法的最后一步就是普通的插入排序，但是到了这步，需排序的数据几乎是已排好的了（此时插入排序较快）。

假设有一个很小的数据在一个已按升序排好序的数组的末端。如果用复杂度为O(n2)的排序（冒泡排序或插入排序），可能会进行n次的比较和交换才能将该数据移至正确位置。而希尔排序会用较大的步长移动数据，所以小数据只需进行少数比较和交换即可到正确位置。（通过增加索引的步长，例如是用`i += step_size`而不是`i++`）。

其排序过程图如下:

<center>![sort5][]</center>



### 4.5.2 代码

```c
void ShellInsert (SqList &L, int dk) {
	//对顺序表L做一趟希尔插入排序。与直接插入排序相比:
  	// 1. 前后记录位置增量为dk
  	// 2. r[0]只是暂存单元，不是哨兵。当j <= 0时，插入位置已经找到。
  	for (i = dk + 1; i <= L.length; i++) {
  		if (L.r[i].key < L.r[i - dk].key) {	//需要将L.r[i]插入有序增量子序列
  			L.r[0] = L.r[i];				//暂存在r[0]
          	for (j = i - dk; j >0 && L.r[0].key < L.r[j].key; j-= dk) {
  				L.r[j + dk] = L.r[j];		//记录后移，查找插入位置
			}
        	L.r[j+dk] = L.r[0];				//插入
		}
	}
}
void ShellSort (SqList &L, int dlta[], int t) {
  	//使用增量序列dlta[0..t-1]对顺序表L做希尔排序
  	for (k = 0; k < t; k++) {
  		ShellInsert(L, dlta[k]);
	}
}
```



### 4.5.3 效率分析

**增量**的选择是希尔排序的重要部分。只要最增量长为1任何增量序列都可以工作。算法最开始以一定的增量进行排序。然后会继续以一定增量进行排序，最终算法以增量为1进行排序。当增量为1时，算法变为插入排序，这就保证了数据一定会被排序。

Donald Shell最初建议增量选择为`2/n`并且对增量取**半**直到增量达到1。虽然这样取可以比`O(n^2)`类的算法（*插入排序*）更好，但这样仍然有减少平均时间和最差时间的余地。可能**希尔排序**最重要的地方在于当用较小步长排序后，以前用的较大步长仍然是有序的。比如，如果一个数列以增量5进行了排序然后再以增量3进行排序，那么该数列不仅是以增量3有序，而且是以增量5有序。如果不是这样，那么算法在*迭代*过程中会打乱以前的顺序，那就不会以如此短的时间完成排序了。

## 4.6 归并排序:*稳定*

 ### 4.6.1 说明

<center>![sort6][]</center>

归并操作（merge），也叫归并算法，指的是将两个已经排序的序列合并成一个序列的操作。归并排序算法依赖归并操作。

- 迭代法
  1.  申请空间，使其大小为两个已经排序序列之和，该空间用来存放合并后的序列
  2.  设定两个指针，最初位置分别为两个已经排序序列的起始位置
  3.  比较两个指针所指向的元素，选择相对小的元素放入到合并空间，并移动指针到下一位置
  4.  重复步骤3直到某一指针到达序列尾
  5.  将另一序列剩下的所有元素直接复制到合并序列尾


- 递归法
  1. 将序列每相邻两个数字进行归并操作，形成floor(n/2)个序列，排序后每个序列包含两个元素
  2. 将上述序列再次归并，形成floor(n/4)个序列，每个序列包含四个元素
  3. 重复步骤2，直到所有元素排序完毕

### 4.6.2 代码

``` c

```











[1]: https://o5iqfmxl6.qnssl.com/16-4-23/66383221.jpg
[sort1]: https://o5iqfmxl6.qnssl.com/16-4-23/29445357.jpg
[sort2]: https://o5iqfmxl6.qnssl.com/16-4-23/62551407.jpg

[sort4]: https://o5iqfmxl6.qnssl.com/md/1461465386831.gif
[sort5]: https://o5iqfmxl6.qnssl.com/16-4-23/41203511.jpg
[sort6]: https://o5iqfmxl6.qnssl.com/md/1461465668753.gif

