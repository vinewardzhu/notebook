## 第 1 章 Kafka概述

### 1.1 定义 

**Kafka传统定义：**Kafka是一个分布式的基于发布/订阅模式的消息队列（Message Queue），主要应用于大数据实时处理领域。

**发布/订阅：**消息的发布者不会将消息直接发送给特定的订阅者，而是将发布的消息分为不同的类别，订阅者只接收感兴趣的消息。

**Kafka最新定义：**Kafka是一个开源的分布式事件流平台（Event Streaming Platform），被数千家公司用于高性能数据管道、流分析、数据集成和关键任务应用。

### 1.2 消息队列

​	目前企业中比较常见的消息队列产品主要有Kafka、ActiveMQ、RabbitMQ、RocketMQ等。

​	在大数据场景中主要采用Kafka作为消息队列。在JavaEE开发中主要采用ActiveMQ、RabbitMQ、RocketMQ。

#### 1.2.1 传统消息队列的应用场景

传统的消息队列的主要应用场景包括：缓存/消峰、解耦和异步通信。

​	**缓冲/消峰：**有助于控制和优化数据流经过系统的速度，解决生产消息和消费消息的处理速度不一致的情况。

​	**解耦：**允许你独立的扩展或修改两边的处理过程，只要确保它们遵守同样的接口约束。

​	**异步通信：**允许用户把一个消息放入队列，但并不立即处理它，然后在需要的时候再去处理它们。

#### 1.2.2 消息队列的两种模式

**1）点对点模式**

- 消费者主动拉取数据，消息收到后清除消息

**2）发布/订阅模式**

- 可以有多个topic主题（浏览、点赞、收藏、评论）

- 消费者消费数据后，不删除数据

- 每个消费者相互独立，都可以消费到数据

### 1.3 Kafka基础架构

![1675823892228](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\Kafka基础架构.png)

**（1）Producer：**消息生产者，就是向Kafka broker发消息的客户端。

**（2）Consumer：**消息消费者，向Kafka broker取消息的客户端。

## 第 2 章 Kafka快速入门

### 2.1 安装部署

#### 2.1.1 集群规划

| hadoop102 | hadoop103 | hadoop104 |
| --------- | --------- | --------- |
| zk        | zk        | zk        |
| kafka     | kafka     | kafka     |

#### 2.1.2 集群部署

1）官方下载地址：http://kafka.apache.org/downloads.html

2）解压安装包

```shell
[atguigu@hadoop102 software]$ tar -zxvf kafka_2.12-3.3.0.tgz -C /opt/module/
```

3）修改解压后的文件名称

```shell
[atguigu@hadoop102 module]$ mv kafka_2.12-3.0.0 /kafka
```

4）进入到/opt/module/kafka目录，修改配置文件

```shell
[atguigu@hadoop102 kafka]$ cd config/
[atguigu@hadoop102 config]$ vim server.properties
```

#### 2.1.3 集群启停脚本

```shell
#!/bin/bash
case $1 in
"start")
	for i in hadoop102 hadoop103 hadoop104
	do
		echo "--- 启动 $i kafka ---"
		ssh $i "/opt/module/bin/kafka-server-start.sh -daemon config/server.properties"
	done
;;
"stop")
	do
		echo "--- 停止 $i kafka ---"
		ssh $i "/opt/module/bin/kafka-server-stop.sh"
	done
;;
```

### 2.2 Kafka命令行操作

#### 2.2.1 主题命令行操作

1）查看操作主题命令参数

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-topic.sh
```

| 参数                                              | 描述                               |
| ------------------------------------------------- | ---------------------------------- |
| --bootstrap-server<String: server to connect to>  | 连接的Kafka Broker主机名称和端口号 |
| --topic<String topic>                             | 操作的topic名称                    |
| --create                                          | 创建主题                           |
| --delete                                          | 删除主题                           |
| --alter                                           | 修改主题                           |
| --list                                            | 查看所有主题                       |
| --describe                                        | 查看主题详细描述                   |
| --partitions<Integer: # of partitions>            | 设置分区数                         |
| --replication-factor<Integer: replication factor> | 设置分区副本数                     |
| --config<String: name=value>                      | 更新系统默认的配置                 |

2）查看当前服务器中的所有topic

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-topics.sh --bootstrap-server hadoop102:9092,hadoop103:9092 --list
```

3）创建first topic

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-topics.sh --bootstrap-server hadoop102:9092 --topic first --create --partitions 1 --replication-factor 3
```

#### 2.2.2 生产者命令行操作

#### 2.2.3 消费者命令行操作

## 第 3 章 Kafka生产者

### 3.1 生产者消息

#### 3.1.1 发送原理

​	在消息发送的过程中，涉及到了两个线程——main线程和Sender线程。在main线程中创建了一个双端对列RecordAccumulator。main线程将消息发送给RecordAccumulator，Sender线程不断从RecordAccumulator中拉取消息发送到Kafka Broker。

**发送流程：**

![1675833729917](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\Producer发送流程.png)

#### 3.1.2 生产者重要参数列表

| 参数名称          | 描述                                     |
| ----------------- | ---------------------------------------- |
| bootstrap.servers | 生产者链接集群所需的broker地址清单。例如 |
|                   |                                          |
|                   |                                          |



### 3.2 异步发送API

#### 3.2.1 普通异步发送

1）需求：创建Kafka生产者，采用异步的方式发送到Kafka Broker

2）代码编写

​	（1）创建工程

​	（2）导入依赖

```xml
<dependencies>
	<dependency>
    	<groupId>org.apache.kafka</groupId>
        <artifactId>kafka-clients</artifactId>
        <version>3.0.0</version>
   	</dependency>
</dependencies>
```

​	（3）创建包名：com.atguigu.kafka.producer

​	（4）编写不带回调函数的API代码

```java
package com.atguigu.kafka.producer;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

/**
 * @Author: VinEwardZhu
 * @CreateTime: 2023-02-08 14:24
 * @Version: 1.0
 */
public class CustomProducer {
    public static void main(String[] args) {
        //0.配置
        Properties properties = new Properties();
        //连接集群 bootstrap.servers
        properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "hadoop102:9092,hadoop103:9092");
        //指定对应的key和value的序列化类型 key.serializer
//        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");
        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        //1.创建kafka生产者对象
        KafkaProducer<String, String> kafkaProducer = new KafkaProducer<>(properties);
        //2.发送数据
        for (int i = 0; i < 5; i++) {
            kafkaProducer.send(new ProducerRecord<>("first", "atguigu" + i));
        }
        //3.关闭资源
        kafkaProducer.close();
    }
}
```

#### 3.2.2 带回调函数的异步发送

​	回调函数会在producer收到ack时调用，为异步调用，该方法有两个参数，分别是元数据信息（RecordMetadata）和异常信息（Exception），如果Exception为null，说明消息发送成功，如果Exception不为null，说明消息发送失败。

```java
package com.atguigu.kafka.producer;

import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

/**
 * @Author: VinEwardZhu
 * @CreateTime: 2023-02-08 14:42
 * @Version: 1.0
 */
public class CustomProducerCallback {
    public static void main(String[] args) {
        //0.配置
        Properties properties = new Properties();
        //连接集群 bootstrap.servers
        properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "hadoop102:9092,hadoop103:9092");
        //指定对应的key和value的序列化类型 key.serializer
//        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");
        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        //1.创建kafka生产者对象
        KafkaProducer<String, String> kafkaProducer = new KafkaProducer<>(properties);
        //2.发送数据
        for (int i = 0; i < 5; i++) {
            kafkaProducer.send(new ProducerRecord<>("first", "atguigu" + i), new Callback() {
                @Override
                public void onCompletion(RecordMetadata metadata, Exception exception) {
                    if (exception == null) {
                        System.out.println("主题：" + metadata.topic() + " 分区：" + metadata.partition());
                    }
                }
            });
        }
        //3.关闭资源
        kafkaProducer.close();
    }
}
```

### 3.3 同步发送API

```java
package com.atguigu.kafka.producer;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;
import java.util.concurrent.ExecutionException;

/**
 * @Author: VinEwardZhu
 * @CreateTime: 2023-02-08 14:58
 * @Version: 1.0
 */
public class CustomProducerSync {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        //0.配置
        Properties properties = new Properties();
        //连接集群 bootstrap.servers
        properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "hadoop102:9092,hadoop103:9092");
        //指定对应的key和value的序列化类型 key.serializer
//        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");
        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        //1.创建kafka生产者对象
        KafkaProducer<String, String> kafkaProducer = new KafkaProducer<>(properties);
        //2.发送数据
        for (int i = 0; i < 5; i++) {
            kafkaProducer.send(new ProducerRecord<>("first", "atguigu" + i)).get();
        }
        //3.关闭资源
        kafkaProducer.close();
    }
}
```

只需要在异步发送的基础上，再调用一下get()方法即可。

### 3.4 生产者分区

#### 3.4.1 分区好处

（1）便于合理使用存储资源，每个partition在一个Broker上存储，可以把海量的数据按照分区切割成一块一块数据存储在多台Broker上。合理控制分区的任务，可以实现负载均衡的效果。

（2）提高并行度，生产者可以以分区为单位发送数据；消费者可以以分区为单位进行消费数据。

#### 3.4.2 生产者发送消息的区分策略

1）默认的分区器DefaultPartitoiner

​	在IDEA中ctrl + n，全局查找DefaultPartitioner

```java
public class DefaultPartitioner implements Partitioner {
    
}
```

在IDEA中全局查找（ctrl + n）ProducerRecord类，在类中可以看到如下构造方法：

```java
/**
 *（1）指明partition的情况下，直接将指明的值作为partition值；例如partition=0，所有数据写入分区
 *（2）没有指明partition值但有key的情况下，将key的hash值与topic的partition数进行取余得到partitioni值；
 * 例如：key1的hash值=5，key2的hash值=6，topic的partition数=2，那么key1对应的value1写入1号分区，key2对应的value2写入0号分区
 *（3）既没有partition值又没有key值的情况下，Kafka采用Sticky Partition（黏性分区器），会随机选择一个分区，并尽可能一直使用该分区，待该分区的batch已满或者已完成，Kafka再随机一个分区进行使用（和上一次的分区不同）。
 * 例如：第一次随机选择0号分区，等0号分区当前批次满了（默认16k）或者linger.ms设置的时间到了，Kafka再随机一个分区进行使用（如果还是0会继续随机）
 */
public ProducerRecord(String topic, Integer partition, Long timestamp, K key, V value, Iterable<Header> headers) {
        
    }

    public ProducerRecord(String topic, Integer partition, Long timestamp, K key, V value) {
        
    }

    public ProducerRecord(String topic, Integer partition, K key, V value, Iterable<Header> headers) {
        
    }

    public ProducerRecord(String topic, Integer partition, K key, V value) {
        
    }

    public ProducerRecord(String topic, K key, V value) {
        
    }

    public ProducerRecord(String topic, V value) {
        
    }
```

#### 3.4.3 自定义分区器

如果研发人员可以根据企业需求，自己重新实现分区器

1）需求

​	例如我们实现一个分区器，实现发送过来的数据中如果包含atguigu，就发往0号分区，不包含atguigu，就发往1号分区

2）实现步骤

​	（1）定义类实现Partitioner接口

​	（2）重写partition()方法

```java
package com.atguigu.kafka.producer;

import org.apache.kafka.clients.producer.Partitioner;
import org.apache.kafka.common.Cluster;

import java.util.Map;

/**
 * @Author: VinEwardZhu
 * @CreateTime: 2023-02-08 16:23
 * @Version: 1.0
 */
//properties.put(ProducerConfig.PARTITIONER_CLASS_CONFIG,"com.atguigu.kafka.producer.MyPartitioner");关联自定义分区器
public class MyPartitioner implements Partitioner {

    @Override
    public int partition(String topic, Object key, byte[] keyBytes, Object value, byte[] valueBytes, Cluster cluster) {
        //获取数据
        String msgValue = value.toString();
        int partition;
        if (msgValue.contains("atguigu")) {
            partition = 0;
        } else {
            partition = 1;
        }
        return partition;
    }

    @Override
    public void close() {

    }

    @Override
    public void configure(Map<String, ?> map) {

    }
}
```

### 3.5 生产经验——生产者如何提高吞吐量

![1675845947646](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\Producer提高吞吐量.png)

```java
package com.atguigu.kafka.producer;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.protocol.types.Field;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

/**
 * @Author: VinEwardZhu
 * @CreateTime: 2023-02-08 16:47
 * @Version: 1.0
 */
public class CustomProducerParameters {
    public static void main(String[] args) {
        //0.配置
        Properties properties = new Properties();
        //连接kafka集群
        properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "hadoop102:9092, hadoop102:9092");
        //序列化
        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        //缓冲区大小
        properties.put(ProducerConfig.BUFFER_MEMORY_CONFIG, 33554432);
        //批次大小
        properties.put(ProducerConfig.BATCH_SIZE_CONFIG, 16384);
        //linger.ms
        properties.put(ProducerConfig.LINGER_MS_CONFIG, 1);
        //压缩
        properties.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy");
        //1.创建生产者
        KafkaProducer<String, String> kafkaProducer = new KafkaProducer<String, String>(properties);
        //2.发送数据
        for (int i = 0; i < 5; i++) {
            kafkaProducer.send(new ProducerRecord<>("first", "atguigu" + i));
        }
        //3.关闭资源
        kafkaProducer.close();
    }
}
```

### 3.6 生产经验——数据可靠性

1）ack应答原理

![1675848041010](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\acks应答原理.png)

![1675848264114](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\数据可靠性分析.png)

**可靠性总结：**

​	acks=0，生产者发送过来数据就不管了，可靠性差，效率高；

​	akcs=1，生产者发送过来数据Leader应答，可靠性中等，效率中等；

​	acks=-1，生产者发送过来数据Leader和ISR队列里面所有Follower应答，可靠性高，效率低；

在生产环境中，acks=0很少使用；acks=1，一般用于传输普通日志，允许丢个别数据；acks=-1，一般用于传输和钱相关的数据，对可靠性要求比较高的场景。

**数据重复分析：**

acks：-1（all）：生产者发送过来的数据，Leader和ISR队列里面的所有节点收齐数据后应答。

![1675847618822](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\数据重复分析.png)

代码配置：

```java
//acks
properties.put(ProducerConfig.ACKS_CONFIG, "1");
//重试次数
properties.put(ProducerConfig.RETRIES_CONFIG, 3);
```

### 3.7 生产经验——数据去重

#### 3.7.1 数据传递语义

- 至少一次（At Least Once）= ACK级别设置为-1 + 分区副本大于等于2 + ISR里应答的最小副本数量大于等于2

- 最多一次（At Most Once）= ACK级别设置为0

- 总结：

  At Least Once可以保证数据不丢失，但是不能保证数据不重复

  At Most Once可以保证数据不重复，但是不能保证数据不丢失

- 精确一次（Exactly Once）：对于一些非常重要的信息，比如和钱相关的数据，要求数据既不能重复也不丢失。Kafka0.11版本后，引入一项重大特性：幂等性和事务。

#### 3.7.2 幂等性

1）幂等性原理

幂等性就是指Producer不论向Broker发送多少次重复数据，Broker端都只会持久化一条，保证了不重复。

精确一次（Exactly Once）= 幂等性 + 至少一次（ack=-1 + 分区副本数>=2 + ISR最小副本数量>=2）.

重复数据的判断标准：具有<PID，Partition，SeqNumber>相同主键的消息提交时，Broker只会持久化一条。其中PID是Kafka每次重启都会分配一个新的；Partition表示分区号；Sequence Number是单调自增的。

所以幂等性只能保证的是在单分区单会话内不重复。

![1675853488105](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\幂等性.png)

2）如何使用幂等性

​	开启参数enable.idempotence默认为true，false关闭

#### 3.7.3 生产者事务

说明：开启事务，必须开启幂等性

```java
package com.atguigu.kafka.producer;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

/**
 * @Author: VinEwardZhu
 * @CreateTime: 2023-02-08 19:00
 * @Version: 1.0
 */
public class CustomProducerTranactions {
    public static void main(String[] args) {
        //0.配置
        Properties properties = new Properties();
        //连接kafka集群
        properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "hadoop102:9092, hadoop102:9092");
        //序列化
        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        //指定事务id
        properties.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "tranactional_id_01");
        //1.创建生产者
        KafkaProducer<String, String> kafkaProducer = new KafkaProducer<String, String>(properties);
        kafkaProducer.initTransactions();
        kafkaProducer.beginTransaction();
        try {
            //2.发送数据
            for (int i = 0; i < 5; i++) {
                kafkaProducer.send(new ProducerRecord<>("first", "atguigu" + i));
            }
            int i = 1 / 0;
        } catch (Exception e) {
            kafkaProducer.abortTransaction();
        } finally {
            //3.关闭资源
            kafkaProducer.close();
        }
    }
}
```

### 3.8 生产经验——数据有序

![1675855621632](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\数据有序.png)

### 3.9 生产经验——数据乱序

1）kafka在1.x版本之前保证数据单分区有序，条件如下：

​	max.in.flight.requests.per.connection=1(不需要考虑是否开启幂等性)

2）kafka在1.x及以后版本保证数据单分区有序，条件如下：

​	（1）未开启幂等性

​		max.in.flight.requests.per.connection需要设置为1

​	（2）开启幂等性

​		max.in.flight.requests.per.connection需要设置小于等于5

​		原因说明：因为在kafka 1.x以后，启用幂等后，kafka服务端会缓存producer发来的最近5个request的元数据，故无论如何，都可以保证最近5个request的数据都是有序的

![1675856205080](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\数据乱序.png)

## 第 4 章 Kafka Broker

### 4.1 Kafka Broker工作流程

#### 	4.1.1 Zookeeper存储的Kafka信息

​	（1）启动Zookeeper客户端

```shell
[atguigu@hadoop102 zookeeper-3.5.7]$ bin/zkCli.sh
```

​	（2）通过ls命令可以查看kafka相关信息

```shell
[zk: localhost:2181(CONNECTED) 2] ls /kafka
```

![1675857452952](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\Zookeeper存储的Kafka信息.png)

#### 	4.1.2 Kafka Broker总体工作流程

![1675857850769](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\Kafka总体工作流程.png)

1）模拟Kafka上下线，Zookeeper中数据变化

​	（1）查看/kafka/brokers/ids路径上的节点

```shell
[zk: localhost:2181(CONNECTED) 2] ls /kafka/brokers/ids
[0, 1, 2]
```

​	（2）查看/kafka/controller路径上的数据

```shell
[zk: localhost:2181(CONNECTED) 15] get /kafka/controller
{"version":1, "brokerid":0, timestamp: "1637292471777"}
```

​	（3）查看/kafka/brokers/topics/first/partitions/0/state路径上的数据

```shell

```

#### 	4.1.3 Broker重要参数

### 4.2 生产经验——节点服役和退役

#### 	4.2.1 服役新节点

​	1）新节点准备

​		（1）关闭hadoop104，并右键执行克隆操作

​		（2）开启hadoop105，并修改IP地址

```shell
[root@hadoop104 ~]# vim /etc/sysconfig/network-scripts/ifcfg-ens33
DEVICE=ens33
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
NAME="ens33"
IPADDR=192.168.10.2
```

​		（3）在hadoop105上，修改主机名称为hadoop105

```shell
[root@hadoop104 ~]# vim /etc/hostname
hadoop105
```

​		（4）重新启动hadoop104、hadoop105

​		（5）修改hadoop105中kafka的broker.id为3

​		（6）删除hadoop105中kafka下的datas和logs

```shell
[atguigu@hadoop105 kafka]$ rm -rf datas/* logs/*
```

​		（7）启动hadoop102、hadoop103、hadoop104上的kafka集群

```shell
[atguigu@hadoop102 ~]$ zk.sh start
[atguigu@hadoop102 ~]$ kf.sh start
```

​		（8）单独启动hadoop105中的kafka

```shell
[atguigu@hadoop105 kafka]$ bin/kafka-server-start.sh -daemon ./config/server.properties
```

​	2）执行负载均衡操作

​		（1）创建一个要均衡的主题

```shell
[agtuigu@hadoop102 kafka]$ vim topics-to-move.json
{
    topics: [
        {"topic": "first"}
    ],
    "version": 1
}
```

​		（2）生成一个负载均衡的计划

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-reassign-partitions.sh --bootstrap-server hadoop102:9092 --topics-to-move-json-file topics-to-move.json --broker-list "0, 1, 2, 3" --generate
```

​		（3）创建副本存储计划（所有副本存存储在broker0、broker1、broker2、broker3中）

```shell
[atguigu@hadoop102 kafka]$ vim increase-replication-factor.json
```

内容如下：

![1675936258826](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\1675936258826.png)

​		（4）执行副本存储计划

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-reassign-partitions.sh --bootstrap-server hadoop102:9092 --reassignment-json-file increase-replication-factor.json --execute
```

​		（5）验证副本存储计划

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-reassign-partitions.sh --bootstrap-server hadoop102:9092 --reassignment-json-file increase-replication-factor.json --verify
```

#### 	4.2.2 退役旧节点

1）执行负载均衡操作

​	先按照退役一台节点，生成执行计划，然后按照服役时操作流程执行负载均衡。

​	（1）创建一个要均衡的主题

```shell
[atguigu@hadoop102 kafka]$ vim topics-to-move.json
{
    "topics": [
        {"topic": "first"}
    ],
    "version": 1
}
```

​	（2）创建执行计划

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-reassign-partitions.sh --bootstrap-server hadoop102:9092 --topics-to-move-json-file topics-to-move.json --broker-list "0, 1, 2" --generate
```

​	（3）创建副本存储计划（所有副本存储在broker0， broker1， broker2中）

```shell
[atguigu@hadoop102 kafka]$ vim increase-replication-factor.json
```

内容如下：

![1675937129963](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\1675937129963.png)

​	（4）执行副本存储计划

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-reassign-partitions.sh --bootstrap-server hadoop102:9092 --reassignment-json-file increase-replication-factor.json --execute
```

​	（5）验证副本存储计划

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-reassign-partitions.sh --bootstrap-server hadoop102:9092 --reassignment-json-file increase-replication-factor.json --verify
```

2）执行停止命令

​	在hadoop105上执行停止命令即可

```shell
[atguigu@hadoop105 kafka]$ bin/kafka-server-stop.sh
```

### 4.3 Kafka副本

#### 	4.3.1 副本基本信息

​	（1）Kafka副本作用：提高数据可靠性

​	（2）Kafka默认副本1个，生产环境一般配置为2个，保证数据可靠性；太多副本会增加磁盘存储空间，增加网络上数据传输，降低效率。

​	（3）Kafka中副本分为：Leader和Follower。Kafka生产者只会把数据发往Leader，然后Follower找Leader进行同步数据。

​	（4）Kafka分区中的所有副本统称为AR（Assigned Repllicas）AR = ISR + OSR

ISR，表示和Leader保持同步的Follower集合。如果Follower长时间未向Leader发送通信请求或同步数据，则该Follower将被踢出ISR。该时间阈值由replica.lag.time.max.ms参数设定，默认30s。Leader发生故障之后，就会从ISR中选举新的Leader。

OSR，表示Follower与Leader副本同步时，延迟过多的副本

#### 	4.3.2 Leader选举流程

​	Kafka集群中有一个broker的Controller会被选举为Controller Leader，负责管理集群broker的上下线，所有topic的分区副本分配和Leader选举等工作。

​	Controller的信息同步工作是依赖于Zookeeper的。

![1675940427079](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\Leader选举流程.png)

（1）创建一个新的topic，4个分区，4个副本

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-topics.sh --bootstrap-server hadoop102:9092 --create --topic atguigu --partitions 4 --replication-factor 4
```

（2）查看Leader分布情况

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-topics.sh --bootstrap-server hadoop102:9092 --describe --topic atguigu
```

（3）停止掉hadoop105的kafka进程，并查看Leader分区情况

```shell
[atguigu@hadoop105 kafka]$ bin/kafka-server-stop.sh

[atguigu@hadoop102 kafka]$ bin/kafka-topics.sh --bootstrap-server hadoop102:9092 --describe --topic atguigu
```

#### 	4.3.3 Leader和Follower故障处理细节

![1675941342344](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\Follower故障处理细节.png)

![1675941525434](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\Leader故障处理细节.png)

#### 	4.3.4 分区副本分配

​	如果Kafka服务器只有4个节点，那么设置Kafka的分区数大于服务器台数，在Kafka底层如何分配存储副本呢？

1）创建16分区，3个副本

​	（1）创建一个新的topic，名称为second

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-topics.sh --bootstrap-server hadoop102:9092 --create --partitions 16 --replication-factor 3 --topic second
```

​	（2）查看分区副本情况

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-topics.sh --bootstrap-server hadoop102:9092 --describe --topic second
```

#### 	4.3.5 生产经验——手动调整分区副本存储

​	在生产环境中，每台服务器的配置和性能不一致，但是Kafka只会根据自己的代码规则创建对应的分区副本，就会导致个别服务器存储压力大。所有需要手动调整分区副本的存储。

​	需求：创建一个新的topic，4个分区，两个副本，名称为three。将该topic的所有副本都存储到broker0和broker1两台服务器上。

手动调整分区副本存储的步骤如下：

（1）创建一个新的topic，名称为three

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-topics.sh --bootstrap-server hadoop102:9092 --create --partitions 4 --replication-factor 2 --topic three
```

（2）查看分区副本存储情况

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-topics.sh --bootstrap-server hadoop102:9092 --describe --topic --three
```

（3）创建副本存储计划

（4）执行副本存储计划

（5）验证副本存储计划

（6）查看分区副本存储情况

#### 	4.3.6 生产经验——Leader Partition负载平衡

![1675944049234](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\Leader Partition自动平衡.png)

#### 	4.3.7 生产经验——增加副本因子

​	在生产环境中由于某个主题的重要等级需要提升，我们需要考虑增加副本。副本数的增加需要先制定计划，然后根据计划执行。

1）创建topic

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-topics.sh --bootstrap-server hadoop102:9092 --create --partitions 3 --replication-factor 1 --topic four
```

2）手动增加副本存储

​	（1）创建副本存储计划（所有副本都指定存储在broker0、broker1、broker2中）

```shell
[atguigu@hadoop102 kafka]$ vim increase-replication-factor.json
```

​	（2）执行副本存储计划

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-reassign-partitions.sh --bootstrap-server hadoop102:9092 --reassignment-json-file increase-replication-factor.json --execute
```

### 4.4 文件存储

#### 	4.4.1 文件存储机制

![1675945708496](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\Kafka文件存储机制.png)

![1675946037655](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\Log文件和Index文件.png)

#### 	4.4.2 文件清理策略

Kafka中默认的日志保存时间为7天，可以通过调整如下参数修改保存时间

​	log.retention.hours，最低优先级小时，默认7天

​	log.retention.minutes，分钟

​	log.retention.ms，最高优先级毫秒

​	log.retention.check.interval.ms，负责设置检查周期，默认5分钟

那么日志一旦超过了设置的时间，怎么处理呢？

Kafka中提供的日志清理策略有delete和compact两种

1）delete日志删除：将过期数据删除

​	log.cleanup.policy = delete 所有数据启用删除策略

​	（1）基于时间：默认打开。以segment中所有记录中的最大时间戳作为该文件时间戳。

​	（2）基于大小：默认关闭。超过设置的所有日志总大小，删除最早的segment

​		log.retention.bytes，默认等于-1，表示无穷大。

思考：如果一个segment中有一部分数据过期，一部分没有过期，怎么处理？

2）compact日志压缩

​	compact日志压缩：对于相同key的不同value值，只保留最后一个版本。

​		log.cleanup.policy = compact	所有数据启用压缩策略

​	压缩后的offset可能是不连续的，当从这些offset消费消息时，将会拿到比这个offset大的offset对应的消息，实际上会拿到offset为7的消息，并从这个位置开始消费。

​	**这种策略只适合特殊场景，比如消息的key是用户ID，value是用户的资料，通过这种压缩策略，整个消息集里就保存了所有用户最新的资料。**

### 4.5 高效读写数据

1）Kafka本身是分布式集群，可以采用分区技术，并行度高

2）读数据采用稀疏索引，可以快速定位要消费的数据

3）顺序写磁盘

​	Kafka的producer生产数据，要写入到log文件中，写的过程是一直追加到文件末端，为顺序写。官网有数据表明，同样的磁盘，顺序写能到600M/s，而随机写只有100K/s。者与磁盘的机械机构有关，顺序写之所以快，是因为其省去了大量磁头寻址的时间。

4）页缓存 + 零拷贝技术

​	**零拷贝：**Kafka的数据加工处理操作交由Kafka生产者和Kafka消费者处理。Kafka Broker应用层不关心存储的数据，所以就不用走应用层，传输效率高。

​	**PageCache页缓存：**Kafka重度依赖底层操作系统提供的PageCache功能。当上层有写操作时，操作系统只是将数据写入PageCache。当读操作发生时，先从PageCache中查找，如果找不到，再去磁盘中读取。实际上PageCache是把尽可能多的空闲内存都当作了磁盘缓存来使用。

## 第 5 章 Kafka消费者

### 5.1 Kafka消费方式

![1676025256267](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\Kafka消费方式.png)

### 5.2 Kafka消费者工作流程

#### 5.2.1 消费者总体工作流程

![1676024424915](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\消费者总体工作流程.png)

#### 5.2.2 消费着组原理

Consumer Group（CG）：消费者组，由多个consumer组成。形成一个消费者组的条件，是所有消费者的groupid相同。

+ 消费者组内每个消费者负责消费不同分区的数据，一个分区只能由一个组内消费者消费
+ 消费者组之间互不影响。所有的消费者都属于某个消费者组，即消费者组是逻辑上的一个订阅者。

![1676024424915](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\消费者组初始化流程.png)

![1676026119449](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\消费者组消费流程.png)

#### 5.2.3 消费者重要参数



### 5.3 消费者API

#### 5.3.1 独立消费者案例（订阅主题）

1）需求：

​	创建一个独立消费者，消费first主题中数据

注意：在消费者API代码中必须配置消费者组id。命令行启动消费者不填写消费者组id会被自动填写随机的消费者组id。

2）实现步骤

​	（1）创建包名：com.atguigu.kafka.consumer

​	（2）编写代码

```java
package com.atguigu.kafka.consumer;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Properties;

/**
 * @Author: VinEwardZhu
 * @CreateTime: 2023-02-10 19:01
 * @Version: 1.0
 */
public class CustomConsumer {
    public static void main(String[] args) {
        //0.配置
        Properties properties = new Properties();
        //连接
        properties.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "hadoop102:9092, hadoop103:9092");
        //反序列化
        properties.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        //配置消费者组id
        properties.put(ConsumerConfig.GROUP_ID_CONFIG, "test");
        //1.创建一个消费者
        KafkaConsumer<String, String> kafkaConsumer = new KafkaConsumer<>(properties);
        //2.订阅主题
        ArrayList<String> topics = new ArrayList<>();
        topics.add("first");
        kafkaConsumer.subscribe(topics);
        //3.消费数据
        while (true) {
            ConsumerRecords<String, String> consumerRecords = kafkaConsumer.poll(Duration.ofSeconds(1));
            for (ConsumerRecord<String, String> consumerRecord : consumerRecords) {
                System.out.println(consumerRecord);
            }
        }
    }
}
```

​	（3）在IDEA控制台观察接收到的数据

#### 5.3.2 独立消费者案例（订阅分区）

1）需求：创建一个独立消费者，消费first主题0号分区的数据

2）实现步骤

​	（1）代码编写

```java
package com.atguigu.kafka.consumer;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Properties;

/**
 * @Author: VinEwardZhu
 * @CreateTime: 2023-02-10 20:10
 * @Version: 1.0
 */
public class CustomConsumerPartition {
    public static void main(String[] args) {
        //0.配置
        Properties properties = new Properties();
        //连接
        properties.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "hadoop102:9092, hadoop103:9092");
        //反序列化
        properties.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        //组id
        properties.put(ConsumerConfig.GROUP_ID_CONFIG, "test");
        //1.创建一个消费者
        KafkaConsumer<String, String> kafkaConsumer = new KafkaConsumer<>(properties);
        //2.订阅主题对应的分区
        ArrayList<TopicPartition> topicPartitions = new ArrayList<>();
        topicPartitions.add(new TopicPartition("first", 0));
        kafkaConsumer.assign(topicPartitions);
        //3.消费数据
        while (true) {
            ConsumerRecords<String, String> consumerRecords = kafkaConsumer.poll(Duration.ofSeconds(1));
            for (ConsumerRecord<String, String> consumerRecord : consumerRecords) {
                System.out.println(consumerRecord);
            }
        }
    }
}
```

#### 5.3.3 消费者组案例

1）需求：测试同一个主题的分区数据，只能由一个消费者组中的一个消费

2）实例实操

​	（1）复制一份基础消费者的代码，在IDEA中同时启动，即可启动同一个消费者组中的两个消费者

### 5.4 生产经验——分区的分配以及再平衡

#### 5.4.1 Range以及再平衡

![1676032432191](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\分配分区策略之Range.png)

#### 5.4.2 RoundRobin以及再平衡

![1676032968108](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\分配分区策略之RoundRobin.png)

消费者修改分区分配策略：

```java
//设置分区分配策略
properties.put(ConsumerConfig.PARTITION_ASSIGNMENT_STRATEGY_CONFIG,"org.apache.kafka.clients.consumer.RoundRobinAssignor");
```

#### 5.4.3 Sticky以及再平衡

​	粘性分区定义：可以理解维分配的结果带有"粘性的"。即在执行一次新的分配之前，考虑上一次分配的结果，尽量少的调整分配的变动，可以节省大量的开销。

​	粘性分区是Kafka0.11x版本开始引入这种分配策略，首先会尽量均衡的放置分区到消费者上面，在出现同一消费者组内消费者出现问题的时候，会尽量保持原有分配的分区不变化。

1）需求：设置主题为first，7个分区；准备3个消费者，采用粘性分区策略，并进行消费，观察消费分配情况。然后再停止其中一个消费者，再次观察消费分配情况

2）步骤

​	（1）修改分区分配策略为粘性

​	注意：3个消费者都应该注释掉，之后重启3个消费者，如果出现报错，全部停止等会再重启，或者修改为全新的消费者组

### 5.5 offset位移

#### 5.5.1 offset的默认维护位置

_consumer_offsets主题里面采用key和value的方式存储数据。key是group.id+topic+分区号，value就是当前offset的值。每隔一段时间，kafka内部会对这个topic进行compact，也就是每个group.id+topic+分区号就保留最新数据。

1）消费offset案例

​	（0）思想：_consumer_offsets为Kafka中的topic，那就可以通过消费者进行消费

​	（1）在配置文件config/consumer.properties中添加配置exclude.internal.topics=false，默认是true，表示不能消费系统主题。为了查看该系统主题数据，所以该参数修改为false。

​	（2）采用命令行方式，创建一个新的topic

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-topics.sh --bootstrap-server hadoop102:9092 --create --topic atguigu --partitions 2 --replication-factor 2
```

​	（3）启动生产者往atguigu生产数据

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-console-producer.sh --topic atguigu --bootstrap-server hadoop102:9092
```

​	（4）启动消费者消费atguigu数据

```shell
[atguigu@hadoop102 kafka]$ bin/kafka-console-consumer.sh --bootstrap-server hadoop102:9092 --topic atguigu --group test
```

注意：指定消费者组名称，更好观察数据存储位置（key是group.id+topic+分区号）。

​	（5）查看消费者消费主题_consumer_offsets

```shell
[atguigu@hadoop102:9092 kafka]$ bin/kafka-console-consumer.sh --topic _consumer_offsets --bootstrap_server hadoop102:9092 --consumer.config config/consumer.properties --formatter "kafka.coordinator.group.GroupMetadataManager\$OffsetsMessageFormatter" --from-beginning
```

#### 5.5.2 自动提交offset

![1676289688320](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\自动提交offset.png)

#### 5.5.3 手动提交offset

​	![1676290184468](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\手动提交offset.png)

#### 5.5.4 指定offset消费

```java
package com.atguigu.kafka.consumer;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.protocol.types.Field;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Properties;
import java.util.Set;

/**
 * @Author: VinEwardZhu
 * @CreateTime: 2023-02-13 20:14
 * @Version: 1.0
 */
public class CustomConsumerSeek {
    public static void main(String[] args) {
        //0 配置
        Properties properties = new Properties();
        //连接
        properties.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "hadoop102:9092, hadoop103:9092");
        //反序列化
        properties.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());     
        //组id
        properties.put(ConsumerConfig.GROUP_ID_CONFIG, "test2");        
        //1.创建消费者
        KafkaConsumer<String, String> kafkaConsumer = new KafkaConsumer<>(properties);
        //2.订阅主题
        ArrayList<String> topics = new ArrayList<>();
        topics.add("first");
        kafkaConsumer.subscribe(topics);      
        //指定位置进行消费
        Set<TopicPartition> assignment = kafkaConsumer.assignment();
        //保证分区分配方案已经指定完毕
        while (assignment.size() == 0) {
            kafkaConsumer.poll(Duration.ofSeconds(1));
            assignment = kafkaConsumer.assignment();
        }        
        //指定消费的offset
        for (TopicPartition topicPartition : assignment) {
            kafkaConsumer.seek(topicPartition, 100);
        } 
        //3.消费数据
        while (true) {
            ConsumerRecords<String, String> consumerRecords = kafkaConsumer.poll(Duration.ofSeconds(1));
            for (ConsumerRecord<String, String> consumerRecord : consumerRecords) {
                System.out.println(consumerRecord);
            }
        }
    }
}
```

注意：每次执行完，需要修改消费者组名；

#### 5.5.5 指定时间消费

​	需求：在生产环境中，会遇到最近消费的几个小时数据异常，想重新按照时间消费。例如要求按照时间消费前一天的数据，怎么处理？

​	操作步骤：

```java
package com.atguigu.kafka.consumer;

import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.internals.Topic;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.*;

/**
 * @Author: VinEwardZhu
 * @CreateTime: 2023-02-13 20:35
 * @Version: 1.0
 */
public class CustomConsumerSeekTime {
    public static void main(String[] args) {
        //0 配置
        Properties properties = new Properties();
        //连接
        properties.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "hadoop102:9092, hadoop103:9092");
        //反序列化
        properties.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());

        //组id
        properties.put(ConsumerConfig.GROUP_ID_CONFIG, "test2");

        //1.创建消费者
        KafkaConsumer<String, String> kafkaConsumer = new KafkaConsumer<>(properties);

        //2.订阅主题
        ArrayList<String> topics = new ArrayList<>();
        topics.add("first");
        kafkaConsumer.subscribe(topics);

        //指定位置进行消费
        Set<TopicPartition> assignment = kafkaConsumer.assignment();

        //保证分区分配方案已经指定完毕
        while (assignment.size() == 0) {
            kafkaConsumer.poll(Duration.ofSeconds(1));
            assignment = kafkaConsumer.assignment();
        }

        //希望把时间转换为对应的offset
        HashMap<TopicPartition, Long> topicPartitionLongHashMap = new HashMap<>();
        //封装对应集合
        for (TopicPartition topicPartition : assignment) {
            topicPartitionLongHashMap.put(topicPartition, System.currentTimeMillis() - 1 * 24 * 3600 * 1000);
        }
        Map<TopicPartition, OffsetAndTimestamp> topicPartitionOffsetAndTimestampMap = kafkaConsumer.offsetsForTimes(topicPartitionLongHashMap);

        //指定消费的offset
        for (TopicPartition topicPartition : assignment) {
            OffsetAndTimestamp offsetAndTimestamp = topicPartitionOffsetAndTimestampMap.get(topicPartition);
            kafkaConsumer.seek(topicPartition, offsetAndTimestamp.offset());
        }

        //3.消费数据
        while (true) {
            ConsumerRecords<String, String> consumerRecords = kafkaConsumer.poll(Duration.ofSeconds(1));
            for (ConsumerRecord<String, String> consumerRecord : consumerRecords) {
                System.out.println(consumerRecord);
            }
        }
    }
}
```

#### 5.5.6 漏消费和重复消费分析

​	重复消费：已经消费了数据，但是offset没提交

​	漏消费：先提交offset消费，有肯能会造成数据的漏消费

![1676292490400](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\重复消费和漏消费.png)

​	思考：怎么能做到既不漏消费也不重复消费呢？详看消费者事务。

### 5.6 生产经验——消费者事务

![1676292683826](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\消费者事务.png)

### 5.7 生产经验——数据积压（消费者如何提高吞吐量）

![1676292911251](C:\Users\朱文华\AppData\Roaming\Typora\typora-user-images\数据积压.png)

## 第 6 章 Kafka-Eagle监控

​	Kafka-Eagle框架可以监控Kafka集群的整体运行情况，在生产环境中经常使用。

​	官网：https://www.kafka-eagle.org/

### 6.1 MySQL环境准备

​	Kafka-eagle的安装依赖于MySQL，MySQL主要用来存储可视化展示的数据。如果集群中之前安装过MySQL可以跨过该步。

### 6.2 Kafka环境准备

1）关闭Kafka集群

```shell
[atuigu@hadoop102 kafka]$ kf.sh stop
```

2）修改/opt/module/kafka/bin/kafka-server-start.sh命令中

```shell
[atguigu@hadoop102 kafka]$ vim bin/kafka-server-start.sh
```

修改如下参数值：

```shell
if ["x$KAFKA_HEAP_OPTS" = "x"]; then
	export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
fi	
```

为

```shell
if ["x$KAFKA_HEAP_OPTS" = "x"]; then
	export KAFKA_HEAP_OPTS="-server -Xmx2G -Xms2G -XX:PermSize=128m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=8 -XX:ConcGCThreads=5 -XX:InitiationHeapOccupancyPercent=70"
	export JMX_PORT="9999"
fi	
```

注意：修改之后在启动Kafka之前要分发至其他节点

### 6.3 Kafka-Eagle安装

0）官网：https://www.kafka-eagle.org/

1）上传压缩包kafka-eagle-bin-2.0.8.tar.gz到集群/opt/software目录

2）解压到本地

```shell
[atguigu@hadoop102 software]$ tar -zxvf kafka-eagle-bin-2.0.8.tar.gz
```

3）进入刚才解压的目录

```shell
[atguigu@hadoop102 kafka-eagle-bin-2.0.8]$ ll
```

4）将efak-web-2.0.8.bin.tar.gz解压至/opt/module

```shell
[atguigu@hadoop102 kafka-eagle-bin-2.0.8]$ tar -zxvf efak-web-2.0.8-bin.tar.gz -C /opt/module/
```

5）修改名称

```shell
[atguigu@hadoop102 modue]$ mv efak-web-2.0.8/ efak
```

6）修改配置文件/opt/module/efak/conf/system-config.properties

```shell
[atguigu@hadoop102 conf]$ vim system-config.properties
```

7）添加环境变量

```shell
[atguigu@hadoop102 conf]sudo vim /etc/profile.d/my_env.sh
#kafkaEFAK
export KE_HOME=/opt/module/efak
export PATH=$PATH:$KE_HOME/bin
```

注意：source/etc/profile

8）启动

（1）注意：启动之前需要先启动ZK以及KAFKA

```shell
[atguigu@hadoop102 kafka]$ kf.sh start
```

（2）启动efak

```shell
[atguigu@hadoop102 efak]$ bin/ke.sh start
```

​		说明：如果停止efak，执行命令

```shell
[atguigu@hadoop102 efak]$ bin/ke.sh stop
```

### 6.4 Kafka-Eagle页面操作

## 第 7 章 Kafka-Kraft模式

### 7.1 Kafka-Kraft架构

​	左图为Kafka现有架构，元数据在zookeeper中，运行时动态选举controller，由controller进行Kafka集群管理。右图为kraft模式架构（实验性），不再依赖zookeeper集群，而是用三台controller节点代替zookeeper，元数据保存在controller中，由controller直接进行集群管理。

​	这样做的好处有以下几个：

+ Kafka不再依赖外部框架，而是能够独立运行；
+ controller管理集群时，不再需要从zookeeper中先读取数据，集群性能上升；
+ 由于不依赖zookeeper，集群扩展时不再收到zookeeper读写能力限制；
+ controller不再动态选举，而是由配置文件规定。这样我们可以有针对性的加强controller节点的配置，而不是像以前一样对随机controller节点的高负载束手无策。

### 7.2 Kafka-Kraft集群部署

1）再次解压一份kafka安装包

```shell
[atguigu@hadoop102 software]$ tar -zxvf kafka_2.12-3.0.0.tgz -C /opt/module/
```

2）重命名为kafka2

```shell
[atguigu@hadoop102 module]$ mv kafka_2.12-3.0.0/ kafka2
```

3）在hadoop102上修改/opt/module/kafka2/config/kraft/server.properties配置文件

```shell
[atguigu@hadoop102 kraft]$ vim server.properties
#kafka的角色（controller相当于主机、broker节点相当于从机，主机类似zk功能）
process.roles=broker, controller
#节点
node.id=2
#controller服务协议名
controller.listener.names=CONTROLLER
#全Controller列表
controller.quorum.voters=2@hadoop102:9093,3@hadoop103:9093,4@hadoop104:9093
#不同服务器绑定的端口
listeners=PLAINTEXT://:9092,CONTROLLER://:9093
#broker服务协议名
inter.broker.listener.name=PLAINTEXT
#broker对外暴露的地址
advertised.Listeners=PLAINTEXT://hadoop102:9092
#协议别名到安全协议的映射
listener.security.protocol.map=CONTROLLER:PLAINTEXT, PLAINTEXT:PLAINTEXT, SSL:SSL, SASL_PLAINTEXT:SASL_PLAINTEXT, SASL_SSL:SASL_SSL
#kafka数据存储目录
log.dirs=/opt/module/kafka2/data
```

4）分发kafka2

```shell
[atguigu@hadoop102 module]$ xsync kafka2/
```

+ 在hadoop103和hadoop104上需要对node.id相应改变，值需要和controller.quorum.voters对应。
+ 在hadoop103和hadoop104上需要根据各自的主机名称，修改相应的advertised.Listeners地址

5）初始化集群数据目录

​	（1）首先生成存储目录唯一ID

```shell
[atguigu@hadoop102 kafka2]$ bin/kafka-storage.sh random-uuid
```

​	（2）用该ID格式化kafka存储目录（三台节点）

```shell
[atguigu@hadoop102 kafka]$ biin/kafka-storage.sh format -t 'uuid' -c /opt/module/kafka2/config/kraft/server.properties
```

6）启动kafka集群

```shell
[atguigu@hadoop102 kafka2]$ bin/kafka-server-start.sh -daemon config/kraft/server.properties
[atguigu@hadoop103 kafka2]$ bin/kafka-server-start.sh -daemon config/kraft/server.properties
[atguigu@hadoop104 kafka2]$ bin/kafka-server-start.sh -daemon config/kraft/server.properties
```

7）停止kafka集群

```shell
[atguigu@hadoop102 kafka2]$ bin/kafka-server-stop.sh
[atguigu@hadoop103 kafka2]$ bin/kafka-server-stop.sh
[atguigu@hadoop104 kafka2]$ bin/kafka-server-stop.sh

```

### 7.3 Kafka-Kraft集群启动停止脚本

1）在/home/atguigu/bin目录下创建文件kf2.sh脚本文件

```shell
[atguigu@hadoop102 bin]$ vim kf2.sh
```

脚本如下：

```shell
#!/bin/bash
case $1 in
"start") {
    for i in hadoop102 hadoop103 hadoop104
    do
    	echo "------启动 $i kafka2--------"
    	ssh $i "/opt/module/kafka2/kafka-server-start.sh -daemon config/kraft/server.properties"
    done	
};;
"stop") {
    for i in hadoop102 hadoop103 hadoop104
    do
    	echo "-------停止 $i kafka2--------"
    	ssh $i "/opt/module/kafka2/bin/kafka-server-stop.sh"
    done	
};;
esac
```

2）添加执行权限

```shell
[atguigu@hadoop102 bin]$ chmod +x kf2.sh
```

3）启动集群命令

```shell
[atguigu@hadoop102 ~]$ kf2.sh start
```

4）停止集群命令

```shell
[atguigu@hadoop102 ~]$ kf2.sh stop
```

