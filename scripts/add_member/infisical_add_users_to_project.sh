#!/usr/bin/env bash

# Personal access token for infisical
infisical_token="$INFISICAL_TOKEN"
# Email list of accepted users.
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
# List of project names to blacklist (case sensitive but replace space with '_')
blacklisted_projects=() # Example: ("API" "Landing_Page")

# Do not edit below this line, unless you know what you are doing
emails=""
infisical_uri="https://infisical.envronment.com"
org_id="7230a41f-3283-4be6-a496-5a8d1ee17afe"

function warning_emails()
{
    local infisical_orga_users_uri="$infisical_uri/api/v1/organization/$org_id/users"

    local res=$(curl -s -L "$infisical_orga_users_uri" -H "Authorization: Bearer $infisical_token")
    local refused_emails=$(echo $res | jq -r '.[] | .[] | select(.status == "invited").user.email')
    local triggered_emails=()

    for email in "${user_emails[@]}"; do
        if [[ " $refused_emails" =~ "$email" ]]; then
            triggered_emails+=("$email")
        fi
    done

    if [[ ${#triggered_emails[@]} -gt 0 ]]; then
        echo "/!\\ Warning /!\\"
        echo "Some emails in the user list that you want to add are still invited."
        echo "Here is the list of emails that cannot be added to the project:"
        for email in "${triggered_emails[@]}"; do
            echo "- $email"
        done
        echo "Please remind them to accept the invitation and try again (or remove them from the list)."
        exit 1
    fi
}

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

function list_of_user_to_be_added_to_projects()
{
    echo "List of user to be added to the project:"
    for email in "${user_emails[@]}"; do
        echo "- $email"
    done
    echo
}

function remind_blacklisted_project()
{
    if [ ${#blacklisted_projects[@]} -gt 0 ]; then
        echo "The following projects are blacklisted:"
        for project in "${blacklisted_projects[@]}"; do
            echo "- $project"
        done
        echo
    fi

}

function add_user_to_project()
{
    if [ -z "$infisical_token" ]; then
        echo -n "Enter the infisical token: "
        read infisical_token
    fi

    local infisical_orga_projects_uri="$infisical_uri/api/v2/organizations/$org_id/workspaces"

    local res=$(curl -s "$infisical_orga_projects_uri" -H "Authorization: Bearer $infisical_token")

    local project_ids=($(echo $res | jq -r '.[] | .[] | .id'))
    local project_names=($(echo $res | jq -r '.[] | .[] | .name' | tr ' ' '_'))

    remind_blacklisted_project

    for i in ${!project_ids[@]}; do
        if [[ " ${blacklisted_projects[@]} " =~ " ${project_names[$i]} " ]]; then
            continue
        fi

        echo "Project ${project_names[$i]} (${project_ids[$i]}):"

        local infisical_project_members_uri="$infisical_uri/api/v2/workspace/${project_ids[$i]}/memberships"
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
warning_emails
list_of_user_to_be_added_to_projects
add_user_to_project