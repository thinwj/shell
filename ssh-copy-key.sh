#!/bin/bash

cat ./ip.txt | while read line
do
expect -c "
spawn ssh-copy-id -i /home/ucloud/.ssh/id_rsa.pub root@$line
expect {
  "*yes/no*" {send yes\r ; exp_continue}
  "*password:" {send ucloud.123cn\r ; exp_continue}
eof {exit} }"
done
