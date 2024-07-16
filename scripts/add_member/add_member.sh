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
}


function add_user_to_mailcow()
{
    if [ -z "$mailcow_token" ]; then
        echo -n "Enter the mailcow token: "
        read mailcow_token
    fi
}

function add_user_to_infisical()
{
    if [ -z "$infisical_token" ]; then
        echo -n "Enter the infisical token: "
        read infisical_token
    fi
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

function add_user_to_coolify()
{
    if [ -z "$coolify_token" ]; then
        echo -n "Enter the coolify token: "
        read coolify_token
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

    jsreport_token=$(echo -n "$jsreport_username:$jsreport_password" | base64)
}

function main()
{
    local functions=(
        add_user_to_github
        add_user_to_youtrack
        add_user_to_mailcow
        add_user_to_infisical
        add_user_to_figma
        add_user_to_lucidchart
        add_user_to_gitea
        add_user_to_coolify
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
