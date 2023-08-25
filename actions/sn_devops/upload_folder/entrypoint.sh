#!/bin/bash

function create_changeset()
{
  request_url="${sn_instance}/api/sn_cdm/changesets/create?appName=$1"

  if [[ $? -eq 2 ]] && [[ $2 != "" ]]; then
    request_url="${request_url}&description=$2"
  fi

  response=$(curl -s -X POST ${request_url} -u ${sn_user}:${sn_password})

  changeset_id=$(echo ${response}|jq -r ".result.number")
  echo "changeset=${changeset_id}" >> $GITHUB_OUTPUT
  echo ${changeset_id}
}

function commit_changeset()
{
  request_url="${sn_instance}/api/sn_cdm/changesets/commit?autoValidate=$1&publishOption=$2&changesetNumber=$3"
  response=$(curl -s -X PUT ${request_url} -u ${sn_user}:${sn_password})

  commit_id=$(echo ${response}|jq -r ".result.commit_id")

  check_commit_status ${commit_id}
}

function check_commit_status()
{
  request_url="${sn_instance}/api/sn_cdm/changesets/commit-status/$1"
  counter=0
  state="new"

  while [[ ${state} != "completed" ]] && [[ ${counter} -lt 30 ]]; do
    response=$(curl -s -X GET ${request_url} -u ${sn_user}:${sn_password})
    echo ${response}
    counter=$((counter+1))
    state=$(echo ${response}|jq -r ".result.state")
    sleep 1
  done
}

function get_snapshot_validation_status()
{
  request_url="${sn_instance}/api/now/table/sn_cdm_snapshot?sysparm_query=changeset_id.number=$1"
  response=$(curl -s -X GET ${request_url} -u ${sn_user}:${sn_password})
  status="not_validated"
  errors_found=0
  declare -A errors

  while [[ ${status} == "not_validated" ]]; do
    status="validated"
    response=$(curl -s -X GET ${request_url} -u ${sn_user}:${sn_password})
    for row in $(echo ${response}|jq -r ".result[]| @base64"); do
      _jq() {
        echo ${row}| base64 -d | jq -r ${1}
      }
      validation_status=$(_jq ".validation")
      snapshot=$(_jq ".name")

      echo "Validation status for snapshot ${snapshot}: ${validation_status}"
      if [[ ${validation_status} == "not_validated" ]] || [[ ${validation_status} == "in_progress" ]]; then
        status="not_validated"
      elif [[ ${validation_status} == "failed" ]]; then
        errors_found=1
        errors[${snapshot}]=${validation_status}
      fi
    done
    sleep 1
  done

  if [[ ${errors_found} -eq 1 ]]; then
    for snapshot in ${!errors[@]}; do
      echo "Validation failed for snapshot ${snapshot} with following errors:"
      policy_url="${sn_instance}/api/now/table/sn_cdm_policy_validation_result?sysparm_query=snapshot.name%3D${snapshot}%5Etype%3Dfailure%5Esnapshot.cdm_application_id.name%3D$2&sysparm_fields=policy.name%2Cdescription%2Cnode_path"
      policy_response=$(curl -s -X GET ${policy_url} -u ${sn_user}:${sn_password})
      echo ${policy_response}|jq -r ".result[]"
    done

    echo "Aborting..."
    exit 1
  fi

  echo ${response}
}

function check_upload_status()
{
  request_url="${sn_instance}/api/sn_cdm/applications/upload-status/$1"
  response=$(curl -s -X GET ${request_url} -u ${sn_user}:${sn_password})
  state=$(echo ${response}|jq -r ".result.state")

  counter=0

  while [[ ${counter} -lt 30 ]] && [[ ${state} != "completed" ]]; do
    response=$(curl -s -X GET ${request_url} -u ${sn_user}:${sn_password})
    echo ${response}
    state=$(echo ${response}|jq -r ".result.state")

    if [[ ${state} == "error" ]]; then
      echo "Error encountered during upload process:"
      echo ${response}|jq -r ".result.output"
      echo "Aborting..."
      exit 1
    fi

    sleep 1
  done
}

function upload()
{
  case $1 in
    "component")
      request_url="$sn_instance/api/sn_cdm/applications/uploads/components?appName=$2&dataFormat=$3&autoCommit=false&autoValidate=false&publishOption=publish_none&changesetNumber=$6&namePath=$7"
      file=$5
      name_path=$7
      ;;
    "collection")
      request_url="$sn_instance/api/sn_cdm/applications/uploads/collections?appName=$3&collectionName=$2&dataFormat=$4&autoCommit=false&autoValidate=false&publishOption=publish_none&changesetNumber=$7&namePath=$8"
      file=$6
      name_path=$8
      ;;
    "deployable")
      request_url="$sn_instance/api/sn_cdm/applications/uploads/deployables?appName=$3&deployableName=$2&dataFormat=$4&autoCommit=false&autoValidate=false&publishOption=publish_none&changesetNumber=$7&namePath=$8"
      file=$6
      name_path=$8
      ;;
    *)
      echo "Target should be 1 of: component, collection or deployable, $1 provided.  Aborting..."
      exit 1
  esac

  echo "Uploading file ${file} to name path ${name_path}"
  response=$(curl -s -X PUT ${request_url} -u $sn_user:$sn_password -H "Content-Type: text/plain" --data-binary @$file)
  echo ${response}
  upload_id=$(echo ${response}|jq -r ".result.upload_id")
  
  check_upload_status ${upload_id}
}

function tfconvert()
{
echo "Converting $1 to json for upload"
sed -ie '/^[ \t]*#/d' $1 #removing comments
/yj -cj < $1 >temp.json
cp temp.json $1
}


declare sn_instance=$1
declare sn_user=$2
declare sn_password=$3

echo "Uploading files with extension $9 from folder $7 into application $4, recursive: $8"

if [[ $8 == "false" ]]; then
  echo "Finding NON-RECURSIVELY"
  files=($(find $7 -maxdepth 1 -name "*.$9"))
else
  echo "Finding RECURSIVELY"
  files=($(find $7 -name "*.$9"))
fi

changeset=$(create_changeset $4)

for file in ${files[@]}; do
  echo ${file}
    if [[ $9 == "tfvars" ]]; then
    tfconvert $file
    format="json"
    else
    format=$9
    fi
  file_path=$(echo ${file}|sed -r 's/^\.\///'|sed -r 's/\//%2F/g')
  name_path="${13}${file_path}"
  cat $file
  echo ${format}
  upload $5 $6 $4 ${format} ${12} ${file} ${changeset} ${name_path}
done

if [[ ${10} == "true" ]]; then
  commit_changeset ${11} ${12} ${changeset}
  if [[ ${11} == "true" ]]; then
    get_snapshot_validation_status ${changeset} $4
  fi
fi
