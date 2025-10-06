EKS deployment
This folder provisions the Amazon EKS cluster using OpenTofu.
It depends on the networking module (VPC + subnets) to supply required values.

tofu version   #to see if you have opentofu installed
EKS has provider defined in root. Later if we want modifications, we can only modify this and not the rest of the infra

Verify if the cluster is alive:

aws eks update-kubeconfig --name <cluster-name> --region us-east-2
kubectl get nodes


