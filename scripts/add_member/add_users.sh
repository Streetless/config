#!/usr/bin/env bash

user_emails=(
    "alwyn.mattapullut"
    "anthony.vienne"
    "hugo.baret"
    "nicolas.julie"
    "axel.medan"
    "gaetan.kelechian"
    "nicolas.reboule"
    "quentin.robert"
    "alexis.cheron"
    "jonathan.albac"
)

for email in "${user_emails[@]}"; do
    echo "Adding $email to the project tools"

    export EPITECH_EMAIL="$email"
    ./add_member.sh jsreport
done