# tak

Just a collection of hacky scripts used to setup and tear down simple k8s clusters on EC2

- Install Terraform, AWS CLI and Ansible on your laptop
- Fill in the access and secret keys
- Scripts will create a new VPC and other resources and use 3 new floating IPs

Run ```terraform destroy``` when you want to clean up

