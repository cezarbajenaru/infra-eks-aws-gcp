tofu outputs to get the values created

CLI VPC check
    aws ec2 describe-vpcs --region us-east-2 --query "Vpcs[].{ID:VpcId,CIDR:CidrBlock}"

CLI get Subnets
    aws ec2 describe-subnets --region us-east-2 --filters "Name=vpc-id,Values=vpc-0aae990c4109f5877" \
    --query "Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone}"

CLI get NAT gateways
    aws ec2 describe-nat-gateways --region us-east-2 --filter "Name=vpc-id,Values=vpc-0aae990c4109f5877" \
    --query "NatGateways[].{ID:NatGatewayId,Subnet:SubnetId,State:State}"


