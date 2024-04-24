#!/bin/bash

# Exit on the first command that returns a nonzero code.
set -e

# Requirements:
# curl, jq, sed

# User Defined Variables
wiremock_url="<your mock api url base>"  # example: https://mymockapi.wiremockapi.cloud/
username="<email address of user with write access to the mock api>"  # example: dan@wiremock.io
api_token="<user's API token>" # example: 98bc20ca8d97830cce47aa8cb278fe36
response_code="501" # stubs with this response code will be deleted

# Function that checks if a given executable is on the path. If it isn't, prints an install message and exits.
# Usage: check_binary EXECUTABLE_NAME INSTALL_MESSAGE
check_binary() {
  if ! which "$1" > /dev/null; then
    # Using a subshell to redirect output to stderr. It's cleaner this way and will play nice with other redirects.
    # https://stackoverflow.com/a/23550347/225905
    ( >&2 echo "$2" )
    # Exit with a nonzero code so that the caller knows the script failed.
    exit 1
  fi
}

check_binary "jq" "$(cat <<EOF
You will need jq to run this script.
Install it using your package manager. E.g. for homebrew:
brew install jq
EOF
)"

# a dumb command that uses jq in order to provide a SSCCE snippet
# http://sscce.org/
jq -r ".message"  >> /dev/null <<EOF
{"message": "hello from jq!"}
EOF

# Get all stubs with a requested response code
stubs=$(curl -s -H "Authorization:Token $api_token" "${wiremock_url}__admin/mappings" | jq -r '.mappings[] | select(.response.status == '"$response_code"') | .id')

# Check if stubs is empty
if [ -z "$stubs" ]; then
  echo "No stubs with a $response_code response status found."
  exit 0
fi

# Save export of mock API to local disk before any delete actions
mockName=$(echo $wiremock_url | sed -e 's/https*:\/\///; s/\.*[^\.]*\.[^\.]*$//; s/^$/null/; s/\./ /g')
backupName=$mockName-$(date +"%FT%H%M%S").json.bak
echo "Creating backup export named $backupName"
curl -s --output $backupName -H "Authorization:Token $api_token" "${wiremock_url}__admin/mappings"

# Delete each stub with matching response code
echo "Deleting stubs with a $response_code response status..."
for stub_id in $stubs; do
  curl -s -o /dev/null -H "Authorization:Token $api_token" -X DELETE "${wiremock_url}__admin/mappings/$stub_id"
  echo "Deleted stub with ID: $stub_id"
done

echo "All done!"