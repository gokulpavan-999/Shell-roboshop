#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/Shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
  echo "ERROR:: Please run this Script with root Privilege"
  exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
      echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
    else
      echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing Python3"

id roboshop &>>$LOG_FILE
  if [ $? -ne 0 ]; then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
     VALIDATE $? "Create User"
  else
    echo -e "User already exists ... $Y SKIPPING $N"
  fi

mkdir /app
VALIDATE $? "Create app Directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Download Payment Application"

cd /app
VALIDATE $? "Changing app directory"

rm-rf /app/*
VALIDATE $? "Remove existing Code"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Unzip Payment"

pip3 install -r requirements.txt &>>$LOG_FILE

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
systemctl daemon-reload
systemctl enable payment &>>$LOG_FILE

systemctl restart payment 
