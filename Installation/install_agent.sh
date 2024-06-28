#!/bin/bash
set -e

declare -r INSTALLER_URL="https://aws-elastic-disaster-recovery-us-east-1.s3.us-east-1.amazonaws.com/latest/linux/aws-replication-installer-init"

function install_agent(){
  local region=$1
  local access_key_id=$2
  local secret_access_key=$3
  local session_token=$4
  
	curl -o aws-replication-installer-init $INSTALLER_URL
	chmod +x aws-replication-installer-init

	sudo ./aws-replication-installer-init --region $region \
	--aws-access-key-id "${access_key_id}" \
	--aws-secret-access-key "${secret_access_key}" \
	--aws-session-token "${session_token}" \
	--no-prompt

}

function usage(){
  echo "Usage: `basename $0` [parameters]"
  echo
  echo "Parameters:"
  printf "\t-r \t--region:        Enabled service region (default: eu-central-1)\n"
  printf "\t-o \t--role:          Role name to assume for the installation (default: <Service>_AgentInstallationRole)\n"
  printf "\t-s \t--service:       Type of service - MGN or DRS (default: DRS)\n"
  printf "\t-e \t--endpoint:      Service Endpoint Interface\n"
  printf "\t-3 \t--s3-endpoint:   S3 Endpoint Interface\n"
  printf "\t-h \t--help:          Show help of this command\n"
  echo
  echo "Example:"
  printf "\t`basename $0`\n"
  printf "\t`basename $0` --service MGN\n"
  printf "\t`basename $0` --account 123412341234 --region eu-west-1 --service DRS --role DRS_AgentInstallationRole\n"
  echo
  exit 2
}

function main(){

  # parse getopts options
  local tmp_getopts=`getopt -o h,s,r,o,e,3 --long help,service:,region:role:endpoint:s3-endpoint: -- "$@"`
  eval set -- "$tmp_getopts"

  while true; do
      case "$1" in
          -h|--help)                usage;;
          -s|--service)             service=$2;    shift 2;;
          -r|--region)              region=$2;     shift 2;;
          -o|--role)                role=$2;       shift 2;;
          -e|--endpoint)            endpoint=$2;   shift 2;;
          -3|--s3-endpoint)         s3_endpoint=$2;   shift 2;;
          --) shift; break;;
          *) usage;;
      esac
  done

  [ -z $service ] && service="DRS"
  [ -z $region ] && region="eu-central-1"
  [ -z $role] && role="${service}_AgentInstallationRole"

  printf "Region: ${region}\n"
  printf "Service: ${service}\n"
  printf "Role: ${role}\n"

  local account=$(aws sts get-caller-identity --query 'Credentials.Account')

  local values=($(aws sts assume-role --role-arn arn:aws:iam::${account}:role/${role} --role-session-name ${service}_agent_installation --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text))

  install_agent "${region}" "${values[0]}" "${values[1]}" "${values[2]}"
  
  # clean up
  
}

main "$@"
