#!/bin/bash

all_args=("$@")
job_type=$1                     #example: workflow_job_templates | job_templates
job_id=$2                       #example: 40
#json_data=("${all_args[@]:2}") #example: "{"P1": "Colgan"}"
json_data=./ansible-api-call-data.json

tower_api=https://hdc-lnx-vs-0040.int.8451.com/api/v2
token_file=./ansible-api-token.json

echo "[*] making api calls using these parms..."
echo "[.] job_type: $job_type"
echo "[.] job_id: $job_id"
echo "[.] json_data: $(cat $json_data)"
echo;echo

## get a token for the api-user
echo;echo "[*] retreiving token"
curl -s -k -H "Content-Type: application/json" -X POST -u api-user:8451ansiblE -d '{"description":"Template Launch Token", "application":null, "scope":"write"}' "${tower_api}/tokens/" > $token_file

## (OPTIONAL) use token to query the job|workflow template details
echo;echo "[*] retreiving job info"
curl -s -k -H "Authorization: Bearer $(jq -r .token ansible-api-token.json)" -H "Content-Type: application/json" -X GET "${tower_api}/${job_type}/${job_id}/launch/"
#output example
#{"ask_inventory_on_launch":false,"ask_limit_on_launch":false,"ask_scm_branch_on_launch":false,"can_start_without_user_input":true,"defaults":{"extra_vars":"---\nP1: Kolik","inventory":{"name":"Demo Inventory","id":1},"limit":null,"scm_branch":null},"survey_enabled":false,"variables_needed_to_start":[],"node_templates_missing":[],"node_prompts_rejected":[],"workflow_job_template_data":{"name":"demo-workflow-facts","id":40,"description":""},"ask_variables_on_launch":true} 

## execute the workflow
echo;echo "[*] invoking job execution"
curl -s -k -H "Authorization: Bearer $(jq -r .token ansible-api-token.json)" -H "Content-Type: application/json" -X POST  -d @$json_data "${tower_api}/${job_type}/${job_id}/launch/"
#output example
#{"workflow_job":655,"ignored_fields":{},"id":655,"type":"workflow_job","url":"/api/v2/workflow_jobs/655/","related":{"created_by":"/api/v2/users/5/","modified_by":"/api/v2/users/5/","unified_job_template":"/api/v2/workflow_job_templates/40/","workflow_job_template":"/api/v2/workflow_job_templates/40/","notifications":"/api/v2/workflow_jobs/655/notifications/","workflow_nodes":"/api/v2/workflow_jobs/655/workflow_nodes/","labels":"/api/v2/workflow_jobs/655/labels/","activity_stream":"/api/v2/workflow_jobs/655/activity_stream/","relaunch":"/api/v2/workflow_jobs/655/relaunch/","cancel":"/api/v2/workflow_jobs/655/cancel/"},"summary_fields":{"inventory":{"id":1,"name":"Demo Inventory","description":"","has_active_failures":false,"total_hosts":1,"hosts_with_active_failures":0,"total_groups":0,"has_inventory_sources":false,"total_inventory_sources":0,"inventory_sources_with_failures":0,"organization_id":1,"kind":""},"workflow_job_template":{"id":40,"name":"demo-workflow-facts","description":""},"unified_job_template":{"id":40,"name":"demo-workflow-facts","description":"","unified_job_type":"workflow_job"},"created_by":{"id":5,"username":"api-user","first_name":"api-user","last_name":"api-user"},"modified_by":{"id":5,"username":"api-user","first_name":"api-user","last_name":"api-user"},"user_capabilities":{"delete":null,"start":true},"labels":{"count":3,"results":[{"id":3,"name":"facts"},{"id":2,"name":"mp"},{"id":1,"name":"workflow"}]}},"created":"2021-03-04T17:19:35.782931Z","modified":"2021-03-04T17:19:35.851556Z","name":"demo-workflow-facts","description":"","unified_job_template":40,"launch_type":"manual","status":"pending","failed":false,"started":null,"finished":null,"canceled_on":null,"elapsed":0.0,"job_args":"","job_cwd":"","job_env":{},"job_explanation":"","result_traceback":"","workflow_job_template":40,"extra_vars":"{\"P1\": \"Colgan\"}","allow_simultaneous":false,"job_template":null,"is_sliced_job":false,"inventory":1,"limit":null,"scm_branch":null,"webhook_service":"","webhook_credential":null,"webhook_guid":""}

## revoke the token
echo;echo "[*] revoking token"
curl -s -k -X DELETE -u api-user:8451ansiblE "${tower_api}/tokens/$(jq -r .id ansible-api-token.json)/"

## cleanup
cp -f $token_file{,.bak}
rm -f $token_file
