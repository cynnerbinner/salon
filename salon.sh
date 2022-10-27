#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~~ My Salon ~~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"
MAIN_MENU() {
  if [[ $1 ]]
    then
    echo -e "\n$1" 
  fi
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
    echo "$SERVICE_ID) $SERVICE_NAME"
    done
  SERVICE_SELECTION
}

SERVICE_SELECTION(){
  read SERVICE_ID_SELECTED
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID ]]
    then
    MAIN_MENU "I could not find that service. What would you like today?"
    else
    CUSTOMER_INFO
  fi
}

CUSTOMER_INFO() {
  echo -e "\n What's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
    then
    echo -e "\nI don't have a record for that phone number. What is your name?"
    read CUSTOMER_NAME
    NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
    fi
    APPOINTMENT
}

APPOINTMENT(){
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME| sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME| sed -E 's/^ *| *$//g')."
}

MAIN_MENU
