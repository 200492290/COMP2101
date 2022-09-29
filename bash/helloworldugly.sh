#!/bin/bash
# helloworldugly.sh - an exercise in obfuscation
# This script displays the string “Hello World!”
#   and then displays its PID

# Function Definitions
function output-string { echo "$*"; }

# Main Script Body
# This is a silly way of creating the output text
# We start with similar text and stream edit it in a pipeline
# This is a trivial form of code obfuscation
# This version might require installing rot13 first
which rot13 >/dev/null || sudo apt install rot13
output-string $(rot13 <<< "uryo jbyq" |
    sed -e "s/b/o/g" -e "s/l/ll/" -e "s/ol/orl/" |
    tr "h" "H"|tr "w" "W"|
    awk '{print $1 "\x20" $2 "\41"}')
bc <<< "(($$ * 4 - 24)/2 + 12)/2" |
    sed 's/^/I am process # /'
