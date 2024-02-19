#!/bin/bash

# Define the psql command with connection parameters
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Function to display element information
DISPLAY_ELEMENT_INFO() {
    # Query the database for element information
    ELEMENT_INFO=$($PSQL "SELECT elements.name, elements.symbol, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type FROM elements JOIN properties ON elements.atomic_number = properties.atomic_number JOIN types ON properties.type_id = types.type_id WHERE elements.atomic_number = '$1';")

    # Check if element information is found
    if [ -z "$ELEMENT_INFO" ]; then
        echo "I could not find that element in the database."
    else
        # Extract information from the query result
        IFS='|' read -ra ELEMENT_INFO_ARRAY <<<"$ELEMENT_INFO"
        NAME="${ELEMENT_INFO_ARRAY[0]}"
        SYMBOL="${ELEMENT_INFO_ARRAY[1]}"
        MASS="${ELEMENT_INFO_ARRAY[2]}"
        MELTING_POINT="${ELEMENT_INFO_ARRAY[3]}"
        BOILING_POINT="${ELEMENT_INFO_ARRAY[4]}"
        TYPE="${ELEMENT_INFO_ARRAY[5]}"

        # Display the element information
        echo -n "The element with atomic number $1 is $NAME ($SYMBOL). "
        echo -n "It's a $TYPE, with a mass of $MASS amu. "
        echo "$NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    fi
}

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide an element as an argument."
else
    input="$1"

    # Check if the input is numeric
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        DISPLAY_ELEMENT_INFO "$input"
    else
        # Query the database for the atomic number of the element based on the symbol
        ATOMIC_NUMBER_SYMBOL=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$input';")

        # Query the database for the atomic number of the element based on the name
        atomic_number_name=$($PSQL "SELECT atomic_number FROM elements WHERE name ILIKE '%$input%';")

        # Check if the symbol or name exists in the database
        if [ -n "$ATOMIC_NUMBER_SYMBOL" ]; then
            DISPLAY_ELEMENT_INFO "$ATOMIC_NUMBER_SYMBOL"
        elif [ -n "$atomic_number_name" ]; then
            DISPLAY_ELEMENT_INFO "$atomic_number_name"
        else
            echo "I could not find that element in the database."
        fi
    fi
fi
