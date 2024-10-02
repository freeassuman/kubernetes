__________________________pulling lb and cert-manager images from public cer__________________________________________
https://gallery.ecr.aws/l0g8r8j6/cert-manager/cert-manager-cainjector
https://gallery.ecr.aws/l0g8r8j6/cert-manager/cert-manager-controller
https://gallery.ecr.aws/l0g8r8j6/cert-manager/cert-manager-webhook
public.ecr.aws/eks/aws-load-balancer-controller:v2.5.3
quay.io/jetstack/cert-manager-acmesolver:v1.12.0
quay.io/jetstack/cert-manager-cainjector:v1.12.0
quay.io/jetstack/cert-manager-webhook:v1.12.0

docker pull public.ecr.aws/eks/aws-load-balancer-controller:v2.5.3
docker images|grep -i aws-load
docker save 674f1ef419ab > aws-load-balancer-controller_v2.5.3.tar.gz

_____________________________________________________proxybypass in eks node userdata____________________________

Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version:  1.0

--==BOUNDARY==
Content-Type: text/cloud-boothook; charset="us-ascii"

#!/bin/bash -e

#Set the proxy for future processes, and use as an include file
cloud-init-per instance proxy_config cat << EOF >> /etc/environment
http_proxy=185.46.212.88:443
https_proxy=185.46.212.88:443
ftp_proxy=185.46.212.88:443
no_proxy=10.11.8.0/21,172.16.200.0/23,172.20.0.0/16,localhost,.internal,127.0.0.1,169.254.169.254,169.254.169.123,s3.amazonaws.com,.s3.dualstack.eu-west-1.amazonaws.com,.s3.eu-west-1.amazonaws.com,ec2.eu-west-1.amazonaws.com,application-autoscaling.eu-west-1.amazonaws.com,ec2messages.eu-west-1.amazonaws.com,api.ecr.eu-west-1.amazonaws.com,.dkr.ecr.eu-west-1.amazonaws.com,eks.eu-west-1.amazonaws.com,.execute-api.eu-west-1.amazonaws.com,guardduty-data.eu-west-1.amazonaws.com,kms.eu-west-1.amazonaws.com,sqs.eu-west-1.amazonaws.com,ssm.eu-west-1.amazonaws.com,ssmmessages.eu-west-1.amazonaws.com,sts.eu-west-1.amazonaws.com,logs.eu-west-1.amazonaws.com,cloudformation.eu-west-1.amazonaws.com,elasticloadbalancing.eu-west-1.amazonaws.com,kms.eu-west-1.amazonaws.com,cloudformation.eu-west-1.amazonaws.com,monitoring.eu-west-1.amazonaws.com,.bancs-dr,.fav.bhola.com,.eks.amazonaws.com
EOF


_______________________________________________________________configmap update command in demonset_________________________________________________

kubectl patch -n kube-system -p '{ "spec": {"template": { "spec": { "containers": [ { "name": "aws-node", "envFrom": [ { "configMapRef": {"name": "configmap-backoffice-common-kube-system"} } ] } ] } } } }' daemonset aws-node
kubectl patch -n kube-system -p '{ "spec": {"template":{ "spec": { "containers": [ { "name": "kube-proxy", "envFrom": [ { "configMapRef": {"name": "configmap-backoffice-common-kube-system"} } ] } ] } } } }' daemonset kube-proxy

_________________________________________heapdump copy from pod_________________________________________________________________________________
kubectl exec -n deployment-backoffice-api-6466db56b-fs2qg -it -- /bin/bash
cat /sys/fs/cgroup/memory/memory.usage_in_bytes (to check memory inside pod)

jmap -dump:live,format=b,file=/opt/jboss-eap-7.4/standalone/log/hdmp_5.hprof 318 (to get heap dump from the pod)

kubectl cp deployment-backoffice-api-6466db56b-fs2qg:opt/jboss-eap-7.4/standalone/log/hdmp_2.hprof /home/bancs1.27/hdmp_2.hprof -n bancs-bat1 (to copy the file to local location)

______________________________________annotation___________________________________________________

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: demonamespace
  name: ingress-name
  annotations:
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
    alb.ingress.kubernetes.io/success-codes: 200,404,301,302
    alb.ingress.kubernetes.io/load-balancer-attributes: deletion_protection.enabled=true,routing.http2.enabled=true,routing.http.drop_invalid_header_fields.enabled=true,access_logs.s3.enabled=true,access_logs.s3.bucket=bucketname
    alb.ingress.kubernetes.io/tags: Name=urlname.com
    alb.ingress.kubernetes.io/load-balancer-name: alb-vpcname-01
