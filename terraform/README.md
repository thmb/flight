# [TERRAFORM](https://www.terraform.io)



## SETUP



# Learn Terraform - Provision an EKS Cluster

This repo is a companion repo to the [Provision an EKS Cluster tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks), containing
Terraform configuration files to provision an EKS cluster on AWS.

Github Repository

https://github.com/hashicorp/learn-terraform-provision-eks-cluster/tree/main




## AWS

In order to shorten the length of docker commands, you can add the following alias:

alias aws='docker run --rm -ti -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli'

aws --version