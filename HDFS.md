**HDFS写数据流程：**

```text
	1、客户端通过DistributeFileSystem模块向NameNode发送上传数据请求，NameNode检查目标文件是否已存在，父目录是否存在
	2、NameNode返回是否可以上传数据
	3、客户端请求第一个Block上传到哪几个DataNode服务器上
	4、NameNode返回3个DataNode节点，分别为dn1，dn2，dn3
	5、客户端通过FSDataOutputStream模块请求dn1上传数据，dn1收到请求会继续调用dn2，dn2收到请求会继续调用dn3，将这个通信管道建立完成
	6、dn1、dn2、dn3逐级应答客户端
	7、客户端开始往dn1上传第一个Block(先从磁盘读取数据放到一个本地内存缓存)，以Packet为单位，dn1收到一个Packet就会传给dn2，dn2收到会传给dn3；dn1每传一个packet会放入一个应答队列等待应答
	8、当一个Block传输完成之后，客户端再次请求NameNode上传第二个Block的服务器（重复第3-7步）
```

**HDFS读数据流程：**

```text
	1、客户端通过DistributeFileSystem模块向NameNode发送下载文件请求，NameNode通过查询元数据，找到文件块所在的DataNode地址
	2、挑选一台DataNode(就近原则，然后随机)服务器，请求读数据
	3、DataNode开始传输数据给客户端(从磁盘里面读取数据输入流，以Packet为单位来做校验)
	4、客户端以Packet为单位接收，先在本地缓存，然后写入目标文件
```

**NameNode和Secondary NameNode的工作机制:**

```text
第一阶段：NameNode启动
	1、第一次启动NameNode格式化后，创建Fsimage和Edits文件。如果不是第一次启动，直接加载编辑日志和镜像文件到内存
	2、客户端对元数据进行增删改的请求
	3、NameNode记录操作日志，更新滚动日志
	4、NameNode在内存中对元数据进行增删改
第二阶段：Secondary NameNode工作
	1、Secondary NameNode询问NameNode是否需要CheckPoint。直接带回NameNode是否检查结果
	2、Secondary NameNode请求执行CheckPoint
	3、NameNode滚动正在写的Edits日志
	4、将滚动前的编辑日志和镜像文件拷贝到Secondary NameNode
	5、Secondary NameNode加载编辑日志和镜像文件到内存，并合并
	6、生成新的镜像文件fsimage.chkpoint
	7、拷贝fsimage.chkpoint到NameNode
	8、NameNode将fsimage.chkpoint重新命名成fsimage
```

**DataNode工作机制:**

```text
	1、一个数据块在DataNode上以文件形式存储在磁盘上，包括两个文件，一个是数据本身，一个是元数据包括数据块的长度，块数据的校验和，以及时间戳
	2、DataNode启动后向NameNode注册，通过后，周期性(6小时)的向NameNode上报所有的块信息
	3、心跳是每3秒一次，心跳返回结果带有NameNode给该DataNode的命令如复制块数据到另一台机器，或删除某个块数据。如果超过10分钟+30秒没有收到某个DataNode的心跳，则认为该节点不可用
	4、集群运行中可以安全加入和退出一些机器
DataNode保证数据的完整性:
	1、当DataNode读取Block的时候，它会计算CheckSum
	2、如果计算后的CheckSum，与Block创建时值不一样，说明Block已经损坏
	3、Client读取其他DataNode上的Block
	4、常见的校验算法crc(32)，md5(128)，shal(160)
	5、DataNode在其文件创建后周期验证CheckSum
```

**job提交流程:**

```text
	1、建立连接
		判断Job是本地运行还是提交到集群运行，如果提交到集群就连接集群
	2、创建资源路径
		2.1、创建stag路径 hdfs://....../.staging
		2.2、创建job_id路径
			每个job都有一个独一无二的id，根据这个id会在前面的staging路径下创建一个以jobid命名的文件夹。这个文件夹后面用来存放该job执行所需的资源，比如文件的切片规划信息。job提交完这个文件就会清楚
	3、加载资源文件
		3.1、job的Jar包
		3.2、切片规划文件
		3.3、配置文件
	4、提交job
```

**shuffle机制:**

```text
	1、MapTask收集我们的map()方法输出的kv对，放到内存缓冲区中
	2、从内存缓冲区不断溢出本地磁盘文件，可能会溢出多个文件
	3、多个溢出文件会被合并成大的溢出文件
	4、在溢出过程及合并的过程中，都要调用Partitioner进行分区和针对key进行排序
	5、ReduceTask根据自己的分区号，去各个MapTask机器上取相应的结果分区数据
	6、ReduceTask会抓取到同一个分区的来自不同MapTask的结果文件，ReduceTask会将这些文件再进行合并(归并排序)
	7、合并成大文件后，Shuffle的过程也就结束了，后面进入ReduceTask的逻辑运算过程(从文件取出一个一个的键值对Group，调用用户自定义的reduce()方法)
```

**Yarn工作机制:**

```text
	1、MapReduce程序提交到客户端所在的节点
	2、YarnRunner向ResourceManager申请一个Application
	3、ResourceManager将该应用程序的资源路径返回给YarnRunner
	4、该程序将运行所需资源提交到HDFS上
	5、程序资源提交完毕后，申请运行MRAppMaster
	6、ResourceManager将用户的请求初始化成一个Task
	7、其中一个NodeManager领取到Task任务
	8、该NodeManager创建容器Container，并产生MRAppMaster
	9、Container从HDFS上拷贝资源到本地
	10、MRAppMaster向RM申请运行MapTask资源
	11、ResourceManager将运行MapTask任务分配给另外两个NodeManager，另两个NodeManager分别领取任务并创建容器
	12、MapReduce向两个接收到任务的NodeManager发送程序启动脚本，这两个NodeManager分别启动MapTask、MapTask对数据分区排序
	13、MRAppMaster等待所有MapTask运行完毕后，向ResourceManager申请容器，运行ReduceTask
	14、ReduceTask向MapTask获取相应分区的数据
	15、程序运行完毕后，MR会向ResourceManager申请注销自己
```

**Hadoop小文件弊端：**

```text
	HDFS上每个文件都要在NameNode上创建对应的元数据，这个元数据的大小约为150byte，这样当小文件比较多的时候，就会产生很多的元数据文件，一方面会大量占用NameNode的内存空间，另一方面就是元数据文件过多，使得寻址索引速度变慢。小文件过多，在进行MR计算时，会生成过多切片，需要启动过多的MapTask。每个MapTask处理的数据量小，导致MapTask的处理时间比启动时间还小，白白消耗资源
```

**Hadoop小文件解决方案：**

```text
	1、Hadoop Archive(HAR归档)
		是一个高效的将小文件放入HDFS块中的文件存档工具，能够将多个小文件打包成一个HAR文件，从而达到减少NameNode的内存使用。
	2、CombineTextInputFormat
		CombineTextInputFormat用于将多个小文件在切片过程中生成一个单独的切片或者少量的切片。
```

**MapReduce优化：**

```text
MapReduce优化方法主要从六个方面考虑：数据输入、Map阶段、Reduce阶段、IO传输、数据倾斜问题和常用的调优参数。
Mapper阶段
	1、合并小文件
		采用CombineTextInputFormat切片规则
	2、自定义分区，减少数据倾斜
		自定义类，实现Partitioner接口，重写getPartition方法
	3、减少溢写的次数
		Shuffle的环形缓冲区大小(mapreduce.task.io.sort.mb)默认100M，可以提高到200M；环形缓冲区溢出的阈值(mapreduce.map.sort.spill.percent)，默认80%，可以提高到90%
	4、增加每次Merge合并次数
		mapreduce.task.io.sort.factor默认10，可以提高到20
	5、在不影响业务结果的前提条件下可以提前采用Combiner
		job.setCombinerClass(xxxReducer.class)
	6、为了减少磁盘IO，可以采用Snappy或者LZO压缩
		conf.setBoolean("mapreduce.map.output.compress", true)
		conf.setClass("mapreduce.map.output.compress.codec", SnappyCodec.class, CompressionCodec.class)
	7、mapreduce.map.memory.mb默认MapTask内存上限1024M
		可以根据128M数据对应1G内存原则提高该内存
	8、mapreduce.map.cpu.vores默认MapTask的CPU核数1
		计算密集型任务可以增加CPU核数
	9、异常重试
		mapreduce.map.maxattempts每个MapTask最大重试次数，一旦重试次数超过该值，则认为MapTask运行失败，默认值为4。根据机器性能适当提高
Reducer阶段
	1、mapreduce.reduce.shuffle.parallelcopies
		每个Reducer去Map中拉取数据的并行数，默认值是5，可以提高到10
	2、mapreduce.reduce.shuffle.input.buffer.percent
		Buffer大小占Reducer可用内存的比例，默认值0.7，可以提高到0.8
	3、mapreduce.reduce.shuffle.merge.percent
		Buffer中的数据达到多少比例开始写入磁盘，默认0.66，可以提高到0.75
	4、mapreduce.reduce.memory.mb
		默认ReduceTask内存上限1024M，根据128M数据对应1G内存原则，适当提高内存到4~6G
	5、mapreduce.reduce.cpu.vcores
		默认ReduceTask的CPU核数个数1个，可以提高到2~4个
	6、mapreduce.reduce.maxattempts
		每个ReduceTask最大重试次数，默认为4，一旦重试次数超过该值，则认为MapTask运行失败
	7、mapreduce.job.reduce.slowstart.completed.maps
		当MapTask完成的比例达到该值后才会为ReduceTask申请资源，默认为0.05
	8、mapreduce.task.timeout
		如果一个Task在一定时间内没有任何进入，即不会读取新的数据，也没有输出数据，则认为该Task处于Block状态，可能是卡住了，也许永远会卡住，为了防止因为用户程序永远Block住不退出，则强制设置了一个该超时时间(单位毫秒)，默认是600000(10分钟)。如果你的程序对每条输入数据的处理时间过长，建议将该参数调大
	9、如果可以不用Reducer，尽可能不用
```

**减少数据倾斜的方法：**

```text
	1、抽样和范围分区
		可以通过对原始数据进行抽样得到的结果集来预设分区边界值
	2、自定义分区
		基于输出键的背景知识进行自定义分区
	3、Combiner
		使用Combiner可以大量地减少数据倾斜。在可能的情况下，Combiner的目的就是聚合精简数据
	4、采用Map Join，尽量避免Reduce Join
```

**Zookeeper选举机制：**

```text
SID：服务器ID。用来唯一标识一台Zookeeper集群中的机器，每台机器不能重复，和myid一致
ZXID：事务ID。ZXID是一个事务ID，用来标识一次服务器状态的变更。在某一时刻，集群中的每台机器的ZXID值不一定完全一致，这和Zookeeper服务器对客户端“更新请求”的处理逻辑有关。
Epoch：每个Leader任期的代号。没有Leader时同一轮投票过程中的逻辑时钟值是相同的。每投完一次票这个数据就会增加。
第一次启动时：
	1、服务器1启动，发起一次选举。服务器1投自己一票。此时服务器1票数一票，不够半数以上(3票)，选举无法完成，服务器1状态保持LOOKING;
	2、服务器2启动，再发起一次选举。服务器1和2分别投自己一票并交换选票信息:此时服务器1发现服务器2的myid比自己的大，更改选票为推举服务器2。此时服务器1票数0票，服务器票数2票，没有半数以上结果，选举无法完成，服务器1，2状态保持LOOKING;
	3、服务器3启动，再发起一次选举。此时服务器1和2都会更改选票为服务器3.此时服务器3的票数已经超过半数，服务器3当选Leader。服务器1，2更改状态为FOLLOWING，服务器3更改状态为LEADING;
	4、服务器4启动，发起一次选举。此时服务器1，2，3已经不是LOOKING状态，不会更改选票信息。交换选票信息结果：服务器3为3票，服务器4为1票。此时服务器4服从多数，更改选票信息为服务器3，并更改状态为FOLLOWING;
	5、服务器5启动，同4一样当小弟;
非第一次启动时：
	1、当Zookeeper集群中的一台服务器出现以下两种情况之一时，就会开始进入Leader选举：
		①服务器初始化启动
		②服务器运行期间无法和Leader保持连接
	2、当一台机器进入Leader选举流程时，当前集群也可能会处于以下两种状态：
		①集群中本来就存在一个Leader，对于已经存在Leader的情况，机器试图去选举Leader时，会被告知当前服务器的Leader信息，对于该机器来说，仅仅需要和Leader机器建立连接，并进行状态同步即可;
		②集群中确实不存在Leader，选举规则：EPOCH大的直接胜出; EPOCH相同，事务id大的胜出; 事务id相同，服务器id大的胜出;
```

**三大调度器的特点及使用场景：**

```text
FIFO调度器：单队列，根据提交作业的先后顺序，先来先服务
	优点：简单易懂
	缺点：不支持多队列，生产环境很少使用
容量调度器：是Yahoo开发的多用户调度器
	1、多队列：每个队列可配置一定的资源量，每个队列采用FIFO调度策略
	2、容量保证：管理员可为每个队列设置资源最低保证和使用上限
	3、灵活性：如果一个队列中的资源有剩余，可以暂时共享给那些需要资源的队列，而一旦该队列有新的应用程序提交，则其他队列借调的资源会归还给该队列
	4、多租户：支持多用户共享集群和多应用程序同时运行;为了防止同一个用户的作业独占队列中的资源，该调度器会对同一用户提交的作业所占资源量进行限定
	①队列资源分配：从root开始，使用深度优先算法，优先选择资源占用率最低的队列分配资源
	②作业资源分配：默认按照提交作业的优先级和提交时间顺序分配资源
	③容器资源分配：按照容器的优先级分配资源;如果优先级相同，按照数据本地性原则：1、任务和数据在同一节点;2、任务和数据在同一机架;3、任务和数据不在同一节点也不在同一机架
公平调度器：是Facebook开发的多用户调度器
	1、与容量调度器相同点
	①多队列
	②容量保证
	③灵活性
	④多租户
	2、与容量调度器不同点
	①核心调度策略不同
		容量调度器：优先选择资源利用率低的队列
		公平调度器：优先选择对资源的缺额比例大的
	②每个队列可以单独设置资源分配方式
		容量调度器：FIFO、DRF
		公平调度器：FIFO、FAIR、DRF
FAIR策略：是一种基于最大最小公平算法实现的资源多路复用方式，默认情况下，每个队列内部采用该方式分配资源。这意味着，如果一个队列中有两个应用程序同时运行，则每个应用程序可得到1/2的资源;如果三个应用程序同时运行，则每个应用程序可得到1/3的资源。
DFR策略：之前说的资源都是单一标准，例如只考虑内存(也是Yarn默认的情况)。但是很多时候我们资源有很多种，例如内存，CPU，网络带宽等，这样我们很难衡量两个应用应该分配的资源比例。
```

