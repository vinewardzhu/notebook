#### **1、安装Docker**

**环境准备**

1、需要会一点点的Linux基础

2、CentOS 7

3、我们使用Xshell连接远程服务器进行操作

**环境查看**

系统内核是3.10以上的

```shell
[atguigu@hadoop105 ~]$ uname -r
3.10.0-123.el7.x86_64
```

系统版本

```shell
[atguigu@hadoop105 ~]$ cat /etc/os-release
NAME="CentOS Linux"
VERSION="7 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
PRETTY_NAME="CentOS Linux 7 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:7"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"
CENTOS_MANTISBT_PROJECT="CentOS-7"
CENTOS_MANTISBT_PROJECT_VERSION="7"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="7"
```

**安装**

1、卸载旧的版本

```shell
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

2、需要的安装包

```shell
sudo yum install -y yum-utils
```

3、设置镜像的仓库

```shell
官方：
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
阿里云：
sudo yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo  
```

4、更新yum软件包索引

```shell
sudo yum makecache fast
```

5、安装Docker相关的 

docker-ce：社区版	docker-ee：企业版

```shell
sudo yum install docker-ce docker-ce-cli containerd.io
```

6、启动Docker

```shell
systemctl start docker
```

7、查看是否安装成功

```shell
docker version
```

8、运行镜像

```shell
docker run hello-world
```

9、查看一下下载的这个hello-world镜像

```shell
docker images
```

了解：

1、卸载依赖

```shell
yum remove docker-ce docker-ce-cli containerd.io
```

2、删除资源

```shell
rm -rf /var/lib/docker   #/var/lib/docker是docker的默认工作路径
```

**配置阿里云镜像加速**

```shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": ["https://qiyb9988.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
cat /etc/docker/daemon.json	#查看是否已安装好加速
```

**底层原理**

Docker是怎么工作的？

Docker是一个Client-Server结构的系统，Docker的守护进程运行在主机上，通过Socket从客户端访问，Docker-Server接收到Docker-Client的指令，就会执行这个命令！

Docker为什么比VM快？

1、Docker有着比虚拟机更少的抽象层

2、Docker利用的是宿主机的内核，VM需要是Guest OS，所以说，建一个容器的时候，Docker不需要像虚拟机一样重新加载一个操作系统内核，避免引导。虚拟机时加载Guest OS，分钟级别的，而Docker是利用宿主机的操作系统，省略了这个复杂的过程，是秒级别的。

#### 2、Docker常用命令

**帮助命令**

```shell
docker version		#显示docker版本信息
docker info			#显示docker的系统信息，包括镜像和容器的数量
docker 命令 --help   #帮助命令
```

**镜像命令**

```shell
docker images					  #查看所有本机的主机上的镜像 
#可选项
-a --all						  #列出所有镜像
-q --quiet  					  #只显示镜像的id
docker search 					  #搜索镜像
docker pull 					  #下载镜像
docker rm						  #删除镜像
#如：【docker rm -f 容器id】
docker rm -f $(docker images -aq) #删除全部的容器
```

**容器命令**

说明：我们有了镜像才可以创建，下载一个centos镜像来测试学习

```shell
docker pull centos
```

新建容器并启动

```shell
docker run [可选参数]
#参数说明：
--name		#容器名字，用来区分容器
-d			#后台方式运行
-v			#目录挂载
-it 		#使用交互方式运行，进入容器查看内容
-p			#指定容器的端口 -p 8080:8080
# -p 主机ip:主机端口:容器端口
# -p 主机端口:容器端口(常用)	
# -p 容器端口
# -p (随机指定端口)
docker ps	#列出所有的运行的容器
#参数说明：
-a			#列出当前正在运行的容器 + 带出历史运行过的容器
```

退出容器

```shell
exit		 	#从容器中退回主机并停止容器
ctrl + P + Q 	#从容器中退回主机但不停止容器
docker start 	#启动容器
docker restart  #重启容器
docker stop 	#停止当前正在运行的容器
docker kill 	#强制停止当前容器
```

**常用其他命令**

后台启动容器

```shell
docker run -d 容器id
#问题：docker ps，发现centos停止了
#常见的坑：docker容器使用后台运行，就必须有一个前台进程，docker发现没有应用，就会自动停止
#nginx，容器启动后，发现自己没有提供服务，就会立刻停止，就是没有程序了
```

查看日志

```shell
docker logs -tf --tail 容器
--tf 	#显示日志
--tail  #要显示日志条数
#自己编写一段shell脚本
docker run -d centos /bin/sh -c "while true;do echo kuangshen;sleep 1;done"
docker top 容器id								 #查看容器中进程信息
docker inspect 容器id	 						 #查看镜像的元数据
docker exec -it 容器id bash/shell(/bin/bash)   #进入容器后开启一个新的终端，可以在里面操作(常用)
docker attach 容器id 							 #进入容器正在执行的终端，不会启动新的进程
docker cp 容器id:容器内路径 目的主机路径 		  #从容器内拷贝文件到主机上
```

**可视化**

portainer(先用这个)（Docker图形化界面管理工具，提供一个后台面板供我们操作）

Rancher(CI/CD再用)

Docker镜像都是只读的，当容器启动时，一个新的可写层被加载到容器镜像的顶部，这一层就是我们通常说的容器层，容器之下的都叫镜像层

Commit**镜像**

```shell
docker commit #提交容器成为一个新的副本
docker commit -m="提交的描述信息" -a="作者" 容器id 目标镜像名称:[TAG]
```

**容器数据卷**

容器之间可以有一个数据共享的技术！Docker容器中产生的数据，同步到本地，这就是数据卷技术！目录的挂载，将我们容器内的目录，挂载到Linux上面！

###### 总结一句话：容器的持久化和同步操作！容器之间也是可以数据共享的

**使用数据卷**

方式一：直接使用命令来挂载

```shell
docker run -it -v 主机目录
#具名挂载和匿名挂载
所有的docker容器内的卷，没有指定目录的情况下都是在/var/lib/docker/volumes/xxx/_date目录下
我们通过具名挂载可以方便的找到我们的一个卷，大多数情况在使用的具名挂载
#如何确定是具名挂载还是匿名挂载，还是指定路径挂载
-v 容器内路径   		   #匿名挂载
-v 卷名:容器内的路径 	 #具名挂载
-v 宿主机路径:容器内路径 	#指定路径挂载
#拓展：
通过-v 容器内路径:ro/rw改变读写权限
ro readonly  #只读
rw readwrite #可读可写
一旦这个设置了容器权限，容器对我们挂载出来的内容就有限定了
docker run -d -p --name nginx02 -v juming-nginx:/etc/nginx:ro nginx
docker run -d -p --name nginx02 -v juming-nginx:/etc/nginx:rw nginx
只要看到ro就说明这个路径只能通过宿主机来操作，容器内部是无法操作的
```

**初始DockerFile**

```shell
DockerFile就是用来构建Docker镜像的构建文件！命令脚本
通过这个脚本可以生成镜像，镜像是一层一层，脚本一个个的命令，每个命令都是一层
#创建一个dockerfile文件，名字可以随机取，建议取Dockerfile
#文件中的内容：指令(大写) 参数
FROM centos
VOLUME ["volume01", "volume02"]
CMD echo "---------------end-----"
CMD /bin/bash
```

**数据卷容器**

```shell
#多个mysql同步数据
#容器之间配置信息的传递数据卷容器的生命周期一直持续到没有容器使用为止，但是一旦持久化到了本地，这个时候，本地的数据是不会被删除的
```

**DockerFile**

```shell
dockerfile是用来构建docker镜像的文件！命令脚本参数
构建步骤：
1、编写一个dockerfile文件
2、docker buile构建成为一个镜像
3、docker run 运行镜像
4、docker push 发布镜像（DockerHub、阿里云仓库）
```

**DockerFile构建过程**

```shell
1、每个保留关键字（指令）都必须是大写字母
2、执行从上到下顺序执行
3、# 表示注释
4、每一个指令都会创建提交一个新的镜像层，并提交
dockerfile是面向开发的，我们以后要发布项目，做镜像，就需要编写dockerfile文件
Docker镜像逐渐成为企业交付的标准，必须掌握
DockerFile：构建文件，定义了一切的步骤，源代码
DockerImages：通过DockerFile构建生成的镜像，最终发布和运行的产品
Docker容器：容器就是镜像运行起来提供服务器
CMD和ENTRYPOINT的区别
CMD              # 指定这个容器启动的时候要运行的命令，只有最后一个会生效，可被代替
ENTRYPOINT       # 指定这个容器启动的时候要运行的命令，可以追加命令
```

**Docker网络**

```shell
1、我们每启动一个docker容器，docker就会给docker容器分配一个ip，我们只要安装了docker，就会有一个网卡docker0桥接模式，使用的技术是evth-pair技术
# 我们发现这个容器带来网卡，都是一对对的
# env-pair 就是一对虚拟设备接口，他们都是成对出现的，一段连着协议，一段彼此相连
# 正因为有这个特性，evth-pair充当一个桥梁，连接各种虚拟网络设备的
# OpenStack, Docker容器之间的连接，OVS的连接，都是使用evth-pair技术
Docker中的所有网络接口都是虚拟的，虚拟的转发效率高(内网传递文件)
只要容器删除，对应网桥一对就没了
```











