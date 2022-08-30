## Hadoop的优势：

```tex
1、高可靠性：Hadoop底层维护多个数据副本，所以即使Hadoop某个计算元素或存储出现故障，也不会导致数据的丢失。
2、高扩展性：在集群间分配任务数据，可方便的扩展数以千计的节点
3、高效性：在MapReduce的思想下，Hadoop是并行工作的，以加快任务处理
4、高容错性：能够自动将失败的任务重新分配（4次）
```

## Hadoop的组成：

```tex
1.X：HDFS（数据存储）、 MapReduce（计算+资源调度） Common（辅助工具）
2.X：HDFS（数据存储）、MapReduce（计算）、Yarn（资源调度）、Common（辅助工具）
```

## HDFS的架构：

```tex
NameNode（nn）：是HDFS的大哥，管理和存储所有真实数据的元数据信息（文件名、文件大小、创建时间等）
DataNode（dn）：是HDFS的小弟，存储真实的数据，以块为单位。默认的块大小是128M，存储到HDFS后，是两块，128M，72M
Secondary NameNode（2nn）：是NameNode的秘书，辅助NameNode干活，分担NameNode工作，减轻NameNode的压力
```

## Yarn的架构：

```tex
ResourceManager（rm）：是Yarn的大哥，管理和分配集群中所有的资源（来自于每个机器的资源）
NodeManager（nm）：是Yarn的小弟，管理所在机器的资源
ApplicationMaster（am）：每个Job都对应一个ApplicationMaster，主要负责Job的执行过程（资源申请、监控、容错等）
Container：对资源的抽象封装、防止资源被侵占
```

## MapReduce的思想：

```tex
MapReduce将计算过程分为两个阶段：Map和Reduce
1、Map阶段并行处理输入数据（将数据分到多台机器进行计算）
2、Reduce阶段对Map结果进行汇总（将多台机器中运算的结果统一汇总）
```

## 环境搭建：

1）克隆虚拟机，虚拟机配置要求如下：

​	1、单台虚拟机：内存4G(最少2G)，硬盘50G，安装必要环境(最小化安装)

```shell
sudo yum install -y epel-release
sudo yum install -y psmisc nc net-tools rsync vim lrzsz ntp libzstd openssl-static tree iotop
```

​	2、修改克隆虚拟机的静态IP(按照自己机器的网络设置进行修改)

2）修改主机名

​	1、修改主机名

```shell
sudo vim /etc/hostname
```

​	2、配置主机名称映射，打开/etc/hosts

```tex
192.168.1.101	hadoop101
192.168.1.102	hadoop102
192.168.1.103	hadoop103
192.168.1.104	hadoop104
192.168.1.105	hadoop105
```

​	3、修改/etc/sudoers文件，找到下面一行(91行)，在root下面添加一行，如下所示：

```shell
atguigu	ALL=(ALL)	NOPASSWD:ALL
```

​	4、在/opt目录下创建文件夹

+ 在/opt目录下创建module、software文件夹

```shell
sudo mkdir module
sudo mkdir software
```

+ 修改module、software文件夹的所有者

```shell
sudo chown atguigu:atguigu /opt/module /opt/software
```

## 安装JDK

1、将JDK安装包上传到Linux /opt/software目录下

2、解压JDK到/opt/module目录下

3、配置JDK环境变量，两种方式：

+ 第一种：新建/etc/profile.d/my_env.sh文件（推荐）

```shell
sudo vim /etc/pfofile.d/my_env.sh
#添加内容如下
#JAVA_HOME
export JAVA_HOME=/opt/module/jdk1.8.0_212
export PATH=$PATH:$JAVA_HOME/bin
#保存后退出
#重启Xshell窗口，让环境变量生效
```

+ 第二种：直接将环境变量配置到/ect/profile文件中，在/etc/profile文件的末尾追加如下内容：

  ```shell
  JAVA_HOME=/opt/module/jdk1.8.0_212
  PATH=$PATH:$JAVA_HOME/bin
  export PATH JAVA_HOME
  #保存退出，然后执行如下命令
  source /etc/profile
  ```

  ## 安装Hadoop

  Hadoop下载地址：https://archive.apache.org/dist/hadoop/common/hadoop-3.1.3/

  1、将hadoop安装包上传到/opt/software目录下

  2、解压安装文件到/opt/module下面

  ```shell
  tar -zxvf hadoop-3.1.3.tar.gz -C /opt/module/
  ```

  3、将Hadoop添加到环境变量

  ```shell
  JAVA_HOME=/opt/module/jdk1.8.0_144
  HADOOP_HOME=/opt/module/hadoop-3.1.3
  PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
  export PATH JAVA_HOME HADOOP_HOME
  ```

  4、重启（如果Hadoop命令不能用再重启）

  ```shell
  [atguigu@hadoop101 profile.d]$ sync
  [atguigu@hadoop101 profile.d]$ sudo reboot
  ```

  ##### Hadoop重要目录：

  ```te
  1、bin目录：存放对Hadoop相关服务（HDFS，YARN）进行操作的脚本
  2、etc目录：Hadoop的配置相关目录，存放Hadoop的配置文件
  3、lib目录：存放Hadoop的本地库（对数据进行压缩解压缩功能）
  4、sbin目录：存放启动或停止Hadoop相关服务的脚本
  5、share目录：存放Hadoop的依赖jar包、文档和官方案例
  ```

  ##### Hadoop运行模式：

  Hadoop运行模式包括：本地模式、伪分布式模式以及完全分布式模式

  1、Hadoop默认配置就是本地模式，因此不需要进行任何设置即可运行本地模式

  ##### Hadoop的官方案例：

  + grep：通过指定好的正则，匹配输入文件中满足规则的单词并输出

  ```shell
  $ mkdir input
  $ cp etc/hadoop/*.xml input
  $ bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.3.jar grep input output 'dfs[a-z.]+'
  $ cat output/*
  ```

  + wordcount：统计输入文件中的每个单词出现的次数

图形化界面系统安装jdk需要注意的问题：

默认自带了openjdk，我们在安装自己的jdk之前，需要将openjdk卸载

如何卸载：

```te
1、查询卸载
rpm -qa | grep -i java
2、卸载
rpm -e --nodeps 查询到的rpm包
3、组合实现
rpm -qa | grep -i java | xargs -n1 sudo rpm -e --nodeps
```

 2、完全分布式模式环境准备

```tex
准备三台客户机（关闭防火墙、静态ip、主机名称）
安装JDK
配置环境变量
安装Hadoop
配置环境变量
配置集群
单点启动
配置ssh
群起并测试集群
```

##### 编写集群分发脚本xsync：

1、scp（secure copy）安全拷贝

scp可以实现服务器与服务器之间的数据拷贝

基本语法

```shell
scp		-r 		$pdir/$fname    		$user@hadoop$host:$pdir/$fname
命令		递归		要拷贝的文件路径/名称		目的用户@主机:目的路径/名称
```

案例实施

前提：在 hadoop101、hadoop102、hadoop103都已经创建好的/opt/module、

/opt/software两个目录，并且已经把这两个目录修改为atguigu:atguigu

+ 在hadoop101上，将hadoop101中/opt/module目录下的软件拷贝到hadoop102上

```shell
scp -r /opt/module atguigu@hadoop102:/opt/module
```

+ 在hadoop103上，将hadoop101服务器上的/opt/module目录下的软件拷贝到hadoop103上

```shell
scp -r atguigu@hadoop103:/opt/module atguigu@hadoop103:/opt/module
```

+ 在hadoop103上操作将hadoop101中/opt/module目录下的软件拷贝到haoop104上

```shell
scp -r atguigu@hadoop101:/opt/module atguigu@hadoop104:/opt/module
```

2、远程同步工具

rsync主要用于备份和镜像，具有速度快、避免复制相同内容和支持符号链接的优点

基本语法

```shell
rsync    -av    			$pdir/$fname    		$user@hadoop$host:$pdir/$fname
命令		归档拷贝、显示复制过程		要拷贝的文件路径/名称		目的用户@主机:目的路径/名称  
```

案例实施

+ 把hadoop101机器上的/opt/software目录同步到hadoop102服务器的/opt/software目录下

```shell
rsync -av /opt/software/ atguigu@hadoop102:/opt/software
```

3、xsync集群分发脚本

+ 需求：循环复制文件到所有节点的相同目录下
+ 期望脚本：基于rsync技术将文件从一个节点同步到其他所有节点

```te
xsync 要同步的文件名称
```

+ 脚本实现

```shell
#!/bin/bash
#1、判断参数个数
if [ $# -lt 1 ]
then
  echo Not Enough Argument!
  exit;
fi
#2、遍历集群所有机器
for host in hadoop101 hadoop102 hadoop103
do
  echo =============$host=============
  #3、遍历所有目录，挨个发送
  for file in $@
  do
    #4、判断文件是否存在
    if [ -e $file ]
    then
      #5、获取父目录
      pdir=$(cd -P $(dirname $file); pwd)
      #6、获取当前文件的名称
      fname=$(basename $file)
      ssh $host "mkdir -p $pdir"
      rsync -av $pdir/$fname $host:$pdir
    else
      echo $file does not exists!
    fi
  done
done
```

+ 修改脚本xsync具有执行权限

```shell
chmod +x xsync
```

## 集群配置

##### 1、集群部署规划

注意：NameNode和SecondaryNameNode不要安装在同一台服务器

注意：ResourceManager也很消耗内存，不要和NameNode、SecondaryNameNode配置在同一台机器上



|      | hadoop101          | hadoop102                    | hadoop103                   |
| ---- | ------------------ | ---------------------------- | --------------------------- |
| HDFS | NameNode、DataNode | DataNode                     | SecondaryNameNode、DataNode |
| YARN | NodeManager        | ResourceManager、NodeManager | NodeManager                 |

##### 2、配置文件说明

Hadoop配置文件分两类：默认配置文件和自定义配置文件，只有用户想修改某一默认配置时，才需要修改自定义配置文件，更改相应属性值

+ 默认配置文件：

| 要获取的默认文件     | 文件存放在Hadoop的jar包中的位置                           |
| -------------------- | --------------------------------------------------------- |
| [core-default.xml]   | hadoop-common-3.1.3.jar/core-default.xml                  |
| [hdfs-default.xml]   | hadoop-hdfs-3.1.3.jar/hdfs-default.xml                    |
| [yarn-default.xml]   | hadoop-yarn-common-3.1.3.jar/yarn-default.xml             |
| [mapred-default.xml] | hadoop-mapreduce-client-core-3.1.3.jar/mapred-default.xml |

+ 自定义配置文件：

core-site.xml、hdfs-site.xml、yarn-site.xml、mapred-site.xml四个配置文件存放在$HADOOP_HOME/etc/hadoop这个路径上下，用户可以根据需求重新修改配置

##### 3、配置集群

+ 配置：hadoop-env.sh

Linux系统中获取JDK的安装路径：

```shell
echo $JAVA_HOME
```

在hadoop-env.sh文件中修改JAVA_HOME路径：

```shell
export JAVA_HOME=/opt/module/jdk1.8.0_212
```

+ 核心配置文件

**配置core-site.xml**

```shel
cd $HADOOP_HOME/etc/hadoop
vim core-site.xml
```

文件内容如下：

```xml
<!--指定NameNode的地址-->
<property>
	<name>fs.defaultFS</name>
    <value>hdfs://hadoop101:9820</value>
</property>
<!--指定hadoop数据的存储目录 官方配置文件中的配置项是hadoop.tmp.dir，用来指定hadoop数据的存储目录，此次配置用的hadoop.data.dir是自己定义的变量，因为在hdfs-site.xml中会使用此配置的值来具体指定namenode和datanode存储数据的目录-->
<property>
	<name>hadoop.data.dir</name>
    <value>/opt/module/hadoop-3.1.3/data</value>
</property>
<!--下面是兼容性配置，跳过-->
<!--配置atguigu(superuser)允许通过代理访问的主机节点-->
<property>
	<name>hadoop.proxyuser.atguigu.hosts</name>
    <value>*</value>
</property>
<!--配置该atguigu(superuser)允许代理的用户所属组-->
<property>
	<name>hadoop.proxyuser.atguigu.groups</name>
    <value>*</value>
</property>
<!--配置该atguigu(superuser)允许代理的用户-->
<property>
	<name>hadoop.proxyuser.atguigu.users</name>
    <value>*</value>
</property>
    
```

**配置hdfs-site.xml**

文件内容如下：

```xml
<!--指定副本数-->
<property>
	<name>dfs.replication</name>
    <value>3</value>
</property>
<!--指定NameNode数据的存储目录-->
<!--file: 本地的意思-->
<property>
	<name>dfs.namenode.name.dir</name>
    <value>file://${hadoop.data.dir}/name</value>
</property>
<!--指定DataNode数据的存储目录-->
<property>
	<name>dfs.datanode.data.dir</name>
    <value>file://${hadoop.data.dir}/data</value>
</property>
<!--指定SecondaryNameNode数据的存储目录-->
<property>
	<name>dfs.namenode.checkpoint.dir</name>
    <value>file://${hadoop.data.dir}/namescondary</value>
</property>
<!--兼容性配置，先跳过-->
<property>
	<name>dfs.client.datanode.restart.timeout</name>
    <value>30s</value>
</property>
<!--nn web端访问地址-->
<property>
	<name>dfs.namenode.http-address</name>
    <value>hadoop101:9870</value>
</property>
<!--2nn web端访问地址-->
<property>
	<name>dfs.namenode.secondary.http-address</name>
    <value>hadoop103:9868</value>
</property>
```

**配置yarn-site.xml**

文件内如下：

```xml
<!--指定mapreduce_shuffle方式-->
<property>
	<name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
</property>
<!--指定ResourceManager的地址-->
<property>
	<name>yarn.resourcemanager.hostname</name>
    <value>hadoop102</value>
</property>
<!--环境变量的继承-->
<property>
	<name>yarn.nodemanager.env-whitelist</name> 			      
    <value>
JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME
    </value>
</property>
<!--取消虚拟内存的限制
<property>
	<name>yarn.nodemanager.vmem-check-enabled</name>
    <value>false</value>
</property>
-->
```

**配置mapred-site.xml**

文件内容如下：

```xml
<!--指定MapReduce程序运行在Yarn上-->
<property>
	<name>mapreduce.framework.name</name>
    <value>yarn</value>
</property>
```

4、集群单点启动

+ 如果集群是第一次启动，需要格式化NameNode

```shell
hdfs namenode -format
```

+ 在hadoop101上启动NameNode

```shell
hdfs --daemon start namenode
```

+ 完成后执行jps命令，看到如下结果(进程号可能不同)

```shell
3461 NameNode
```

+ 在hadoop101、hadoop102、hadoop103上执行如下命令（三台都要执行）启动datanode

```shell
hdfs --daemon start datanode
```

+ 在hadoop103上启动secondarynamenode

```shell
hdfs --daemon start secondarynamenode
```

+ 在hadoop102上启动ResourceManager

```shell
yarn --daemon start resourcemanager
```

+ 在hadoop101，hadoop102、hadoop103上执行如下命令（三台都要执行）启动nodemanager

```shell
yarn --daemon start nodemanager
```

##### 格式化需要注意的问题

思考：为什么不能一直格式化NameNode，格式化NameNode，要注意什么？

注意：格式化NameNode，会产生新的集群id，导致DataNode中记录的集群id和刚生成的NameNode的集群id不一致，DataNode找不到NameNode。所以，格式化NameNode时，一定要先删除每个节点的data目录和logs日志，然后再格式化NameNode。

##### 出现错误看日志

说明：在企业中遇到bug时，经常根据日志提示信息去分析问题，解决bug

通过tail -n 100 日志文件   的形式查看

## ssh无密登录配置

+ ssh

基本语法：

```shell
ssh 另一台电脑的ip地址或主机名
```

ssh连接时出现Host key verification faild

+ 配置免密

分别在hadoop101、hadoop102、hadoop103生成公钥和私钥：

```shell
ssh-keygen -t rsa
```

然后敲（三个回车），就会在~/.ssh目录下生成两个文件

id_rsa（私钥）、id_rsa.pub（公钥）

分别在hadoop101、hadoop102、hadoop103执行，将公钥拷贝到免密登录的目标机器上

```shell
ssh-copy-id hadoop101
ssh-copy-id hadoop102
ssh-copy-id hadoop103
```

注意：

如果还想实现其他用户的免密登录还需要在每台节点上采用其他账号，完成免密的配置

**群起集群**

+ 配置workers文件（2.x是slaves文件）

```shell
vim /opt/module/hadoop-3.1.3/etc/hadoop/workers
```

在该文件中增加如下内容：

```tex
hadoop101
hadoop102
hadoop103
```

注意：该文件中添加的内容结尾不允许有空格，文件中不允许有空行

同步workers文件到其他节点

```shell
xsync workers
```

+ 启动集群

如果集群是第一次启动，需要在hadoop101节点格式化NameNode

(注意格式化之前一定要停止上次启动的所有namenode和datanode进程，然后再删除data和log数据)

启动HDFS

```shell
start-dfs.sh
```

在配置了ResourceManager的节点(hadoop102)启动YARN

```shell
start-yarn.sh
```

**测试集群**

```shell
hadoop fs -mkdir /wcinput
hadoop fs -put 待上传数据   /wcinput
#执行wordcount
hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.3.jar wordcount /wcinput /wcoutput
```

**配置历史服务器**

为了查看程序的历史运行情况，需要配置一下历史服务器。具体配置步骤如下：

+ 配置mapred-site.xml

在该文件里增加如下配置：

```xml
<!--历史服务器端地址-->
<property>
	<name>mapreduce.jobhistory.address</name>
    <value>hadoop101:10020</value>
</property>
<!--历史服务器web端地址-->
<property>
	<name>mapreduce.jobhistory.webapp.address</name>
    <value>hadoop101:19888</value>
</property>
```

+ 分发配置

```shell
xsync $HADOOP_HOME/etc/hadoop/mapred-site.xml
```

+ 在Hadoop101启动历史服务器

```shell
mapred --daemon start historyserver
```

**配置日志的聚集**

日志聚集概念：应用运行完成以后，将程序运行日志信息上传到HDFS系统上。

日志聚集功能好处：可以方便的查看到程序运行详情，方便开发调试

注意：开启日志聚集功能，需要重新启动NodeManager、ResourceManager和HistoryManager

+ 配置yarn-site.xml

在该文件里面增加如下配置：

```xml
<!--开启日志聚集功能-->
<property>
	<name>yarn.log-aggregation-enable</name>
    <value>true</value>
</property>
<!--查看日志的路径-->
<property>
	<name>yarn.log.server.url</name>
    <value>http://hadoop101:19888/jobhistory/logs</value>
</property>
<!--日志存储的时间 默认一周-->
<property>
	<name>yarn.log-aggregation.retain-seconds</name>
    <value>604800</value>
</property>
```

分发配置：

```shell
xsync $HADOOP_HOME/etc/hadoop/yarn-site.xml
```

关闭NodeManager、ResourceManager和HistoryServer

```shell
在102上执行：stop-yarn.sh
在101上执行：mapred --daemon stop historyserver
```

启动NodeManager、ResourceManager和HistoryServer

```shell
在102上执行：start-yarn.sh
在101上执行：mapred --daemon start historyserver
```

删除HDFS上已经存在的输出文件

```shell
hdfs dfs -rm -R /user/atguigu/output
```

## 集群时间同步

时间同步的方式：找一个机器，作为时间服务器，所有的机器与这台集群时间进行定时的同步，比如，每隔十分钟，同步一次时间

时间服务器hadoop101<------------------------------------------------------------------------------------>其他机器hadoop102

​                                            Hadoop102定时去获取hadoop101时间服务器主机的时间

检查ntp是否安装

修改ntp配置文件

修改/etc/sysconfig/ntpd文件

重新启动ntpd服务

设置ntpd服务开机启动

**Hadoop相关端口号：**				

```tex
1、NameNode内部通信端口：8020
2、NameNode Web端端口：9870
3、2NN Web端端口：9868
4、ResourceManager Web端端口：8088
5、历史服务器Web端端口：19888
```

## HDFS优缺点

+ 优点

高容错性

```tex
数据自动保存多个副本，它通过增加副本的形式，提高容错性
某一个副本丢失以后，它可以自动恢复
```

适合处理大数据

```tex
数据规模：能够处理数据规模达到GB、TB、甚至PB级别的数据
文件规模：能够处理百万规模以上的文件数量，数量相当之大
```

可构建在廉价机器上，通过多副本机制，提高可靠性

+ 缺点

不适合低延时数据访问，比如毫秒级的存储数据，是做不到的

无法高效的对大量小文件进行存储

```tex
存储大量小文件的话，它会占用NameNode大量的内存来存储文件目录和块信息。这样是不可取的，因为NameNode的内存总和是有限的
小文件存储的寻址时间会超过读取时间，它违反了HDFS的设计目标
```

不支持并发写入、文件随机修改

```tex
一个文件只能有一个写，不允许多个线程同时写
仅支持数据append（追加），不支持文件的随机修改
```

## HDFS组成架构

1、NameNode(NN)：就是Master，它是一个主管，管理者

```tex
1、管理HDFS的名称空间
2、配置副本策略
3、管理数据块（Block）映射信息
4、处理客户端读写请求
```

2、DataNode：就是Slave。NameNode下达命令，DataNode执行实际的操作

```tex
1、存储实际的数据块
2、执行数据块时读/写操作
```

3、Client：就是客户端

```tex
1、文件切分。文件上传HDFS的时候，Client将文件切分成一个一个的Block，然后进行上传
2、与NameNode交互，获取文件的位置信息
3、与DataNode交互，读取或写入数据
4、Client提供一些命令来管理HDFS，比如NameNode格式化
5、Client可以通过一些命令来访问HDFS，比如对HDFS增删改查操作
```

4、Secondary NameNode：并非NameNode的热备。当NameNode挂掉的时候，它并不能马上替换NameNode并提供服务

```tex
1、辅助NameNode，分单其工作量，比如定期合并Fsmage和Edits，并推送给NameNode
2、在紧急情况下，可辅助恢复NameNode
```

## HDFS的SHELL操作

1、基本语法

```shell
hadoop fs 具体命令   OR     hdfs dfs 具体命令
两个是完全相同的
```

2、命令大全

**-help：输出这个命令参数**

```shell
hadoop fs -help rm
```

**-ls：显示目录信息**

```shell
hadoop fs -ls /
```

**-mkdir：在HDFS上创建目录，多级目录加  -p**

```shell
hadoop fs -mkdir -p /sanguo/shuguo
```

**-moveFromLocal：从本地剪切粘贴到HDFS**

```shell
touch kongming.txt
hadoop fs -moveFromLocal ./kongming.txt /sanguo/shuguo
```

**-appendToFile：追加一个文件到已经存在的文件末尾**

```shell
touch liubei.txt
vim liubei.txt
hadoop fs -appendToFile liubei.txt /sanguo/shuguo/kongming.txt
```

**-cat：显示文件内容**

```shell
hadoop fs -cat /sanguo/shuguo/kongming.txt
```

**-chgrp、-chmod、-chown：Linux文件系统中的用法一样，修改文件权限**

```shell
hadoop fs -chmod 666 /sanguo/shuguo/kongming.txt
hadoop fs -chown atguigu:atguigu /sanguo/shuguo/kongming.txt
```

**-copyFromLocal：从本地文件系统中拷贝文件到HDFS路径去，效果和 -put 一样**

```shell
hadoop fs -copyFromLocal README.txt /
```

**-copyToLocal：从HDFS拷贝到本地**

```shell
hadoop fs -copyToLocal /sanguo/shuguo/kongming.txt ./
```

**-cp：从HDFS的一个路径拷贝到HDFS的另一个路径**

```shell
hadoop fs -cp /sanguo/shuguo/kongming.txt /zhuge.txt
```

**-mv：在HDFS目录中移动文件**

```shell
hadoop fs -mv /zhuge.txt /sanguo/shuguo/
```

**-get：等同于copyToLocal，就是从HDFS下载文件到本地**

```shell
hadoop fs -get /sanguo/shuguo/kongming.txt
```

**-getmere：合并下载多个文件，比如HDFS的目录/user/atguigu/test下有多个文件log.1，log.2，log.3**

```shell
hadoop fs -getmerge /user/atguigu/text/* ./zaiyiqi.txt
```

**-put：等同于copyFromLocal**

```shell
hadoop fs -put ./zaiyiqi.txt /user/atguigu/test/
```

**-tail：显示一个文件的末尾**

```shell
hadoop fs -tail /sanguo/shuguo/kongming.txt
```

**-rm：删除文件或文件夹**

```shell
hadoop fs -rm /user/atguigu/test/jinlian2.txt
```

**-rmdir：删除空目录**

```shell
hadoop fs -mkdir /test
hadoop fs -rmdir /test
```

**-du：统计文件夹的大小信息**

```shell
hadoop fs -du -s -h /user/atguigui/test
```

**-setrep：设置HDFS中文件的副本数量**

```shell
hadoop fs -setrep 5 /README.txt
```

hadoop默认情况下开启了权限检查，切默认使用dir.who作为http访问的静态用户，因此可以通过关闭权限检查或配置http访问的静态用户为atguigu，二选一即可(推荐一)

+ 在core-site.xml中修改http访问的静态用户为atguigu

```xml
<property>
	<name>hadoop.http.staticuser.user</name>
    <value>atguigu</value>
</property>
```

+ 在hdfs-site.xml中关闭权限检查

```xml
<property>
	<name>dfs.permission.enabled</name>
    <value>false</value>
</property>
```

## HDFS客户端环境准备

1、把提供好的windows依赖复制到某个位置 例如：E:\hadoop\hadoop-3.1.0

2、配置环境变量

3、特殊情况：

+ 将windows依赖的hadoop.dll和winutils.exe文件复制到c:\windows\system32目录下

+ 可能windows缺少微软常用运行库
+ 重启电脑

创建Maven工程

导入相关依赖：

```xml
<dependencies>
    <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>4.12</version>
    </dependency>
    <dependency>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-slf4j-impl</artifactId>
        <version>2.12.0</version>
    </dependency>
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-client</artifactId>
        <version>3.1.3</version>
    </dependency>
</dependencies>
```

配置日志文件：log4j2.xml

```xml
<Configuration status="error" strict="true" name="XMLConfig">
    <Appenders>
        <!--类型名为Console，名称为必须属性-->
        <Appender type="Console" name="STDOUT">
            <!--布局为PatternLayout的方式，输出样式为：-->
            <Layout type="PatternLayout"
                    pattern="[%p] [%d{yyyy-MM-dd HH:mm:ss}][%c{10}]%m%n"/>
        </Appender>
    </Appenders>
    <Loggers>
        <!--可加性为false-->
        <Logger name="test" level="info" additivity="false">
            <AppenderRef ref="STDOUT"/>
        </Logger>
        <Root level="info">
            <AppenderRef ref="STDOUT"/>
        </Root>
    </Loggers>
</Configuration>
```

```java
public class TestHDFS {

    private FileSystem fs;
    private Configuration conf;
    private URI uri;
    private String user;

    @Before
    public void init() throws IOException, InterruptedException {
        uri = URI.create("hdfs://hadoop101:8020");
        conf = new Configuration();
        user = "atguigu";
        fs = FileSystem.get(uri, conf, user);
    }

    @After
    public void close() throws IOException {
        fs.close();
    }

    /**
     * 文件上传
     */
    @Test
    public void testUpload() throws IOException {
        fs.copyFromLocalFile(false, false, new Path("e:/test/hadoop.txt"), new Path("/testhdfs"));
    }

    /**
     * 文件下载
     */
    @Test
    public void testDownload() throws IOException {
        fs.copyToLocalFile(false,
                new Path("/bigdata0523/mengmeng.txt"),
                new Path("e:\\asource\\mengment.txt"),
                true);
    }

    /**
     * 文件的改名和移动
     */
    @Test
    public void testRename() throws IOException {
        //改名
        boolean b = fs.rename(new Path("/bigdata0523/mengmeng.txt"),
                new Path("/bigddata0523/dachangtui.txt"));
        //移动
        fs.rename(new Path("/bigdata0523/dachangtui.txt"),
                new Path("/mengment.txt"));
    }

    /**
     * 文件详情查看
     */
    @Test
    public void testListFiles() throws IOException {
        RemoteIterator<LocatedFileStatus> listFiles =
                fs.listFiles(new Path("/"), false);//true表示递归
        //迭代
        while (listFiles.hasNext()) {
            LocatedFileStatus fileStatus = listFiles.next();
            //获取文件的详情
            System.out.println("文件路径：" + fileStatus.getPath());
            System.out.println("文件权限：" + fileStatus.getPermission());
            System.out.println("文件主人：" + fileStatus.getOwner());
            System.out.println("文件组：" + fileStatus.getGroup());
            System.out.println("文件大小：" + fileStatus.getLen());
            System.out.println("文件副本数：" + fileStatus.getReplication());
            System.out.println("文件块大小：" + fileStatus.getBlockSize());
            System.out.println("文件块位置：" + Arrays.toString(fileStatus.getBlockLocations()));
            System.out.println("===================================");
        }
    }

    /**
     * 文件和文件夹判断
     */
    @Test
    public void testListStatus() throws IOException {
        FileStatus[] listStatus = fs.listStatus(new Path("/"));
        for (FileStatus status : listStatus) {
            if (status.isFile()) {
                System.out.println("File：" + status.getPath());
            } else {
                System.out.println("Dir：" + status.getPath());
            }
        }
    }

    /**
     * 文件、目录的删除
     */
    @Test
    public void testDelete() throws IOException {
        //删除文件，传true或false都可以
        boolean delete = fs.delete(new Path("/mengment.txt"), false);
        //删除目录，如果目录是空，则传true或false都可以，如果目录非空，则须传true进行递归删除
        boolean delete1 = fs.delete(new Path("/user"), false);
    }

    /**
     * 文件上传：基于IO流把数据从本地写到HDFS
     * 文件下载：基于IO流把数据从HDFS写到本地
     */
    @Test
    public void testIODownload() throws IOException {
        //待下载文件
        String srcFile = "/bigdata0523/qiangge.txt";
        //目标文件
        String destFile = "e:\\asource\\qiangge.txt";
        //输入流
        FSDataInputStream fis = fs.open(new Path(destFile));
        //输出流
        FileOutputStream fos = new FileOutputStream(new File(destFile));
        //流的拷贝
        IOUtils.copyBytes(fis, fos, conf);
        //关闭
        IOUtils.closeStream(fis);
        IOUtils.closeStream(fos);

    }

    /**
     * 把整个HDFS中的文件和目录全部都罗列出来
     */
    public void listAllFileAndDir(String path, FileSystem fs) throws IOException {
        //先获取指定Path下的所有的文件和目录
        FileStatus[] listStatus = fs.listStatus(new Path(path));
        //迭代listStatus数组，判断是文件还是目录
        for (FileStatus status : listStatus) {
            if (status.isFile()) {
                System.out.println("File：" + status.getPath().toString());
            } else {
                System.out.println("Dir：" + status.getPath().toString());
                //获取当前目录下的所有的文件和目录
                listAllFileAndDir(status.getPath().toString(), fs);
            }
        }
    }

    @Test
    public void testlistAllFileAndDir() throws IOException {
        listAllFileAndDir("/", fs);
    }

    @Test
    public void testIOUpload() throws IOException {
        //待上传文件
        String srcFile = "e:\\asource\\Hadoop从入门到精通.txt";
        //目标文件
        String destFile = "/Hadoop从入门到精通.txt";
        //输入流
        FileInputStream fis = new FileInputStream(new File(srcFile));
        //输出流
        FSDataOutputStream fos = fs.create(new Path(destFile));
        //流拷贝
//        int i;
//        byte[] buffer = new byte[1024];
//        while ((i = fis.read()) != -1) {
//            fos.write(buffer, 0, i);
//        }
        IOUtils.copyBytes(fis, fos, conf);
        //关闭流
        IOUtils.closeStream(fis);
        IOUtils.closeStream(fos);
    }

    /**
     * 参数的优先级：
     * xxx-default.xml < xxx-site.xml < IDEA中添加的xxx-site.xml < 在代码中通过Configuration对象设置
     */
    @Test
    public void testHDFS() throws InterruptedException, IOException {
        //1、创建文件系统对象
        URI uri = URI.create("hdfs://hadoop101:8020");
        Configuration conf = new Configuration();
//        conf.set("dfs.replication", "1");
        String user = "atguigu";
        FileSystem fs = FileSystem.get(uri,conf,user);
        System.out.println("fs=" + fs);
        //2、创建一个目录
        boolean b = fs.mkdirs(new Path("/testhdfs"));
        //3、关闭
        fs.close();
    }
}
```

## HDFS写数据流程

![image-20220806102958032](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\image-20220806102958032.png)

## HDFS读数据流程

![image-20220806105559842](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\image-20220806105559842.png)

## NameNode工作机制

![image-20220806111741539](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\image-20220806111741539.png)

oiv和oev查看Fsimage和edits文件

```shell
hdfs oiv -p 文件类型 -i 镜像文件 -o 转换后文件输出路径
```

**CheckPoint时间设置**

1、通常情况下，SecondaryNameNode每隔一小时执行一次

hdfs-default.xml

```xml
<property>
	<name>fs.namenode.checkpoint.period</name>
    <value>3600</value>
</property>
```

2、一分钟检查一次操作次数，当操作次数达到1百万时，SecondaryNameNode执行一次

```xml
<property>
	<name>dfs.namenode.checkpoint.txns</name>
    <value>1000000</value>
    <description>操作动作次数</description>
</property>
<property>
	<name>dfs.namenode.checkpoint.check.period</name>
    <value>60</value>
    <description>1分钟见检查一次操作次数</description>
</property>
```

NameNode故障后，可以采用如下两种方法恢复数据

1、方法一：将SecondaryNameNode中数据拷贝到NameNode存储数据的目录

2、方法二：使用-importCheckpoint选项启动NameNode守护进程，从而将SecondaryNameNode中数据拷贝到NameNode目录中。

## 集群安全模式

集群处于安全模式，不能 执行重要操作（写操作）。集群启动完成后，自动退出安全模式

```tex
bin/hdfs dfsadmin -safemode get		（功能描述：查看安全模式状态）
bin/hdfs dfsadmin -safemode enter	（功能描述：进入安全模式状态）
bin/hdfs dfsadmin -safemode leave	（功能描述：离开安全模式状态）
bin/hdfs dfsadmin -safemode wait	（功能描述：等待安全模式状态）
```

## DataNode工作机制

![image-20220806145916032](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\image-20220806145916032.png)

## MapReduce概述

```tex
MapReduce是一个分布式运算程序的编程框架，是用户开发“基于Hadoop的数据分析应用”的核心框架。

MapReduce核心功能是将用户编写的业务逻辑代码和自带默认组件整合成一个完整的分布式运算程序，并发运行在一个Hadoop集群上。
```

## MapReduce优缺点

```tex
优点：
1、MapReduce易于编程
它简单的实现一些接口，就可以完成一个分布式程序，这个分布式程序可以分布到大量廉价的PC机器上运行。也就是你写一个分布式程序，跟写一个简单的串行程序是一摸一样的。就是因为这个特点使得MapReduce编程变得非常流行
2、良好的扩展性
当你的计算资源不能得到满足的时候，你可以通过简单的增加机器来扩展它的计算能力
3、高容错性
MapReduce设计的初衷就是使程序能够部署在廉价的PC机器上，这就要求它具有很高的容错性。比如其中一台机器挂了，它可以把上面的计算任务转移到另外一个节点上运行，不至于这个任务运行失败，而且这个过程不需要人工参与，而完全是由Hadooop内部完成的
4、适合PB级以上海量数据的离线处理
可以实现上千台服务器集群并发工作，提供数据处理能力
缺点：
1、不擅长实时计算
MapReduce无法像MySQL一样，在毫秒或者秒级内返回结果
2、不擅长流式计算
流失计算的输入数据是动态的，而MapReduce的输入数据集是静态的，不能动态变化。这是因为MapReduce自身的设计特点决定了数据源必须是静态的
3、不擅长DAG（有向图）计算
多个应用程序存在依赖关系，后一个应用程序的输入为前一个的输出。在这种情况下，MapReduce并不是不能做，而是使用后，每个MapReduce作业的输出结果都会写入到磁盘，会造成大量的磁盘IO，导致性能非常的低下
```

## MapReduce核心编程思想

![image-20220807104846302](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\image-20220807104846302.png)

**MapReduce进程**

```tex
一个完整的MapReduce程序在分布式运行时有三类实例进程
（1）Mr AppMaster：负责整个程序的过程调度及状态协调
（2）MapTask：负责Map阶段的整个数据处理流程
（3）ReduceTask：负责Reduce阶段的整个数据处理流程
```

**MapReduce编程规范**

```tex
用户编写的程序分成三个部分：Mapper、Reduce和Driver
1、Mapper阶段
（1）用户自定义的Mapper要继承自己的父类
（2）Mapper的输入数据是KV对的形式（KV的类型可自定义）
（3）Mapper中的业务逻辑写在map()方法中
（4）Mapper的输出数据是KV对的形式（KV的类型可自定义）
（5）map()方法（MapTask进程）对每一个<K,V>调用一次
2、Reduce阶段
（1）用户自定义的Reduce要继承自己的父类
（2）Reduce的输入数据类型对应的Mapper的输出数据类型，也是KV
（3）Reduce的业务逻辑写在reduce()方法中
（4）ReduceTask进程对每一组相同K的<K,V>组调用一次reduce()方法
3、Driver阶段
相当于YARN集群的客户端，用于提交我们整个程序到YARN集群，提交的是封装了MapReduce程序相关运行参数的job对象
```

**WordCount案例实操**

（1）需求

在给定的文本文件中统计输出每一个单词出现的总次数

+ 输入数据

```tex
hello.txt
```

+ 期望输出数据

```tex
atguigu 2
banzhang 1
cls 2
hadoop 1
```

代码示例：

```java
public class WordCountDriver {

    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {
        //1、创建配置对象
        Configuration conf = new Configuration();
        //2、创建Job对象
        Job job = Job.getInstance(conf);
        //3、关联驱动类
        job.setJarByClass(WordCountDriver.class);
        //4、关联Mapper和Reducer
        job.setMapperClass(WordCountMapper.class);
        job.setReducerClass(WordCountReducer.class);
        //5、设置mapper输出的key和value类型
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);
        //6、设置最终输出的key和value的类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        //7、设置输入和输出路径
        FileInputFormat.setInputPaths(job, new Path("E:\\input\\inputWord"));
        FileOutputFormat.setOutputPath(job, new Path("E:\\output"));
        //8、提交Job
        job.waitForCompletion(true);
    }
}
```

```java
public class WordCountMapper extends Mapper<LongWritable, Text, Text, IntWritable> {

    //定义输出的k
    private Text outk = new Text();
    //定义输出的v
    private IntWritable outv = new IntWritable(1);
    /**
     * map方法是整个mr中map阶段的核心处理方法
     * @param key   表示偏移量
     * @param value 读取到一行数据
     * @param context   上下文对象，负责调度整个Mapper类中的方法的执行
     */
    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        //1、将读取到的一行数据从Text转回String（方便操作）
        String line = value.toString();
        //2、按照分隔符分割当前的数据
        String[] words = line.split(" ");
        //3、将words进行迭代处理，把迭代出的每个单词拼成kv写出
        for (String word : words) {
            outk.set(word);
            //写出
            context.write(outk, outv);
        }
    }
}
```

```java
public class WordCountReducer extends Reducer<Text, IntWritable, Text, IntWritable> {

    //定义输出的v
    private IntWritable outv = new IntWritable();

    /**
     * reduce方法是mr中reduce阶段的核心处理过程
     * 多个相同key的kv对，会组成一组kv，一组相同k的多个kv对会执行一次reduce方法
     * @param key   输入数据的key，表示一个单词
     * @param values    上下文对象，负责调度整个Reducer类中方法的执行
     * @param context
     */
    @Override
    protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
        //1、迭代values，取出每个values，进行汇总
        int sum = 0;
        for (IntWritable value : values) {
            sum += value.get();
        }
        //2、封装value
        outv.set(sum);
        //3、写出
        context.write(key, outv);
    }
```

## MapReduce框架原理

源码解读：

InputFormat数据输入

重要方法：

1、getSplits()：生成切片

 	createRecordReader()：创建RecordReader对象，负责数据的读取

2、子抽象类FileInputFormat

​	getSplits()：默认的切片规则的实现

​	isSplitable()：判断一个文件是否可切分，统一的实现，返回的是true

3、具体的实现类

​	TextInputFormat：是默认使用的InputFormat类

​	createRecordReader()：创建LineRecordReader对象

​	isSplitable()：重写了该方法，对各种压缩文件进行了判断是否可切分

​	切片的规则用的是FileInputFormat中的实现

​	CombineFileInputFormat：解决小文件场景生成过多切片的问题

## MapReduce工作流程

## Shuffle机制

Map方法之后，Reduce方法之前的数据处理过程称之为Shuffle。

shuffle具体划分：

map-->sort(map阶段)-->copy(reduce阶段)-->sort(reduce阶段)

-->reduce

![image-20220809230022737](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\image-20220809230022737.png)

默认的分区器：

HashPartitioner，分区的计算：根据key的hashcode值对reduce的个数取余操作得到分区号

分区与reduce个数的关系：

```java
NewOutputCollector(JobContext jobContext, JobConf job, TaskUmbilicalProtocol umbilical, TaskReporter reporter) throws IOException, ClassNotFoundException {
            this.collector = MapTask.this.createSortingCollector(job, reporter);
            this.partitions = jobContext.getNumReduceTasks();
            if (this.partitions > 1) {
                //如果reduce的个数大于1，会获取分区器对象，获取的过程是读取mapreduce.job.partitioner.class配置的值，如果配置有值，就使用该值指定的分区器，如果配置没值，就使用默认的HashPartitioner
                this.partitioner = (Partitioner)ReflectionUtils.newInstance(jobContext.getPartitionerClass(), job);
            } else {
                //如果reduce的个数不大于1，也意味着reduce的个数是默认的1个，此种情况不需要进行分区计算，所以直接返回的分区号是固定的0
                this.partitioner = new Partitioner<K, V>() {
                    public int getPartition(K key, V value, int numPartitions) {
                        return NewOutputCollector.this.partitions - 1;
                    }
                };
            }

        }
```

自定义分区器：

+ 自定义类继承Partitioner，重写getPartition()方法
+ 在job驱动中，设置自定义Partitioner：job.setPartitionerClass(CustomPartitioner.class)
+ 自定义Partition后，要根据自定义Partitioner的逻辑设置相应数量的ReduceTask：job.setNumReduceTask(5)

分区使用注意：

+ 分区号必须是从0开始，逐一累加
+ reduce个数设置：

​			如果设置为1，就算设置了分区类，最终还是只有一个分区

​			如果设置为1 < reduce个数 < 自定义分区器的实际分区数，会报错

​			如果设置为reduce个数 > 自定义分区器的实际分区数，会有空跑的Reduce，会浪费

## WritableComparable排序

排序是MapReduce框架中最重要的操作之一

排序分类：

1、部分排序

MapReduce根据输入记录的键对数据集排序，保证输出的每个文件内部有序

2、全排序

最终输出结果只有一个，且文件内部有序，实现方式是只设置一个ReduceTask。但该方法再处理大型文件时效率极低，因为一台机器处理所有文件，完全丧失了MapReduce所提供的并行架构

3、辅助排序

在Reduce端对key进行分组，应用于：在接收的key为bean对象时，想让一个或几个字段相同(全部字段比较不同)时的key进入统一个reduce方法时，可以采用分组排序

4、二次排序

在自定义排序过程中，如果compareTo中的判断条件为两个即为二次排序

编码实现比较：

+ 为key单独编写比较器对象 ，xxxWritableComparator，重写compare方法实现比较规则
+ 不为key编写比较器对象，hadoop会帮我们创建一个比较器对象，该比较器对象会调用到WritableComparable的compareTo方法，因此我们只需要让key对应的类实现WritableComparable接口，并实现compareTo方法，定义比较规则即可

**Combiner:**

Combiner的作用就是在每个MapTask中提前进行数据的汇总处理，减少数据的传输量，也降低Reducer处理的数据量

Combiner的父类是Reducer，但是Combiner是运行在MapTask中

**分组：**

在ReduceTaks中，相同key的多个kv对会分成一组，进入到一个reduce方法进行处理

hadoop如何确定key是否相同：比较

​		job.setGroupingComparatorClass();指定分组比较器

**总结：**分组比较时，会通过mapreduce.job.output.group.comparator.class参数获取对应的分组比较器，

如果能获取到，则使用，如果获取不到，则尝试通过mapreduce.job.output.key.comparator.class参数获取排序比较器，如果获取到，则使用，如果获取不到，则hadoop帮我们创建一个，并最终调用到key所在类的compareTo方法

**OutpPutFormat数据输出：**

重要方法：

getRecordWriter()：获取RecordWrite对象，负责数据的写出

chekcOutputSpecs()：检查输出路径

子抽象类：FileOutputFormat

checkOutputSpecs：默认实现

具体实现类：TextOutputFormat

默认使用的OutputFormat

通过LineRecordWriter负责数据的输出

**自定义OutputFormat**

+ 继承FileOutputFomrat类
+ 重写getRecordWriter方法
+ 自定义xxxRecordWriter类，继承RecordWriter类，重写write类

## Reduce Join

Map端的主要工作：为来自不同表或文件的key/value对，打标签以区别不同来源的记录。然后用连接字段作为key，其余部分和新加的标志作为value，最后进行输出

Reduce端的主要工作：在Reduce端以连接字段作为key的分组已经完成，我们只需要在每一个分组当中将那些来源于不同文件的记录在Map阶段已经大标志分开，最后进行合并就行了

## Map Join

Map Join适用于一张表十分小，一张表很大的场景

优点：

​		思考：在Reduce端处理过多的表，非常容易产生数据倾斜。怎么办？

​		在Map端缓存多张表，提前处理业务逻辑，这样增加Map端业务，减少Reduce端数据的压力，尽可能的减少数据倾斜

具体办法：采用DistributeCache

+ 在Mapper的setup阶段，将文件读取到缓存集合中
+ 在驱动函数中加载缓存（缓存普通文件到Task运行节点）job.addCacheFile(new URI("file:///e:cache/pd.txt"))

## Yarn资源调度器

Yarn是一个资源调度平台，负责为运算程序提供服务器运算资源，相当于一个分布式的操作系统平台，而MapReduce等运算程序则相当于运行于操作系统之上的应用程序

## Yarn基本架构

![image-20220815185855308](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\image-20220815185855308.png)

## Yarn工作机制

![image-20220815190521371](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\image-20220815190521371.png)

## MR源码解读

