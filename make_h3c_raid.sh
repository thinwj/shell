#!/bin/bash
#华三定制raid脚本 ,未做任何兼容  
#三块盘raid5  三块盘raid00 非标需求


#安装raid等工具
echo "安装raid工具........"
yum -y install  vim wget 2>/dev/null >&2 
wget -O /root/Arcconf-2.04-22665.x86_64.rpm http://ucloud.mirror.ucloud.cn/raid/Arcconf-2.04-22665.x86_64.rpm 2>/dev/null >&2
rpm -ivh /root/Arcconf-2.04-22665.x86_64.rpm  2>/dev/null >&2
rm -f /root/Arcconf-2.04-22665.x86_64.rpm 2>/dev/null >&2

#卸载挂载分区
echo "清理已有数据盘相关信息........"
umount /data/ 2>/dev/null >&2
sed -i '/data/d' /etc/fstab 2>/dev/null >&2

#检测当前raid信息：
echo "当前系统raid信息为："
/usr/Arcconf/arcconf getconfig 1 ld | grep "RAID level"


#清除raid
echo "清除数据盘已有raid信息........"
dev_id=`/usr/Arcconf/arcconf list|grep -i 'Controller [0-9]'|awk -F ':' '{print $1}'|awk '{print $2}'`

has_array=`/usr/Arcconf/arcconf getconfig $dev_id LD|grep "Logical Device number" | wc -l`
if [ $has_array -gt 0 ]; then
	for (( i=1; i<$has_array; i++)); do
   		/usr/Arcconf/arcconf delete 1 logicaldrive $i noprompt  2>/dev/null >&2
	done
fi
sleep 5s

#制作3raid5
echo "三块盘制作一个raid5..........."
/usr/Arcconf/arcconf create $dev_id logicaldrive Wcache wb  MAX 5 0 2 0 3 0 4 noprompt 2>/dev/null >&2
sleep 5s


#制作 3raid00
echo "三块盘制作为三个raid00........"
/usr/Arcconf/arcconf create $dev_id logicaldrive max simple_volume 0 5 noprompt 2>/dev/null >&2
/usr/Arcconf/arcconf create $dev_id logicaldrive max simple_volume 0 6 noprompt 2>/dev/null >&2
/usr/Arcconf/arcconf create $dev_id logicaldrive max simple_volume 0 7 noprompt 2>/dev/null >&2


#检测是否成功：
echo "当前系统raid信息为："
/usr/Arcconf/arcconf getconfig 1 ld | grep "RAID level"
