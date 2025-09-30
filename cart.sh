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
  echo "Please run this Script with root Privilege"
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
VALIDATE $? "Disabled Default Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nodejs"

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

  curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
  VALIDATE $? "Download cart Application"

  cd /app &>>$LOG_FILE
  VALIDATE $? "Changing to app directory"

  rm -rf /app/* &>>$LOG_FILE
  VALIDATE $? "Remove existing code"

  unzip /tmp/cart.zip &>>$LOG_FILE
  VALIDATE $? "Unzip cart"

  npm install &>>$LOG_FILE
  VALIDATE $? "Installing Dependencies"

  cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
  VALIDATE $? "Copy systemctl service"

  systemctl daemon-reload
  systemctl enable cart &>>$LOG_FILE
  VALIDATE $? "Enabling cart"

  systemctl restart cart
  VALIDATE $? "Restarted cart"
