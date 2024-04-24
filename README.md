# WireMock Cloud API Cleanup By Response Code Tool
This bash script utility deletes all stubs within a given WireMock Cloud API that have a given response code.
It is especially useful when a proxy recording was used to add new stubs, but the recorder was configured incorrectly
resulting in many stubs being added with 4xx or 5xx response codes.

If any stubs are found with the configured response code, the Mock API will first be exported to a local file for
backup purposes.  The backfile will contain the name of the Mock API and a date/time stamp.

## Requirements
- bash shell
- curl
- jq
- sed

## Steps to use
1. Save a copy of `mockAPIcleanByRspCode.sh`
2. Make the file executable `chmod +x mockAPIcleanByRspCode.sh`
3. Edit the script in your preferred text editor
   - replace `<your mock api url base>` with the url prefix for the WireMock Cloud mock API you want to affect
   - replace `<email address of user with write access to the mock api>` with your WireMock Cloud user email address
   - replace `<user's API token>` with your API token taken from https://app.wiremock.cloud/account/api
   - <optional> replace `501` with a different http status code that you would like to target for deletion
   - save and exit
4. Run the script `./mockAPIcleanByRspCode.sh`
