#!/bin/bash

source ./common.sh
app_name=dispatch

check_root
app_setup

dnf install golang -y
VALIDATE $? "install golang"

if [ ! -f go.mod ]; then
  go mod init dispatch &>>$LOG_FILE
  VALIDATE $? "Initializing Go Module"
else
    echo "go.mod already exists... SKIPPING" | tee -a $LOG_FILE  
fi

go mod tidy &>>$LOG_FILE
VALIDATE $? "Downloading Dependencies"

go build &>>$LOG_FILE
VALIDATE $? "Building Dispatch Service"

systemd_setup
print_time