#!/bin/bash

if [ $# != 2 ];then
``echo "USAGE: sh $0 add/del username"
``exit 1;
fi

#定义变量
AD=$1
USER=$2
#PASS=`head -c 100 /dev/urandom | tr -dc a-z0-9A-Z |head -c 16`
DIR1=/etc/openvpn/client/easy-rsa/3.0
DIR2=/etc/openvpn/easy-rsa/3.0
TMP=/tmp/openvpn.ept

#解决签约错误
cd $DIR2/pki
if [ -f index.txt ];then
   rm -f index.txt && touch index.txt
fi

#创建客户端证书
if [ "$AD" == "add" ];then
cat > $TMP << EOF
#!/usr/bin/expect
spawn sshpass -p "bus365_0121" sudo ssh root@172.16.1.130
set timeout -1
expect "]#"
send -- "cd $DIR1\r"
sleep 2
expect "]#"
send -- "echo 'yes'|./easyrsa gen-req $USER nopass\r"
sleep 5
expect  "]:"
send -- "\r"
sleep 3
expect "]#"
send -- "cd $DIR2\r"
expect "]#"
send -- "./easyrsa import-req $DIR1/pki/reqs/$USER.req $USER\r"
sleep 3
expect  "]#"
send -- "./easyrsa sign client $USER\r"
expect  "details:"
send -- "yes\r"
expect  "]#"
send -- "exit\r"
expect eof
EOF
#运行expect脚本
#pass_file=$DIR1/pass_file
stat_file=/tmp/openvpn_add_del.log
#echo "$USER  $PASS" >>$pass_file
#userpass=`tail -1 $pass_file`

echo "#..................................#"
echo "  OVPN用户账号自动创建中...请稍等  "
echo "#..................................#"
/usr/bin/expect -f $TMP >$stat_file
if [ $? -ne 0 ];then
   echo "用户证书文件创建异常,请检查"
fi

#拷贝crt/key
mkdir -p $DIR1/users/$USER
cp $DIR2/pki/issued/$USER.crt $DIR1/users/$USER/
cp $DIR1/pki/private/$USER.key $DIR1/users/$USER/
echo "#.....用户账号创建完成,详情如下........#"
echo "                                        "
echo "用户crt/key下载目录：$DIR1/users/$USER"
#echo "用户证书密码[请牢记]: $userpass"
echo "                                        "
echo "#......................................#"

#写入随机数到文件,用于sync md5变更依据
#echo "$PASS" >>/tmp/ovpn_create.log
rm $TMP
fi



#吊销用户证书
if [ "$AD" == "del" ];then
TMP2=/tmp/ovpn_revoke.ept
stat_file2=/tmp/ovpn_revoke.log

cat > $TMP2 << EOF
#!/usr/bin/expect
spawn sshpass -p "bus365_0121" sudo ssh root@172.16.1.130
set timeout -1
expect "]#"
send -- "cd $DIR2\r"
expect "]#"
send -- "./easyrsa revoke $USER\r"
expect "revocation: "
send -- "yes\r"
expect "]#"
send -- "./easyrsa gen-crl\r"
expect  "]#"
send -- "exit\r"
expect eof
EOF

echo "#..................................#"
echo "  OVPN账号自动吊销中...请稍等   "
echo "#..................................#"
/usr/bin/expect -f $TMP2 >${stat_file2}
if [ $? -ne 0 ];then
   echo "用户证书吊销出现问题,请检查"
fi

\cp $DIR2/pki/crl.pem /etc/openvpn/
num1=`ps -ef|grep "server.conf"|grep -v grep|awk '{print $2}'`
kill -9 $num1 && sleep 2
/usr/sbin/openvpn --config /etc/openvpn/server.conf  > /tmp/open.log 2>&1 &
if [ $? -eq 0 ];then
   echo "警告: $USER账号已被注销, 即刻生效!"
fi

rm $TMP2
fi
