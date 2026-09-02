#!/bin/bash

source ./common.sh
app_name=mongodb

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo repo "

dnf install mongodb-org -y &>> $LOG_FILE 
VALIDATE $? " install mongod "

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing MongoDB conf file for remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting MongoDB"

print_time