查看所有的库
show databases;
选库
use 库名;
查看库的信息
show create database 库名;
创建库
create database [if not exists] 库名 [character set '字符编码集'];
修改库的字符编码集
alter database 库名 character set '字符编码集';
删除库
drop database [if exists] 库名;
----------------------------------------
查看所有的表
show tables;
查看表结构
desc 表名;
查看表信息
show create table 表名;
创建表
方式1：
create table [if not exists] 表名(
	字段名1 数据类型,
	字段名2 数据类型,
	......
	字段名n 数据类型
)[character set '字符编码集'];
方式2：
create table 表名
[as]
select查询语句;
方式3：
create table 表名 like 表名;
删除表
drop table if exists 表名;
---------------------------------------
对表中的字段进行操作
alter table 表名 add/drop/change/modify [column]...
向表中添加字段
alter table 表名 add [column] 字段名 数据类型;
删除表中的字段
alter table 表名 drop 字段名;
修改表中的字段名
alter table 表名 change [column] 原字段名 新字段名 [数据类型];
修改表中的字段类型
alter table 表名 modify 要修改数据类型的字段名 数据类型;
修改表的名字
alter table 表名 rename to 新表名;
---------------------------------------
向表中插入一条数据
insert into 表名(字段1, 字段2, 字段3, ...) values (值1, 值2, 值3, ...);
insert into 表名 values (值1, 值2, 值3, ...);
向表中插入多条数据
insert into 表名(字段1, 字段2, 字段3, ...) values (值1, 值2, 值3, ...), values (值1, 值2, 值3, ...), values (值1, 值2, 值3, ...);
insert into 表名 values (值1, 值2, 值3, ...), (值1, 值2, 值3, ...), (值1, 值2, 值3, ...);
将查询的结果插入到当前表中
insert into 表名(字段1, 字段2, 字段3, ...)
select 字段1, 字段2, 字段3, ...;
修改表中的数据
update 表名 set 字段1=值1, 字段2=值2, 字段3=值3, ...[where 过滤条件]
删除表中的数据
delete from 表名 [where 过滤条件]
truncate table 表名
----------------------------------------
/*
 约束：为了保证数据的一致性和完整性,SQL规范以约束的方式对表数据进行额外的条件限制
 有一下六种约束：
 	NOT NULL    	非空约束，规定某个字段不能为空
 	UNIQUE			唯一约束，规定某个字段在整个表中是唯一的
 	PRIMARY KEY		主键（非空且唯一）
 	FOREIGN KEY		外键
 	CHECK			检查约束（mysql不支持）
 	DEFAULT			默认值
 约束分类：表级约束 vs 列级约束
*/
主键约束：约束多列
格式：
constraint 索引名 primary key(字段1, 字段2, 字段3...)	
唯一约束：约束多列
格式：
constraint 索引名 unique(字段1, 字段2, 字段3...)
外键约束
constraint 索引名 foreign key(从表的字段) references 主表名(主表的字段)
----------------------------------------
添加约束
alter table 表名 add primary key(字段1, 字段2, 字段3...);
修改约束
alter table 表名 modify 字段名 类型 primary key;
删除约束
alter table 表名 drop primary key;
----------------------------------------
级联删除
on delete cascade
----------------------------------------
/*
 limit 索引位置, 数据的条数
 注意：索引位置从0开始
 分页公式：limit(页数 - 1) * 数据的条数, 数据的条数
*/

