# sed

## 一、sed简介

sed 是一种在线编辑器，它一次处理一行内容。处理时，把当前处理的行存储在临时缓冲区中，称为“模式空间”（pattern space），接着用sed命令处理缓冲区中的内容，处理完成后，把缓冲区的内容送往屏幕。接着处理下一行，这样不断重复，直到文件末尾。文件内容并没有 改变，除非你使用重定向存储输出。Sed主要用来自动编辑一个或多个文件；简化对文件的反复操作；编写转换程序等。



## 二、sed选项

```bash
使用方法：

sed  选项     sed内置命令字符  文本

选项：
    -n    屏蔽默认输出，常与sed内置命令p一起用
    -i    将结果写入文件
    -e    多次编辑，不需要管道符
    -r    支持扩展正则

内置命令：
                a    append，对文本追加，在指定行后增加1或多行
                d        delete 删除匹配行
                i        insert，表示插入文本，在指定行前添加1或多行
                p        打印匹配行的内容，通过与-n一起用
                s/正则/替换内容/g    匹配正则内容，然后替换内容，结尾g代表全局匹配
                
sed匹配范围：
空地址       全文处理
单地址       指定某一行
/pattern/    被模式匹配到的每一行
范围区间      1,2 一到二行，10,+5第10行向下5行，/pattern1/,/pattern2/
步长          1~2 奇数行，2~2偶数行
```



## 三、sed示例

### 1.基本操作

```
sed  -n '1p' test.txt        	#遍历文本，1p代表只看第1行
sed  -n '1,2p' test.txt        	#看1-2行
sed -n '2p;4p' test.txt        	#输出第2、第4
sed  -n '1,+2p' test.txt        #输出1行，+后面的2行
sed -n '1~2p' test.txt          #输出第1行，后面的奇数行3 5 7 9...
sed -n '/^root/p' test.txt      #输出以root开头的行
sed -n '$=' test.txt          	#显示最后一个行号
sed -n '=' test.txt           	#只显示文件所有的行号
sed -n '$=' /etc/passwd      	#查看主机所有账号数量
```



### 2.数据删除

```bash
sed '1d' test.txt          		#删除第1行
sed -i '5d' test.txt        	#删除第5行，并写入文件
```



### 3.数据替换

```bash

sed 's/qq/weixin/g' 1.txt   	 	#替换文件中的 qq 为 weixin(加-i写入文件)，或者使用重定向

sed '3s/2017/AAAA/2;3s/2017/AAAA/2'   	#将第三行的第2、3个2017替换成AAAA          
2017 2011 2018
2017 2017 2024
2017 AAAA AAAA

sed 's#/bin/bash#/sbin/nologin#' 2      #将/bin/bash替换成/sbin/nologin      
```



### 4.文本内容追加

```bash
sed '2i i am 27' 1.txt					#在第二行上面追加
sed -i '2a I am joshaaa' josh2         	#在第二行下追加I am joshaaa   

 #追加多行，在第三行下追加两行（\n），追加内容（i like linux.       and you?）    
sed -i "3a i like linux.\nand you?" josh2        
sed "a----------" 1.txt 				#在每行下都添加新内容
```



### 5.获取网卡地址

```bash
#取出IP对应的行
[root@localhost grep]# ifconfig | sed -n '10p'
        inet 192.168.204.128  netmask 255.255.255.0  broadcast 192.168.204.255
        
#找到第10行后，去掉IP之前的内容
[root@localhost grep]# ifconfig | sed -n '10s#^.*inet##gp'
 192.168.204.128  netmask 255.255.255.0  broadcast 192.168.204.255

-n 取消默认输出
10s 是处理第10行内容
#^.*inet## 匹配inet前面所有内容
gp代表全局替换且打印替换结果

[root@localhost grep]# ifconfig | sed -n '10s#^.*inet##gp' | sed -n 's/net.*$//gp'
 192.168.204.128 
 
 net.*$ 匹配net到结尾的内容
 s/net.*$//gp 把匹配到内容替换为空


#-e多次编辑
[root@localhost grep]# ifconfig | sed -ne '10s/^.*inet//g' -e '10s/net.*$//gp'
 192.168.204.128 
```
