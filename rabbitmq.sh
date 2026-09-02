#!/bin/bash

source ./common.sh
app_name=rabbitmq

check_root

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "install rabbitmq"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "enable rabbitmq"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "start rabbitmq"

rabbitmqctl add_user roboshop $RABBITMQ_PASSWD
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

print_time