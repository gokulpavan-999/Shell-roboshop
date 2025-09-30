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

if [ $USERID -ne 0 ]; then
   echo "Please run this Script with root privilege"
   exit 1
fi

VALIDATE(){
   if [ $1 -ne 0 ]; then
     echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
  else
     echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
  fi
}

####Nodejs####
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable Default Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"

id roboshop
  if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
  else
    echo -e "User already exist ... $Y SKIPPING $N"
  fi

  mkdir -p /app &>>$LOG_FILE
  VALIDATE $? "Create app directory"

  curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
  VALIDATE $? "Download the user Application"

  cd /app &>>$LOG_FILE
  VALIDATE $? "Change to app directory"

  rm -rf /app/* &>>$LOG_FILE
  VALIDATE $? "Remove existing code"

  unzip /tmp/user.zip &>>$LOG_FILE
  VALIDATE $? "Unzip user"

  npm install &>>$LOG_FILE
  VALIDATE $? "Installing Dependencies"

  cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
  VALIDATE $? "Copy Systemctl service"

  systemctl daemon-relaod
  systemctl enable user &>>$LOG_FILE
  VALIDATE $? "Enabling User"

  systemctl restart user
  VALIDATE $? "Restart User"
