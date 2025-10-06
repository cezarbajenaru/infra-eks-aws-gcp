After EKS cluster creation should return this:

cluster_endpoint = "https://EF23FB4483E3BA3EA7FD70C260687CC2.gr7.us-east-2.eks.amazonaws.com" #where kubectl talks
cluster_name = "mlops-infra-aws-eks"
cluster_oidc_issuer_url = "https://oidc.eks.us-east-2.amazonaws.com/id/EF23FB4483E3BA3EA7FD70C260687CC2" #service account integration
node_group_role_name = "default-eks-node-group-20250916182516141400000002" #IAM role for worker nodes


--------------------------------------------
The following command bridges local kubectl to AWS EKS:
aws eks --region us-east-2 update-kubeconfig --name mlops-infra-aws-eks 

See you identity from AWS configure - These credentials will 
aws sts get-caller-identity

Uses your AWS credentials (from ~/.aws/credentials or environment vars) to talk to the EKS control plane in AWS.

It checks: “Am I allowed to access this cluster?”
That’s where your IAM user/role permissions come in.
Updates your kubeconfig (usually ~/.kube/config) with a new cluster context:
API server endpoint (the URL for your EKS cluster).
Cluster certificate (so kubectl trusts it).
Auth method (uses your AWS IAM credentials whenever you run kubectl).

Should return:
Added new context arn:aws:eks:us-east-2:716969406947:cluster/mlops-infra-aws-eks to /home/plasticmemory/.kube/config
---------------------------------------------

kubectl config get-contexts
kubectl config current-context

Check if nodes exist:
aws eks describe-nodegroup \
  --cluster-name mlops-infra-aws-eks \
  --nodegroup-name <your-nodegroup-name> \
  --region us-east-2


kubectl get nodes --watch #verbose version in CLI


HELM

We need kubernetes manifests to  ( you cannot run Docker Compose)



