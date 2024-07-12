#!/usr/bin/env bash

# Get epitech epitech email

echo -n "Enter the epitech email of the user you want to add to the organization: "
read email

# Get youtrack token

# Get mailcow token

# Get infisical token

# Get figma token

# Get lucidchart token

# Get gitea token

# Get coolify token

username=$(echo $email | cut -d'@' -f1) # Username for pld, youtrack

# Add user to our github organization

org=Streetless
team=EnVRonment
team_id=10498894

echo "Adding $email to $org/$team"

gh api /orgs/$org/invitations -f "email=$email" -f "role=direct_member" -F "team_ids[]=$team_id"

# Create a new user in our pld

