Creation of boostrap exists because we need the S3 bucket for the .tfstate files BEFORE we create any infrastructure. If everything runs in one script, the infra is not yet created and fails on the first run. It is cleaner to create in separate steps with no fails inbetween


How to check if this resource exists: 
    aws s3 ls --region us-east-2 | grep mlops-tofu-state
    Should return date/time/name of resource

DynamoDB check:
    aws dynamodb list-tables --region us-east-2
    should return a json with name

tofu output
Should return:
    tf_state_bucket = "mlops-tofu-state"
    tf_locks_table  = "mlops-tofu-locks"

commands to run this from scratch:
    tofu validate
    tofu plan -out=tfplan  # this is just to create a profile of this initial release in case something drifts(only saved locally)
    tofu apply tfplan

