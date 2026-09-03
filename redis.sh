#!/bin/bash

source ./common.sh
app_name=redis

check_root

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "disable redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "enable redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "install redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "Changing Redis bind address"

sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
VALIDATE $? "Disabling Redis protected mode"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "enable redis" 

systemctl start redis &>>$LOG_FILE
VALIDATE $? "start redis"

print_time