
Use opentofu and use AWS terraform registry
#########################################################################################################

The following are not in exact order of creation/execution. They are only the client requirements for this project. Order of execution is constructed bellow

Networking & Clusters:
     1. Provision VPC, subnets, security groups in AWS|Delivrable:Terraform module `infra/aws/network`|Acceptance:`terraform apply` creates network with private/public subnets
     2. Deploy EKS cluster with node groups/Fargate|Delivrable:infra/aws/eks Terraform|Acceptance:kubectl get nodes returns healthy nodes
     3. Setup Ingress (ALB + cert-manager + ExternalDNS)|Delivrable:Helm releases in k8s/platform|Acceptance:DNS + TLS working for sample app
     
Databases:
    1. Provision Aurora Postgres clusters (v14 + v15) for LangFuse and MLFlow|Delivrable:infra/aws/db Terraform|Acceptance:PSQL connectivity verified
    2. Provision ElastiCache Redis|Delivrable:infra/aws/redis Terraform|Acceptance:redis-cli ping returns PONG
    3. Provision Redshift Serverless|Delivrable:infra/aws/redshift Terraform|Acceptance:Test query succeeds

Storage:
    1. Create S3 buckets for artifacts/logs|Delivrable:infra/aws/storage Terraform|Acceptance:Buckets enforce versioning + encryption
    2. Migrate MinIO → S3|Delivrable:/runbooks/migration_minio.md|Acceptance:Random sample artifacts accessible from MLflow

App Layer (K8s):
    1. Build Helm charts for MLflow, Model Server, Langfuse|Delivrable:charts/* repos|Acceptance:helm install deploys Langfuse with healthy pods
    2. Setup secrets sync via External Secrets Operator|Delivrable:k8s/secrets/externalsecret.yaml|Acceptance:Secrets propagate to pods automatically
    3. Configure readiness/liveness probes|Delivrable:Helm chart values.yaml|Acceptance:Health checks pass in K8s

Data migration:
    1. Postgres → Aurora migration|Delivrable:/runbooks/migration_postgres.md|Acceptance:Row counts match; app writes succeed
    2. ClickHouse → Redshift migration|Delivrable:/runbooks/migration_clickhouse.md|Acceptance:KPIs reproducible in Redshift

CI/CD:
    1. Build GitHub Actions pipeline|Delivrable:.github/workflows/deploy.yml|Acceptance:Push to main → deploys to staging EKS
    2. Integrate Trivy security scan|Delivrable:.github/workflows/scan.yml|Acceptance:Builds blocked if high CVEs
    
Security:
    1. Enforce IAM roles for service accounts (IRSA)|Delivrable:infra/aws/iam Terraform|Acceptance:Pods assume least-priv roles
    2. Apply Pod SecurityContext (non-root, read-only FS)|Delivrable:Helm values.prod.yaml|Acceptance:Pods run with restricted policies
    
Observability:
    1. Enable CloudWatch Container Insights|Delivrable:AWS console/Terraform|Acceptance:CPU/mem graphs visible for pods
    2. Configure CloudWatch Logs for app stdout|Delivrable:Terraform log groups|Acceptance:Logs searchable in CW console
    
#############################################################################################################

Steps to achieve this in order of execution:
Step 0:

Creation of boostrap/ exists because we need the S3 bucket for the .tfstate files BEFORE we create any other infrastructure. If everything runs in one script, the infra is not yet created and fails on the first run. It is cleaner to create in separate modules

Modules will have .tfstate living in an S3 bucket created by boostrap/
S3 is where the modules .tfstates can live, each with their separate folder

Step 1:
    Terraform Modules:
    infra/aws/network
    1. Networking foundation:VPC, private/public subnets, routing tables, NAT, IGW
    2. Security groups ( to be refined later!!!)
Step 2:
    Terraform Modules:
    infra/aws/eks
    1. EKS cluster:EKS cluster, node groups/Fargate profiles
    2. IAM roles for service accounts                        # these will be done with Helm
        aws eks update-kubeconfig --name <cluster>
        kubectl get nodes must work with healty nodes 
Step 3:
    Helm Release:
    infra/k8s/ingress
    Install ingress add-ons via Helm releases:
    ALB Ingress Controller
    Cert-manager for TLS
    External DNS ( Route 53 )
    Validation -> deploy a sample nginx app to get the HTTPS endpoint

Step 4:
    Terraform Modules:
    infra/aws/db
    infra/aws/redis
    infra/aws/redshift
    Aurora Postgres for MLFlow metadata + Langfuse
    ElastiCache Redis for Langfuse session/cache
    Redshift serverless for analytics (used later in migrations)
    Validation connect with psql / redis-cli

Step 5:
    Terraform Modules:
    infra/aws/storage
    S3 buckets with versioning and encryption
    Validation: upload/download a file, verify encription + versioning enabled

Step 6:
    Application layer - Kubernetes Helm charts
    Helm charts:
    charts/mlflow
    charts/model-server
    charts/langfuse


    
    
    
    
    
    mlops-platform/
├── README.md
├── .gitignore
├── .github/
│   └── workflows/
│       ├── plan.yml               # tofu plan on PRs
│       ├── apply.yml              # tofu apply on main
│       └── scan.yml               # Trivy / security scans
│
├── mlops-infra-aws/               # AWS-specific infra
│   ├── networking/
│   │   └── main.tf                # VPC using official module
│   ├── eks/
│   │   └── main.tf                # EKS cluster + node groups
│   ├── db/
│   │   └── main.tf                # Aurora Postgres, RDS
│   ├── redis/
│   │   └── main.tf                # ElastiCache Redis
│   ├── storage/
│   │   └── main.tf                # S3 bucket for MLflow artifacts
│   ├── iam/
│   │   └── main.tf                # IAM roles for service accounts (IRSA)
│   ├── variables.tf
│   ├── outputs.tf
│   └── backend.tf                 # S3 + DynamoDB backend for OpenTofu state
│
├── mlops-infra-gcp/               # GCP-specific infra (later)
│   ├── networking/
│   │   └── main.tf                # VPC, subnets
│   ├── gke/
│   │   └── main.tf                # GKE cluster
│   ├── db/
│   │   └── main.tf                # Cloud SQL (Postgres)
│   ├── redis/
│   │   └── main.tf                # Memorystore Redis
│   ├── storage/
│   │   └── main.tf                # GCS buckets
│   ├── variables.tf
│   ├── outputs.tf
│   └── backend.tf                 # GCS backend for state
│
├── modules/                       # Shared Terraform modules
│   ├── networking/
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── eks-cluster/
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── database/
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── storage/
│   │   ├── main.tf
│   │   └── variables.tf
│   └── iam/
│       ├── main.tf
│       └── variables.tf
│
├── charts/                        # Helm charts for apps
│   ├── mlflow/
│   │   ├── Chart.yaml

    
    
Later notes:
Each root module (networking/, eks/, db/, storage etc) will have it's own provider block declared in main.tf so it can be run independently
Using one S3 bucket to store all state files - each have their own distinct naming

With IRSA (IAM Roles for Service Accounts):
OIDC issuer URL - This URL acts as the “identity provider” for the cluster. AWS uses it to validate tokens issued by Kubernetes service accounts
You create an IAM Role.
You bind it to a Kubernetes Service Account.
Pods using that service account can assume that IAM role (via the OIDC provider).

###########################
Getting outputs:
tofu output -state=terraform.tfstate   or any other state in the S3 bucket
or
cd infra/bootstrap # go to the folder where outputs have been created and run:
tofu output



Check EKS clusters:
aws eks list-clusters --region us-east-2

Check all ENI:
aws ec2 describe-network-interfaces --region us-east-2 \
  --filters "Name=vpc-id,Values=<your-vpc-id>" \
  --query "NetworkInterfaces[].{ID:NetworkInterfaceId,Status:Status,Description:Description,Attached:Attachment.InstanceId}"

Check VPCs
aws ec2 describe-vpcs --region us-east-2 \
  --query "Vpcs[].{ID:VpcId,CIDR:CidrBlock,Tags:Tags}"

Check EC2's
aws ec2 describe-instances --region us-east-2 \
  --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,Tags:Tags}"

Check Elastic IP's:
aws ec2 describe-addresses --region us-east-2 \
  --query "Addresses[].{ID:AllocationId,PublicIp:PublicIp,Associated:InstanceId}"

Check NAT Gateway:
aws ec2 describe-nat-gateways --region us-east-2 \
  --query "NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId}"

Check subnets:
aws ec2 describe-subnets --region us-east-2 \
  --filters "Name=vpc-id,Values=<your-vpc-id>" \
  --query "Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Tags:Tags}"

Check Internet gateway:
aws ec2 describe-internet-gateways --region us-east-2 \
  --filters "Name=attachment.vpc-id,Values=<your-vpc-id>" \
  --query "InternetGateways[].{ID:InternetGatewayId,Attachments:Attachments}"

Check route tables:
aws ec2 describe-route-tables --region us-east-2 \
  --filters "Name=vpc-id,Values=<your-vpc-id>" \
  --query "RouteTables[].{ID:RouteTableId,Routes:Routes,Tags:Tags}"

Check Load Balancers:
aws elbv2 describe-load-balancers --region us-east-2 \
  --query "LoadBalancers[].{Name:LoadBalancerName,DNS:DNSName,VpcId:VpcId,State:State.Code}"

Check IAM roles:
aws iam list-roles --query "Roles[?contains(RoleName, 'mlops')].RoleName"

Check log groups: 
aws logs describe-log-groups --region us-east-2 \
  --query "logGroups[].logGroupName"

List S3 objects into json file:
$ aws s3api list-object-versions --bucket mlops-tofu-state --region us-east-2 \
--query=>   --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}, DeleteMarkers: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' \
>   --output json > objects.json

    
    
    
    
    
    
    
    
    
    
    
    
    
    

     
     
     
