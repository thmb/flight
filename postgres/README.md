# [POSTGRES](https://www.postgresql.org)



## SETUP






# APPLICATION

Local deployment on Minikube

# WAREHOUSE

Local deployment on Minikube

## AWS

docker run --rm -ti -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli s3 cp s3://aws-cli-docker-demo/hello .

In order to shorten the length of docker commands, you can add the following alias:

alias aws='docker run --rm -ti -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli'

aws --version
