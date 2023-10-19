# [SPARK](https://spark.apache.org)

Spark can run on clusters managed by Kubernetes. This feature makes use of native Kubernetes scheduler that has been added to Spark.

[Running Spark on Kubernetes](https://spark.apache.org/docs/latest/running-on-kubernetes.html) is the preferable alternative.

The [Spark Operator](https://github.com/GoogleCloudPlatform/spark-on-k8s-operator) developed by Google is a popular choice.

## SETUP

The easiest way to install the Kubernetes Operator for Apache Spark is to use the Helm chart.

```console
helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator

helm install my-release spark-operator/spark-operator --namespace spark-operator --create-namespace
```

This will install the Kubernetes Operator for Apache Spark into the namespace `spark-operator`. The operator by default watches and handles SparkApplications in every namespaces. If you would like to limit the operator to watch and handle SparkApplications in a single namespace, e.g., `default` instead, add the following option to the helm install command:

```console
--set sparkJobNamespace=default
```
