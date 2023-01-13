#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "
echo -e "\n~~~~~ MY SALON ~~~~~\n"
MAIN_MENU() {
  # Check everything is ok
 if [[ $1 ]]
 then
  echo -e "\$1"
 fi
  echo "Welcome to My Salon, how can I help you?"
  # Get availability service from the db
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY SERVICE_ID")
  # Display a list of the availability services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
  echo -e "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  if [[ -z $SERVICE ]]
  then
  MAIN_MENU "I could not find that service. What would you like today?"
  else
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # Look for the phone number in the db
  FIND_PHONE=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # If phone is not in the db
  if [[ -z $FIND_PHONE ]]
  then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # Put name and phone_number in customer table
  INSERT_NAME=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  else
  # get the name associated to that phone number
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
  echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME"
  read SERVICE_TIME
  # Get customer_id from customer table
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE' AND name = '$CUSTOMER_NAME'")
  # Put the new appointment line in Appointments table
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}
MAIN_MENU
