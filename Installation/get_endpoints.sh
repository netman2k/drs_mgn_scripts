#!/bin/bash
set -e

function usage(){
  echo "Usage: `basename $0` [parameters]"
  echo
  echo "Parameters:"
  printf "\t-r \t--region:        Enabled service region (default: eu-central-1)\n"
  printf "\t-s \t--service:       Type of service - MGN or DRS (default: DRS)\n"
  printf "\t-h \t--help:          Show help of this command\n"
  echo
  echo "Example:"
  printf "\t`basename $0`\n"
  printf "\t`basename $0` --region eu-central-1 --service MGN\n"
  echo
  exit 2
}

function main(){

  # parse getopts options
  local tmp_getopts=`getopt -o h,s:,r: --long help,service:,region:, -- "$@"`
  eval set -- "$tmp_getopts"

  while true; do
      case "$1" in
          -h|--help)                usage;;
          -s|--service)             service=$2;    shift 2;;
          -r|--region)              region=$2;     shift 2;;
          --) shift; break;;
          *) usage;;
      esac
  done

  [ -z $service ] && service="DRS"
  [ -z $region ] && region="eu-central-1"

  printf "Region: ${region}\n"
  printf "Service: ${service}\n\n"

  local endpoint_dnsnames=($(aws ec2 describe-vpc-endpoints --region $region --filters Name=service-name,Values=com.amazonaws.${region}.${service,,}  --query 'VpcEndpoints[*].DnsEntries[*].DnsName' --output text))

  #printf "Endpoint DNS names:\n"
  for dnsname in "${endpoint_dnsnames[@]}"
  do 
    printf "${dnsname}\n"
  done

}

main "$@"
