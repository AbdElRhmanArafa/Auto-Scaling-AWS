#!/bin/bash
yum update -y --security
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --enable epel
yum -y install httpd php stress
chkconfig httpd on
service httpd start
cd /var/www/html
wget https://aws-tc-largeobjects.s3.amazonaws.com/ILT-TF-200-ACSOPS-1/lab-3-scaling-linux/ec2-stress.zip
unzip ec2-stress.zip

echo 'UserData has been successfully executed. ' >> /home/ec2-user/result
find -wholename /root/.*history -wholename /home/*/.*history -exec rm -f {} \;
find / -name 'authorized_keys' -exec rm -f {} \;
rm -rf /var/lib/cloud/data/scripts/* 
