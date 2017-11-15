#!/bin/bash

set -ex
set -o pipefail

 echo " Declaring environment variables"

declare_env_variables() {
  DEPLOYMENT_ENVIRONMENT="staging"
  CIRCLE_PROJECT_REPONAME="test-pipeline"

  TF_VAR_state_path=
  image_name=

  EMOJIS=(":celebrate:"  ":party_dinosaur:"  ":andela:" ":aw-yeah:" ":carlton-dance:" ":partyparrot:" ":dancing-penguin:" ":aww-yeah-remix:" )
  RANDOM=$$$(date +%s)
  EMOJI=${EMOJIS[$RANDOM % ${#EMOJIS[@]} ]}
  COMMIT_LINK="https://github.com/scott45/${CIRCLE_PROJECT_REPONAME}/commit/${CIRCLE_SHA1}"
  DEPLOYMENT_TEXT="Tag: ${IMG_TAG} has just been deployed to ${CONTAINER_NAME} in ${DEPLOYMENT_ENVIRONMENT}  $COMMIT_LINK "
  SLACK_DEPLOYMENT_TEXT="Tag: <$COMMIT_LINK|${IMG_TAG}> has just been deployed to *${CONTAINER_NAME}* in *${DEPLOYMENT_ENVIRONMENT}* ${EMOJI}"
  DEPLOYMENT_CHANNEL="vof-devops"
}

echo " Pull repo with packer image"
check_out_to_code() {
    git remote add origin -f https://github.com/FlevianK/vof-terraform.git
    git config core.sparsecheckout true
    echo "vof/*" >> .git/info/sparse-checkout"
    git pull origin master
}

echo " Rebuilding packer image"
build_packer_image() {

}

echo " Filtering new packer image name"

sort_and_pick_out_packer_built_image_name() {
    image_name=$(grep -e "A disk image was created:" packer_ouput.txt | cut -d ' ' -f8) # command will go here for sorting out and assigning the name to a variable which will be used in the terraform command
}

echo " Initializing terraform"

Initialise_terraform() {
    terraform init -backend-config="path=$TF_VAR_state_path"
}

echo " Running terraform plan command"

terraform_plan() {
    terraform plan -var="vof_disk_image=$image_name" -var="state_path=$TF_VAR_state_path"
}

echo " Building infrastructure"

build_infrastructure() {
    terraform apply -var="vof_disk_image=$image_name" -var="state_path=$TF_VAR_state_path"
}

echo " Deploying to ${DEPLOYMENT_ENVIRONMENT}"
deploy_to_environment() {

}

echo " Turning off error checking"

turn_off_error_checking() {
    set +e
}

echo " Collecting deployment logs"
saving_deployment_logs() {

}

# echo " Ensuring monitoring is up"
# restart_monitoring_process() {

# }

echo " Sending slack to vof-channel"

notify_vof_team_via_slack() {
curl -X POST --data-urlencode \
"payload={\"channel\": \"${DEPLOYMENT_CHANNEL}\", \"username\": \"DeployNotification\", \"text\": \"${SLACK_DEPLOYMENT_TEXT}\", \"icon_emoji\": \":rocket:\"}" \
https://hooks.slack.com/services/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
}

main() {
  echo "Deployment script invoked at $(date)" >> /tmp/script.log

  declare_env_variables
  check_out_to_code
  build_packer_image
  sort_and_pick_out_packer_built_image_name
  Initialise_terraform
  terraform_plan
  build_infrastructure
  deploy_to_environment
  turn_off_error_checking
  saving_deployment_logs
  notify_vof_team_via_slack

}

main "$@"

