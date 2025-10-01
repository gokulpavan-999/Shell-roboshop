#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/Shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
MYSQL_HOST=mysql.pavandevops.fun
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo -e "Script started executed at: $(date)" | tee -a $LOG_FILE

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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven"

id roboshop &>>$LOG_FILE
  if [ $? -ne 0 ]; then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
     VALIDATE $? "Creating User"
  else
    echo -e "User already exists ... $Y SKIPPING $N"
  fi

mkdir /app &>>$LOG_FILE
VALIDATE $? "Create app directory"
  
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Download shipping Application"

cd /app 
VALIDATE $? "Change to app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "Remove existing code"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Unzip shipping"

mvn clean package &>>$LOG_FILE
mv target/shipping-1.0.jar shipping.jar 

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
systemctl daemon-reload
systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling shipping"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MYSQL"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
  if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
  else
    echo -e "Shipping Data is already loaded ... $Y SKIPPING $N"
  fi

systemctl restart shipping 
VALIDATE $? "Restarted Shipping"

  
