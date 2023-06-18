#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Avenue Salon ~~~~~\n"

MAIN_MENU() {

    if [[ $1 ]]
    then
        echo -e "\n$1"
    else
        echo -e "\nWelcome, how can I help you?"
    fi
    
    AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services;")
    echo "$AVAILABLE_SERVICES" | sed 's/ |/)/'

    read SERVICE_ID_SELECTED

    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
        MAIN_MENU "You should insert a number as service. Try again.\nHow can I help you?"
    else
        SELECTED_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
        if [[ -z $SERVICE_ID_SELECTED ]]
        then
            MAIN_MENU "I could not find that service. How can I help you?"
        else
            echo -e "\nWhat's your phone number?"
            read CUSTOMER_PHONE

            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
            if [[ -z $CUSTOMER_NAME ]]
            then
                echo -e "\nI don't have a record for that phone number, what's your name?"
                read CUSTOMER_NAME

                INSERTED_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
            fi

            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
            SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

            echo -e "\nWhat time you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
            read SERVICE_TIME

            INSERTED_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

            echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
        fi
    fi
}

MAIN_MENU