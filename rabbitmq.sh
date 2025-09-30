#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

 SCRIPT_DIR=$PWD
 LOGS_FOLDER="/var/log/Shell-roboshop"
 SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
 LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
 START_TIME=$(date +%s)

 mkdir -p $LOGS_FOLDER
 echo "Script Started executed at: $(date)" | tee -a $LOG_FILE
 
if [ $USERID -ne 0 ]; then
   echo "ERROR:: Please run this script with root Privileges"
   exit 1
fi

VALIDATE(){
   if [ $1 -ne 0 ]; then
      echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
   else
      echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
   fi
}

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Addding RabbitMQ Repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling RabbitMQ Server"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting RabbitMQ Server"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
VALIDATE $? "User Add RabbitMQCTL"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Set Permissions RabbiMQ"

END_TIME=(date +%s)
TOTAL_TIME=$(( $END_TIME-$START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME seconds $N"
