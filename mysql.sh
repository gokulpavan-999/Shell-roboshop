#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/Shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
   echo "ERROR:: Please run this Script with root privilege"
   exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
       echo -e "$2 ... $R FAILURE $ N" | tee -a $LOG_FILE
       exit 1
    else
       echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MYSQL Server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MYSQL Server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting MYSQL Server"

#mysql_secure_installation --set-root-pass Roboshop@1 &>>$LOG_FILE
#VALIDATE $? "Setting up root password"

mysql -uroot -pRoboShop@1 -e "show databases;" &>>$LOG_FILE
if [ $? -ne 0 ]; then
  mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
  VALIDATE $? "Setting up root password"
else
  echo -e "Root password already set ... ${Y}SKIPPING${N}"
fi

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script expected in: $Y $TOTAL_TIME seconds $N"
