## Hive基本概念

**Hive简介**

由Facebook开源用于解决海量结构化日志的数据统计工具。Hive是基于Hadoop的一个数据仓库工具，可以将结构化的数据文件映射为一张表，并提供类SQL查询功能

**Hive本质**

将HQL转化成MapReduce程序

## Hive的优缺点

优点：

1、操作接口采用类SQL语法，提供快速开发的能力（简单、容易上手）

2、避免了去写MapReduce，减少开发人员的学习成本

3、Hive的执行延迟比较高，因此Hive常用于数据分析，对实时性要求不高的场合

4、Hive优势在于处理大数据，对于处理小数据没有优势，因为Hive的执行延迟比较高

缺点：

1、迭代式算法无法表达

2、数据挖掘方面不擅长，由于MapReduce数处理流程的限制，效率更高的算法却无法实现

3、Hive自动生成的MapReduce作业，通常情况下不够智能化

4、Hive调优比较困难，粒度较粗

**MySQL的安装**

查安装包：mariadb-libs-5.5.35-3.el7.x86_64

卸载：sudo rpm -e --nodeps mariadb-libs-5.5.35-3.el7.x86_6

```shell
sudo rpm -ivh mysql-community-common-5.7.28-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-libs-5.7.28-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-libs-compat-5.7.28-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-client-5.7.28-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-server-5.7.28-1.el7.x86_64.rpm
//初始化数据库
sudo mysqld --initialize --user=mysql
//启动mysql服务
sudo systemctl start mysqld
//查看状态
sudo systemctl status mysqld
//查看随机生成的密码
cat /var/log/mysqld.log | grep password
//连接mysql
mysql -uroot -pxrdOul8r?Hgc
//修改密码
set password = password('123456')
//MySQL远程连接
select host, user, authentication_string from user;
update mysql.user set host = '%' where user = 'root';
flush privileges;
```

**Hive元数据配置到MySQL**

```shell
//将MySQL的JDBC驱动拷贝到
cp /opt/software/mysql-connector-java-5.1.48.jar $HIVE_HOME/lib
```

配置Metasotre到MySQL
在$HIVE_HOME/conf目录下新建hive-site.xml添加如下内容

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
	<!--jdbc连接的URL-->
    <property>
    	<name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://hadoop101:3306/metastore?useSSL=false</value>
    </property>
    <!--jdbc连接的Driver-->
    <property>
    	<name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.jdbc.Driver</value>
    </property>
    <!--jdbc连接的username-->
    <property>
    	<name>javax.jdo.option.ConnectionUserName</name>
        <value>root</value>
    </property>
    <!--jdbc连接的password-->
    <property>
    	<name>javax.jdo.option.ConnectionPassword</name>
        <value>123456</value>
    </property>
    <!--Hive默认在HDFS的工作目录-->
    <property>
    	<name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
    </property>
    <!--Hive元数据存储版本的验证-->
    <property>
    	<name>hive.metastore.schema.verification</name>
        <value>false</value>
    </property>
    <!--指定存储元数据要连接的地址-->
    <property>
    	<name>hive.metastore.uris</name>
        <value>thrift://hadoop101:9003</value>
    </property>
    <!--指定hiveserver2连接的端口号-->
    <property>
    	<name>hive.server2.thrift.port</name>
        <value>10000</value>
    </property>
    <!--指定hiveserver2连接的host-->
    <property>
    	<name>hive.server2.thrift.bind.host</name>
        <value>hadoop101</value>
    </property>
    <!--元数据存储授权-->
    <property>
    	<name>hive.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>
    <!--打印当前所在库-->
    <property>
    	<name>hive.cli.print.current.db</name>
        <value>true</value>
    </property>
    <!--打印表头-->
    <property>
    	<name>hive.cli.print.header</name>
        <value>true</value>
    </property>
</configuration>
```

**启动Hive**

初始化元数据库

+ 登录MySQL

mysql -uroot -p123456

+ 新建Hive元数据库

create database metastore;

quit;

+ 初始化Hive元数据库

schematool -initSchema -dbType mysql -verbose

启动服务

```shell
nohup hive --service metastore 2>&1 &
nohup hive --service hiveserver2 2>&1 &

```

启动脚本

```shell
#!/bin/bash
HIVE_LOG_DIR=$HIVE_HOME/logs
if [ ! -d $HIVE_LOG_DIR ]
then
	mkdir -p $HIVE_LOG_DIR
fi
#检查进程是否运行正常，参数1为进程名，参数2为进程端口
function check_process()
{
	pid=$(ps -ef 2>/dev/null | grep -v grep | grep -i $1 | awk '{print $2}')
	ppid=$(netstat -nltp 2>/dev/null | grep $2 | awk '{print $7}' | cut -d '/' -f 1)
	echo $pid
	[[ "pid" =~ "$ppid" ]] && [ "$ppid" ] && return 0 || return 1
}

function hive_start()
{
	metapid=$(check_process HiveMetastore 9083)
	cmd="nohup hive --service metastore >$HIVE_LOG_DIR/metastore.log 2>&1 &"
	cmd=$cmd" sleep 4; hdfs dfsadmin -safemode wait >/dev/null 2>&1"
	[ -z "$metapid" ] && eval $cmd || echo "Metastore服务已启动"
	server2pid=$(check_process HiveServer2 10000)
	cmd="nohup hive --service hiveserver2 >$HIVE_LOG_DIR/hiveServer2.log 2>&1 &"
	[ -z "$server2pid" ] && eval $cmd || echo "HiveServer2服务已启动"
}
function hive_stop()
{
	metapid=$(check_process HiveMetastore 9083)
	[ "$metapid" ] && kill $metapid || echo "Metastore服务未启动"
	server2pid=$(check_process HiveServer2 10000)
	[ "$server2pid" ] && kill $server2pid || echo "HiveServer2服务未启动"
}
case $1 in
"start")
	hive_start
	;;
"stop")
	hive_stop
	;;
"restart")
	hive_stop
	sleep 2
	hive_start
	;;
"status")
	check_process HiveMetastore 9803 >/dev/null && echo "Metastore服务运行正常" || echo "Metastore服务运行异常"
	check_process HiveServer2 10000 >/dev/null && echo "HiveServer2服务运行正常" || echo "HiveServer2服务运行异常"
	;;
*)
	echo Invalid Args!
	echo 'Usage: '$(basename $0)' start|stop|restart|status'
	;;
esac	
```

添加执行权限
```shell
chmod u+x hiveservice.sh
```

**HiveJDBC访问**

```shell
beeline -u jdbc:hive2://hadoop101:10000 -n atguigu
hive
```

**hive常用交互命令**

```shell
hive -help
hive -e
hive -f
dfs -ls /
```



**参数配置方式**

1、查看当前所有的配置信息

```shell
hive>set;
```

2、参数 多配置三种方式

+ 配置文件方式

默认配置文件：hive-default.xml

用户自定义配置文件：hive-site.xml

注意：用户自定义配置会覆盖默认配置。另外，Hive也会读入Hadoop的配置，因为Hive是作为Hadoop的客户端启动的，Hive的配置会覆盖Hadoop的配置。配置文件的设定对本机启动的所有Hive进程都有效

+ 命令行参数方式

  启动Hive时，可以在命令行添加-hiveconf param=value来设定参数

+ 参数声明方式

可以在HQL中使用SET关键字设定参数

## Hive数据类型

+ 基本数据类型

| Hive数据类型 | Java数据类型 | 长度                                             | 例子                                  |
| ------------ | ------------ | ------------------------------------------------ | ------------------------------------- |
| TINYINT      | byte         | 1byte有符号整数                                  | 20                                    |
| SMALINT      | short        | 2byte有符号整数                                  | 20                                    |
| INT          | int          | 4byte有符号整数                                  | 20                                    |
| BIGINT       | long         | 8byte有符号整数                                  | 20                                    |
| BOOLEAN      | boolean      | 布尔类型，true或false                            | TRUE、FALSE                           |
| FLOAT        | float        | 单精度浮点数                                     | 3.14159                               |
| DOUBLE       | double       | 双精度浮点数                                     | 3.14159                               |
| STRING       | string       | 字符系列，可以指定自付集，可以使用单引号或双引号 | ‘now is the time’、"for all good men" |
| TIMESTAMP    |              | 时间类型                                         |                                       |
| BINARY       |              | 字节数组                                         |                                       |

对于Hive的String类型相当于数据库的varcha类型，该类型时一个可变的字符串，不过它不能生命其中最多能存储多少个字符，理论上他可以存储2GB的字符数

+ 集合数据类型

| 数据类型 | 描述                                                         | 语法示例                                        |
| -------- | ------------------------------------------------------------ | ----------------------------------------------- |
| STRUCT   | 和c语言中的struct类似，都可以通过“点”符号访问元素内容。例如，如果某个列的数据类型是STRUCT{first STRING， last STRING}，那么第一个元素可以通过字段.first来引用 | struct{}，例如struct<street:string,city:string> |
| MAP      | MAP是一组键-值对元素集合，使用数组表示法可以访问数据。例如，如果某个列的数据类型是MAP，其中键->值对是‘first'->’John'和‘last’->'Doe'，那么可以通过字段名['last']获取最后一个元素 | map()，例如map<string, int>                     |
| ARRAY    | 数组是一组具有相同类型和名称的变量的集合，这些变量称为数组的元素，每个数组元素都有一个编号，编号从零开始。例如，数组值为['John', 'Doe']，那么第2个元素可以通过数组名[1]进行引用 | Array()，例如array<string>                      |

**建表示例**

```sql
create table person(
	name string,
    friends array<string>,
    children map<string, int>,
    address struct<street:string, city:string, id:int>
)
row foramt delimited fields terminated by ','
collection items terminated by '_'
map keys terminated by ':'
lines terminated by '\n';
```

**将数据上传到HDFS中**

1、hive的方式：load data local inpath '/opt/module/hive-3.1.2/datas/person.txt' into table person;

2、Hadoop方式：hadoop fs -put /opt/module/hive-3.1.2/datas/person.txt  /user/hive/warehouse/person

**库的DDL**

```sql
//建库语句
CREATE DATABASE [IF NOT EXISTS] database_name -- 指定库名
[COMMENT database_comment] -- 指定库的描述信息
[LOCATION hdfs_path] -- 指定库在hdfs中的对应目录
[WITH DBPROPERTIES (property_name=property_value, ...)]; -- 指定库的属性信息
//建库操作
create database if not exists mydb
comment 'this is my first db'
location '/mydb'
with dbproperties('dbname'='mydb', 'createtime'='2022-08-25');
```

**表的DDL**

```SQL
//建表语句
CREATE [EXTERNAL] TABLE [IF NOT EXISTS] table_name -- 指定表名，[EXTERNAL]表示外部表，如果不加，则创建内部表
[(col_name data_type [COMMENT col_comment], ...] -- 指定列名 列类型 列描述信息
[COMMENT table_comment] -- 指定表的描述信息
[CLUSTERED BY (col_name, col_name, ...) -- 指定分桶列名 分桶是分数据
[SORTED BY (col_name [ASC|DESC], ....)] INTO num_buckets BUCKETS] -- 指定排序列(几乎不用)，分多少个桶
[ROW FORMAT delimited fields terminated by 分隔符] -- 指定每行数据中每个元素的分隔符
[collection items terminated by 分隔符] -- 指定集合的元素分隔符
[map keys terminated by 分隔符] -- 指定map的kv分隔符
[lines terminated by 分隔符] -- 指定行分隔符  
[STORED as file_format] -- 只当表数据的存储格式(textfile, orc, parquet)
[LOCATION hdfs_path]  -- 指定表对应的hdfs目录
[TBLPROPERTIES (property_name=property_value, ...)] -- 指定表的属性信息  
//建表操作
1）管理表（内部表）
删除表时，会将表在HDFS中映射的目录和目录下的数据都删除
2）外部表 EXTERNAL
删除表时，智慧删除MySQL中的元数据信息，不会删除表在HDFS中映射的目录和目录下的数据
3）创建表
create EXTERNAL table if not exists student1
( id int comment 'student id',
	name string comment 'student name'
)
comment 'student table'
row format delimited fields terminated by '\t'
stored as textfile
location '/student1'
tbproperties('tablename'='student1');
4)查表
 show tables
5)查表的详情
 desc 表名
6)修改
 alter table 表名 rename to 新的名字						-- 改表名
 alter table 表名 change column 旧列名 新列名 列类型		 -- 修改已有列
 alter table 表名 add column(新列名 列类型......)		   -- 增加新列	
 alter table 表名 replace columns(新列名 列类型......)	   -- 替换列
 需要注意：新列的类型不能比对应旧列的类型小
7)删除
 drop table if exists 表名
```

**DML数据导入**

```sql
load:
    load data [local] inpath '数据的path' [overwrite] into table 表名 [partition];
    （1）local：如果写，表示从Linux从本地将数据导入(复制)；如果不不写，表示从HDFS将数据进行导入(剪切)
    （2）overwrite：如果写，表示新导入的数据将表中原有的数据进行覆盖；如果不写，表示新数据导入表的目录下，表中已有的数据不会被覆盖
insert:
	（1）insert into table 表名 values(x, x, x,...) 	需要执行mr
	（2）insert into|overwrite 表名1 select * from 表名2 需要执行mr
as select:
	create table 表名1 as select * from 表名2 			 要执行mr
location:
	create table 表名 (列名 列类型 ...) row format ... location 'hdfs中数据的位置'
import:
	import table 表名 from 'hdfs路径
```

**DML数据导出**

```sql
insert:
	insert overwrite [local] directory '导出的路径' row foramt..... select * from 表
hadoop方式导出：
	hadoop fs -get
	dfs -get(hive窗口中)
hive命令：
	hive -e 'sql' > 文件
	hive -f 文件 > 文件
export:
	export table 表名 to 'hdfs路径'
sqoop:

truncate：只能删除管理表，不能删除外部表中的数据
	truncate table 表名
```

**查询**

```sql
SELECT [ALL | DISTINCT] select_expr, select_expr, ... 	-- 查询表中的哪些字段
FROM table_reference									-- 从哪个表查
[WHERE where_condition]									-- where过滤条件
[GROUP BY col_list]										-- 分组
[ORDER BY col_list]										-- 全局排序
[CLUSTER BY col_list									-- 分区排序
	| [DISTRIBUTE BY col_list] [SORT BY col_list]		
]									
[LIMIT number]											-- 限制返回的数据条数
```





