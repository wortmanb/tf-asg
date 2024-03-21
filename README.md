# tf-asg

Terraform scripts to create Elasticsearch clusters from AWS Auto Scaling Groups.

# Usage
## Setup

To start, copy `cluster.tfvars.template` to a new file, say `my-cluster.tfvars`. Edit it and, following the directions in the comments, modify it as needed. At a minimum, you'll want to check the following:

- `cluster_name`
- `elk_version`
- node counts by type

Finally, if you haven't already done so, source the `tf-aliases.sh` script to establish the shortcuts we reference below.

```
source /path/to/tf-aliases.sh
```

Note that all of the shortcuts allow you to specify either the cluster name alone or the `cluster_name.tfvars` file; either will work.

## Checking your config

To check syntax and see what your plan would change without risk of applying the changes accidentally, use `tfp`. Wher you see `my-cluster` in these commands, remember to substitute your cluster bname in its place.

```
tfp my-cluster
```

If the results are as expected and there are no errors, you can proceed to apply the manifest using `tfa`.

## Applying the manifest

Use the `tfa` shortcut to create the ASGs.

```
tfa my-cluster
```

## Destroying the cluster

If you made a mistake and want to start over, `tfd` will perform a Terraform destroy on your cluster.

```
tfd my-cluster
```

# Cautions

If you need to reboot a node, you will need to put it in standby mode first, reboot, and then take it out of standby mode. Alternately, you can detach it from the ASG and reattach it after the reboot is complete, but make sure to indicate that you do not want a replacement instance added during the detach step. See this AWS documentation for more details:
https://repost.aws/knowledge-center/reboot-autoscaling-group-instance.

# Contact

This code was developed for a particular purpose and a particular environment, and for a particular set of clusters. It may not be useable in your situation without modification, though we have attempted to move as much dependency to variables as possible. If you have questions, feel free to contact one of the original authors below.

- tim.hosfelt@elastic.co
- bret.wortman@elastic.co
