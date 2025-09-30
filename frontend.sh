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

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling Default Nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nginx:1.24"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx 
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Download front-end Application"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzip front-end"

rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.conf /etc/systemd/system/nginx.conf &>>$LOG_FILE
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx
VALIDATE $? " Restarting nginx"

