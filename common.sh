#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "script started executed at: $(date)" | tee -a $LOG_FILE

check_root(){
if [ $userid -ne 0]
then
 echo -e "$R error please run the script with root user $N" | tee -a $LOG_FILE
 exit 1
else 
 echo -e "$G you are runninn with root access" | tee -a $LOG_FILE
fi
}

VALIDATE(){
 if [ $1 -eq 0]
 then
  echo -e " $? is $G success $N" | tee -a $LOG_FILE
 else
   echo -e " $? is $R failure $N" | tee -a $LOG_FILE
fi
}

print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo " script executed successfully, $Y $TOTAL_TIME seconds $N"
}

nodejs_setup(){
    dnf module disable nodejs -y &>> $LOG_FILE
    VALIDATE $? "disabling default nodejs"
   
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling nodejs:20"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing nodejs:20"

    npm install &>>$LOG_FILE
    VALIDATE $? "Installing Dependencies"
}

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating roboshop system user"
    else
        echo -e "System user roboshop already created ... $Y SKIPPING $N"
    fi

    mkdir -p /app 
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name"

    rm -rf /app/*
    cd /app 
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzipping $app_name"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Copying $app_name service"

    systemctl daemon-reload &>>$LOG_FILE
    systemctl enable $app_name  &>>$LOG_FILE
    systemctl start $app_name
    VALIDATE $? "Starting $app_name"

maven_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven and Java"

    mvn clean package  &>>$LOG_FILE
    VALIDATE $? "Packaging the shipping application"

    mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
    VALIDATE $? "Moving and renaming Jar file"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Install Python3 packages"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"

    cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
    VALIDATE $? "Copying payment service"

}
