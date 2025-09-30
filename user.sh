#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
   echo "Please run this Script with root privilege"
   exit 1
fi

VALIDATE(){
   if [ $1 -ne 0 ]; then
     echo -e "$2 ... $R FAILURE $N"
  else
     echo -e "$2 ... $G SUCCESS $N"
  fi
}

####Nodejs####
dnf module disable nodejs -y
VALIDATE $? "Disable Default Nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling Nodejs:20"

dnf install nodejs -y
VALIDATE $? "Installing Nodejs"

id roboshop
  if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
  else
    echo -e "User already exist ... $Y SKIPPING $N"
  fi

  mkdir -p /app
  VALIDATE $? "Create app directory"

  curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
  VALIDATE $? "Download the user Application"

  cd /app
  VALIDATE $? "Change to app directory"

  rm -rf /app/*
  VALIDATE $? "Remove existing code"

  unzip /tmp/user.zip
  VALIDATE $? "Unzip user"

  npm install
  VALIDATE $? "Installing Dependencies"

  cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
  VALIDATE $? "Copy Systemctl service"

  systemctl daemon-relaod
  systemctl enable user
  VALIDATE $? "Enabling User"

  systemctl restart user
  VALIDATE $? "Restart User"
