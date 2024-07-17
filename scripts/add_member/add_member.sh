#!/usr/bin/env bash

# Set bash to exit
set -e

##############################
#                            #
#          VARIABLES         #
#                            #
##############################

epitech_email="$EPITECH_EMAIL"

jsreport_username="$JSREPORT_USERNAME"
jsreport_password="$JSREPORT_PASSWORD"

youtrack_token="$YOUTRACK_TOKEN"
mailcow_token="$MAILCOW_TOKEN"
infisical_token="$INFISICAL_TOKEN"
figma_token="$FIGMA_TOKEN"
gitea_token="$GITEA_TOKEN"
lucidchart_token="$LUCIDCHART_TOKEN"
coolify_token="$COOLIFY_TOKEN"

# Get epitech epitech email

if [ -z "$epitech_email" ]; then
    echo -n "Enter the epitech email of the user you want to add to the organization: "
    read epitech_email
fi

epitech_email=$(echo $epitech_email | tr '[:upper:]' '[:lower:]') # Lowercase the email

# check if @ is in the email, if not add it
if [[ ! $epitech_email == *"@"* ]]; then
    epitech_email="$epitech_email@epitech.eu"
fi

if [[ ! $epitech_email =~ ^[a-zA-Z0-9._%+-]+@epitech\.eu$ ]]; then
    echo "Invalid email"
    exit 1
fi

username=$(echo $epitech_email | cut -d'@' -f1) # Username for pld, youtrack
firstname=$(echo $epitech_email | cut -d'.' -f1) # Firstname
firstname=${firstname^} # Capitalize the first letter
lastname=$(echo $epitech_email | cut -d'.' -f2) # Lastname
lastname=${lastname^} # Capitalize the first letter
fullname="$firstname $lastname"

##############################
#                            #
#          FUNCTIONS         #
#                            #
##############################


function add_user_to_github()
{
    local org=Streetless
    local team=EnVRonment
    local team_id=10498894

    echo "Adding $epitech_email to $org/$team"

    gh api /orgs/$org/invitations -f "email=$epitech_email" -f "role=direct_member" -F "team_ids[]=$team_id"
}

function add_user_to_youtrack()
{
    if [ -z "$youtrack_token" ]; then
        echo -n "Enter the youtrack token: "
        read youtrack_token
    fi

    youtrack_uri="https://youtrack.envronment.com"
    youtrack_users_uri="$youtrack_uri/hub/api/rest/users"
    youtrack_eip_group_uri="$youtrack_uri/hub/api/rest/usergroups/e9926957-ba47-4e1c-b902-8e61b9dfe2b4/users"

    echo "Adding $epitech_email to Youtrack"
    res=$(curl -s -X POST -L "$youtrack_users_uri/invite?email=$epitech_email&fields=id%2Clogin&userType=STANDARD_USER&failOnPermissionReduce=true" \
    -H "Authorization: Bearer $youtrack_token")
    echo $res

    user_id=$(echo $res | jq -r '.[0].id')
    echo $user_id

    if [ -z "$user_id" ] || [ "$user_id" == "null" ]; then
        echo "Error while inviting user to Youtrack"
        exit 1
    fi

    echo "Rename $username with $fullname"
    curl -s -X POST -L "$youtrack_users_uri/$user_id?fields=id%2Clogin%2Cname%2Cprofile" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $youtrack_token" \
    -d "{ \"name\": \"$fullname\" }"

    echo "Add $epitech_email ($user_id) to EIP group"
    curl -s -X POST -L "$youtrack_eip_group_uri?failOnPermissionReduce=true&fields=login%2Cguest%2CcreationTime%2ClastAccessTime" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $youtrack_token" \
    -d "{\"id\": \"$user_id\"}"
}

function add_user_to_mailcow()
{
    if [ -z "$mailcow_token" ]; then
        echo -n "Enter the mailcow token: "
        read mailcow_token
    fi

    echo "Creating mailbox for "$username" with password "$username""
    curl -L -X POST 'https://mail.envronment.com/api/v1/add/mailbox' \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $mailcow_token" \
    -d "{
        \"local_part\": \"$username\",
        \"domain\": \"envronment.com\",
        \"name\": \"$fullname\",
        \"quota\": \"2048\",
        \"password\": \"$username\",
        \"password2\": \"$username\",
        \"active\": true,
        \"force_pw_update\": true,
        \"tls_enforce_in\": true,
        \"tls_enforce_out\": true
    }"
}

function add_user_to_figma()
{
    if [ -z "$figma_token" ]; then
        echo -n "Enter the figma token: "
        read figma_token
    fi
}

function add_user_to_lucidchart()
{
    if [ -z "$lucidchart_token" ]; then
        echo -n "Enter the lucidchart token: "
        read lucidchart_token
    fi
}

function add_user_to_gitea()
{
    if [ -z "$gitea_token" ]; then
        echo -n "Enter the gitea token: "
        read gitea_token
    fi
}

function add_user_to_jsreport()
{
    # Get jsreport admin account
    if [ -z "$jsreport_username" ]; then
        echo -n "Enter the jsreport admin username: "
        read jsreport_username
    fi

    if [ -z "$jsreport_password" ]; then
        echo -n "Enter the jsreport admin password: "
        read -s jsreport_password
    fi

    local jsreport_url="http://localhost:5488/"
    local jsreport_token=$(echo -n "$jsreport_username:$jsreport_password" | base64)
}

function main()
{
    local functions=(
        add_user_to_github
        add_user_to_youtrack
        add_user_to_mailcow
        add_user_to_figma
        add_user_to_lucidchart
        add_user_to_gitea
        add_user_to_jsreport
    )

    functionChoosen="$1"

    if [ -n "$functionChoosen" ]; then
        functionChoosen="add_user_to_$functionChoosen"

        if [[ ! " ${functions[@]} " =~ " ${functionChoosen} " ]]; then
            echo "Invalid function"
            exit 1
        fi

        $functionChoosen
        return
    fi

    for function in "${functions[@]}"; do
        $function
    done
}

main $@
