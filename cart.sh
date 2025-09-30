#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
  echo "Please run this Script with root Privilege"
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
VALIDATE $? "Disabled Default Nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling Nodejs"

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

  curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
  VALIDATE $? "Download cart Application"

  cd /app
  VALIDATE $? "Changing to app directory"

  rm -rf /app/*
  VALIDATE $? "Remove existing code"

  unzip /tmp/cart.zip
  VALIDATE $? "Unzip cart"

  npm install
  VALIDATE $? "Installing Dependencies"

  cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
  VALIDATE $? "Copy systemctl service"

  systemctl daemon-reload
  systemctl enable cart
  VALIDATE $? "Enabling cart"

  systemctl restart cart
  VALIDATE $? "Restarted cart"
