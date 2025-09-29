#!/bin/bash

USERID=(id - u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/Shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDEF/$SCRIPT_NAME.log" # /var/log/Shell-roboshop/16.logs.log

START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee - a $LOG_FILE

if [ $USERID -ne 0 ]; then
   echo "ERROR:: Please run with root privilege"
   exit 1
fi

VALIDATE(){
  if [ $1 -ne 0 ]; then
     echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
  else
    echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
  fi
}

#####redis#####
dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabled Default Redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enable redis"

dnf install redis -y &>>$LOG_FILEe
VALIDATE $? "Install redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections to redis"

systemctl enable redis
VALIDATE $? "Enable redis"

systemctl start redis
VALIDATE $? "Start redis"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME $N"
