#!/usr/bin/env bash

infisical_token="$INFISICAL_TOKEN"
user_emails=(
    "hugo.baret@epitech.eu"
    "nicolas.julie@epitech.eu"
    "axel.medan@epitech.eu"
    "gaetan.kelechian@epitech.eu"
    "nicolas.reboule@epitech.eu"
    "quentin.robert@epitech.eu"
    "alexis.cheron@epitech.eu"
    "jonathan.albac@epitech.eu"
)
# List of projects name to blacklist (case sensitive but replace space with '_')
blacklisted_projects=() # Example: blacklisted_projects=("API" "Landing_Page")

emails=""

function format_emails()
{
    if [ ${#user_emails[@]} -eq 0 ]; then
        echo -n "Enter the emails of the users you want to add to the project (separated by a space): "
        read -a user_emails
    fi

    for email in "${user_emails[@]}"; do
        emails+="\"$email\","
    done
}

function listOfUserToBeAddedToProject()
{
    echo "List of user to be added to the project:"
    for email in "${user_emails[@]}"; do
        echo "- $email"
    done
    echo
}

function add_user_to_project()
{
    if [ -z "$infisical_token" ]; then
        echo -n "Enter the infisical token: "
        read infisical_token
    fi

    local infisical_uri="https://infisical.envronment.com"
    local infisical_orga_projects_uri="$infisical_uri/api/v2/organizations/7230a41f-3283-4be6-a496-5a8d1ee17afe/workspaces"

    local res=$(curl -s "$infisical_orga_projects_uri" -H "Authorization: Bearer $infisical_token")

    local project_Ids=($(echo $res | jq -r '.[] | .[] | .id'))
    local project_Names=($(echo $res | jq -r '.[] | .[] | .name' | tr ' ' '_'))

    for i in ${!project_Ids[@]}; do
        if [[ " ${blacklisted_projects[@]} " =~ " ${project_Names[$i]} " ]]; then
            continue
        fi

        echo "Project ${project_Names[$i]} (${project_Ids[$i]}):"

        local infisical_project_members_uri="$infisical_uri/api/v2/workspace/${project_Ids[$i]}/memberships"
        curl -s -L -X POST "$infisical_project_members_uri" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $infisical_token" \
        --data-raw "{
            \"emails\": [ ${emails::-1} ]
        }"
        echo -e "\n\n"
    done
}

format_emails
listOfUserToBeAddedToProject
add_user_to_project