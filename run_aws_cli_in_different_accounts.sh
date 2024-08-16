#!/bin/bash

run_this_command () {

  account_id=$1
  account_name=$2
  role_name=$3

#________________________________________________________________________________________
#________________________________________________________________________________________

  echo "-------------------------------------------------------------------"
  echo "Going to run a command on ${account_id}. ${account_name}, using the role: ${role_name}"
  
  #Assume a role in the account
  new_role=$(aws sts assume-role --role-arn "arn:aws:iam::${account_id}:role/${role_name}" --role-session-name "${account_id}-${role_name}")

  echo -e "[default]\naws_access_key_id=$(echo ${new_role} | jq -r '.Credentials.AccessKeyId')\naws_secret_access_key=$(echo ${new_role} | jq -r '.Credentials.SecretAccessKey')\naws_session_token=$(echo ${new_role} | jq -r '.Credentials.SessionToken')" > ~/.aws/credentials

  # aws sts get-caller-identity
  echo "Got Key ID for ${account_id}, ${account_name}"

###########################################################################################################################
  echo "Executing operations in Account :: ${account_name} ......"
  # Put YOUR AWS CLI Commands here........

  for region in us-east-1 us-east-2 ap-east-1 eu-central-1; do
    aws lambda list-functions --function-version ALL --region $region --output table --query "Functions[?Runtime=='python3.7'].FunctionArn"
  done


###########################################################################################################################

  echo -e "" > ~/.aws/credentials
}

########################## Main ###################################
###################################################################

#________________________________________________________________________________________
#________________________________________________________________________________________

mkdir ~/.aws/
role_name="IAM-CA-CICD-Deployment-Execution-Role"

for account in $(cat ./work-on-this-list-of-accounts.txt | tr -d '"'); do

  # Sample account result: "000123456789;my-aws-account-name"
  account_id=$(echo ${account} | cut -f1 -d ';' )
  account_name=$(echo ${account} | cut -f2 -d ';' )


  echo "-------------------------------------------------------------------"
  echo "Getting ready to run a command on this account : ${account_id}; ${account_name}"
  run_this_command ${account_id} ${account_name} ${role_name}
  echo "Exiting from this account : ${account_id}; ${account_name}"
  echo "-------------------------------------------------------------------"
done

rm -rf ~/.aws/

###################################################################

###################################################################
<< ////

HOW TO RUN

# list all account id and account name under single organization
# aws organizations list-accounts > list-of-accounts-in-org.txt
# jq -r '.Accounts[] | "\(.JoinedTimestamp);\(.Id);\(.Name)" ' ./list-of-accounts-in-org.txt  | sort | awk -F ';' '{print $2 ";" $3}' > work-on-this-list-of-accounts.txt



sh run_aws_cli_in_different_accounts.sh

////