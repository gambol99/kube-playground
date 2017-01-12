## Kube Playground

Provides a playground environment for using, demoing the [kubernetes-platform](https://github.com/gambol99/kubernetes-platform) build and terraform modules.

#### **Getting Started**

There are a few prerequisites before doing a build, namely the KMS key use for at-rest encryption of the secrets and the terraform state bucket (though this one might be wrapped up in the script by now).

> - Ensure you have created a AWS KMS key *(in the correct region)* and updated the kms_master_id with the KeyID in the environment file.
> - Ensure you have created an S3 bucket for the terraform remote state and update the *terraform_bucket_name* variable in the environment file.
> - Ensure you have a aws credentials file location in ${HOME}/.aws/credentials and have updated the environment file with the correct aws_profile and aws_account.
> - Ensure you have updated the *kubeapi_access_list* and *ssh_access_list* environment variable to include your ip address.

```bash
# --> Create the terraform bucket
[jest@starfury kube-playground]$ ./run.kube
--> Running Platform, with environment: play-jest
# --> List all the buckets
[play-jest@platform] (master) $ kmsctl buckets
# --> Create a s3 bucket for the terraform state
[play-jest@platform] (master) $ kmsctl buckets create --bucket play-jest-kube-terraform-eu-west-1
... Update

# --> Create the KMS key for encryption
[play-jest@platform] (master) $ kmsctl kms create --name kube-play --description "A shared KMS used for playground builds"
# --> List all the keys
[play-jest@platform] (master) $ kmsctl kms
...

# --> Remember to update the variables (kms_master_id, terraform_bucket_name, dns zone and secret bucket) in the platform/env.tfvars file !!
# Then update teh public and private dns zone for environment and the access lists for ssh and kubeapi access (defaults 0.0.0.0/0)

# --> Kicking off the a build
[play-jest@platform] (master) $ run
... BUILDING ...

# --> Listing the instances
[play-jest@platform] (master) $ aws-instances
--------------------------------------------------------------------------------------------------------
|                                           DescribeInstances                                          |
+-------------------+---------------+----------------+----------------------+-----------+--------------+
|  play-jest-compute|  10.80.20.160 |  None          |  i-038e04cc103a61161 |  running  |  eu-west-1a  |
|  play-jest-compute|  10.80.22.252 |  None          |  i-08f17394ccce0c69b |  running  |  eu-west-1c  |
|  play-jest-bastion|  10.80.110.30 |  54.154.99.216 |  i-0041f7a15d54455d2 |  running  |  eu-west-1a  |
|  play-jest-compute|  10.80.21.84  |  None          |  i-03357aa1e7f0f6aa9 |  running  |  eu-west-1b  |
|  play-jest-secure |  10.80.11.109 |  None          |  i-0de8c881ae76e6600 |  running  |  eu-west-1b  |
|  play-jest-secure |  10.80.12.160 |  None          |  i-00f36bede3f0894ef |  running  |  eu-west-1c  |
|  play-jest-secure |  10.80.10.155 |  None          |  i-0a9c35b5c68f49100 |  running  |  eu-west-1a  |
+-------------------+---------------+----------------+----------------------+-----------+--------------+

# --> List all the ELBS
[play-jest@platform] (master) $ aws-elbs
--------------------------------------------------------------------------------------------------------------------
|                                               DescribeLoadBalancers                                              |
+-----------------------------------+------------------------------------------------------------------------------+
|  play-jest-kube-internal-elb      |  internal-play-jest-kube-internal-elb-382791532.eu-west-1.elb.amazonaws.com  |
|  play-jest-kubeapi                |  play-jest-kubeapi-2081633621.eu-west-1.elb.amazonaws.com                    |
+-----------------------------------+------------------------------------------------------------------------------+

# A kubeconfig has already been copied from secrets/secure/kubeconfig_admin to ~/.kube/config for you. Note, by
# default the server url will be public hostname of the kubeapi. If you have not set the sub-domain yet your'll
# have you use the aws one for now

[play-jest@platform] (master) $ terraform.sh output
[v] --> Retrieving the terraform remote state
Local and remote state in sync
compute_asg = play-jest-compute-asg
enabled_calico = 0
kubeapi_public = https://kube-play-jest.eu.example.com
kubeapi_public_elb = https://play-jest-kubeapi-2081633621.eu-west-1.elb.amazonaws.com
public_name_services = [
    ns-1227.awsdns-25.org,
    ns-1787.awsdns-31.co.uk,
    ns-469.awsdns-58.com,
    ns-678.awsdns-20.net
]

[play-jest@platform] (master) $ kubectl -s https://play-jest-kubeapi-2081633621.eu-west-1.elb.amazonaws.com get nodes
NAME                                         STATUS                     AGE
ip-10-80-10-147.eu-west-1.compute.internal   Ready,SchedulingDisabled   4m
ip-10-80-11-141.eu-west-1.compute.internal   Ready,SchedulingDisabled   4m
ip-10-80-12-193.eu-west-1.compute.internal   Ready,SchedulingDisabled   5m
ip-10-80-20-160.eu-west-1.compute.internal   Ready                      5m
ip-10-80-21-84.eu-west-1.compute.internal    Ready                      5m
ip-10-80-22-252.eu-west-1.compute.internal   Ready                      5m

# Note is usually takes between 3-5 minutes before seeing the API, it has to download containers (kubelet, hyperkube, kube-auth, kmsctl)
# and two binaries (kmsctl, smilodon)

[play-jest@platform] (master) $ kubectl -s https://play-jest-kubeapi-2081633621.eu-west-1.elb.amazonaws.com get ns
NAME          STATUS    AGE
default       Active    20m
kube-system   Active    20m

# By default kubedns and the dashboard has been automatically deployed via the kube-addons manifest.

# Make changes and rerun terraform
[play-jest@platform] (master) $ apply
# Or check the terraform plan
[play-jest@platform] (master) $ plan

# Cleaning up the environment
[play-jest@platform] (master) $ cleanup
This will DELETE ALL resources, are you sure? (yes/no) yes
...
```

#### **Bastion Hosts & SSH Access**

All the instances for the cluster are presently hidden away on private subnet's with not direct access to the internet. Outbound is handled via the managed NAT gateways and inbound can only come from the ELB layers *(by default all node ports from 30000 - 32767 are permitted between the ELB and compute security groups)*.

```shell
# Jump inside the container if not already there
[jest@starfury kubernetes-platform]$ ./play.kube
--> Running Platform, with environment: play-jest

# You have to ensure the secrets are downloaded - assuming a new container, you can fetch them via
[play-jest@platform] (master) $ fetch-secrets
[v] --> Fetching the secrets to the s3 bucket: play-jest-secrets
retrieved the file: addons/calico/deployment.yml and wrote to: secrets/addons/calico/deployment.yml
retrieved the file: addons/dashboard/deployment.yml and wrote to: secrets/addons/dashboard/deployment.yml
retrieved the file: addons/kubedns/deployment.yml and wrote to: secrets/addons/kubedns/deployment.yml
...

# You can setup the ssh-agent via the alias
[play-jest@platform] (master) $ agent-setup
Agent pid 1565
Identity added: /root/.ssh/id_rsa (/root/.ssh/id_rsa)

# Get the bastion host address
[play-jest@platform] (master) $ aws-instances | grep bas
|  play-jest-bastion|  10.80.110.30 |  54.x.x.x |  i-0041f7a15dxxxxxx |  running  |  eu-west-1a  |

[play-jest@platform] (master) $ ssh 54.x.x.x.
CoreOS alpha (1192.2.0)
Update Strategy: No Reboots
Failed Units: 1
  update-engine.service
# go into a master node
core@ip-10-80-110-30 ~ $ ssh 10.80.10.100
# check the journal logs
core@ip-10-80-110-30 ~ $ journalctl -fl
```
**Key Points**

> - The terraform variable *ssh_access_list* controls access to SSH via the Management security group.
> - The SSH key for the instance is kept in the secrets bucket under secrets/locked/environment_name
> - You can setup SSH agent forwarding from within the container via the alias 'agent-setup', ensure you have already downloaded the secrets via fetch-secrets.
> - The bastion hosts are run in a auto-scaling group, at the moment they are exposed directly to the internet, but long term I want to place them behind a ELB.

#### **Bastion Hosts & SSH Access**

All the instances for the cluster are presently hidden away on private subnet's with not direct access to the internet. Outbound is handled via the managed NAT gateways and inbound can only come from the ELB layers *(by default all node ports from 30000 - 32767 are permitted between the ELB and compute security groups)*.

```shell
# Jump inside the container if not already there
[jest@starfury kubernetes-platform]$ ./play.kube
--> Running Platform, with environment: play-jest

# You have to ensure the secrets are downloaded - assuming a new container, you can fetch them via
[play-jest@platform] (master) $ fetch-secrets
[v] --> Fetching the secrets to the s3 bucket: play-jest-secrets
retrieved the file: addons/calico/deployment.yml and wrote to: secrets/addons/calico/deployment.yml
retrieved the file: addons/dashboard/deployment.yml and wrote to: secrets/addons/dashboard/deployment.yml
retrieved the file: addons/kubedns/deployment.yml and wrote to: secrets/addons/kubedns/deployment.yml
...

# You can setup the ssh-agent via the alias
[play-jest@platform] (master) $ agent-setup
Agent pid 1565
Identity added: /root/.ssh/id_rsa (/root/.ssh/id_rsa)

# Get the bastion host address
[play-jest@platform] (master) $ aws-instances | grep bas
|  play-jest-bastion|  10.80.110.30 |  54.x.x.x |  i-0041f7a15dxxxxxx |  running  |  eu-west-1a  |

[play-jest@platform] (master) $ ssh 54.x.x.x.
CoreOS alpha (1192.2.0)
Update Strategy: No Reboots
Failed Units: 1
  update-engine.service
# go into a master node
core@ip-10-80-110-30 ~ $ ssh 10.80.10.100
```
**Key Points**

> - The terraform variable *ssh_access_list* controls access to SSH via the Management security group.
> - The SSH key for the instance is kept in the secrets bucket under secrets/locked/environment_name
> - You can setup SSH agent forwarding from within the container via the alias 'agent-setup', ensure you have already downloaded the secrets via fetch-secrets.
> - The bastion hosts are run in a auto-scaling group, at the moment they are exposed directly to the internet, but long term I want to place them behind a ELB.
