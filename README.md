
# terraform-aws-elastic-beanstalk-environment
## Usage


For a complete example, see [examples/complete](examples/complete)

```hcl
  provider "aws" {
    region = var.region
  }

  module "vpc" {
    source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.8.0"
    namespace  = var.namespace
    stage      = var.stage
    name       = var.name
    cidr_block = "172.16.0.0/16"
  }

  module "subnets" {
    source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.16.0"
    availability_zones   = var.availability_zones
    namespace            = var.namespace
    stage                = var.stage
    name                 = var.name
    vpc_id               = module.vpc.vpc_id
    igw_id               = module.vpc.igw_id
    cidr_block           = module.vpc.vpc_cidr_block
    nat_gateway_enabled  = true
    nat_instance_enabled = false
  }

  module "elastic_beanstalk_application" {
    source      = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-application.git?ref=tags/0.3.0"
    namespace   = var.namespace
    stage       = var.stage
    name        = var.name
    description = "Test elastic_beanstalk_application"
  }

  module "elastic_beanstalk_environment" {
    source = "cloudposse/elastic-beanstalk-environment/aws"
    # Cloud Posse recommends pinning every module to a specific version
    # version = "x.x.x"
    namespace                          = var.namespace
    stage                              = var.stage
    name                               = var.name
    description                        = "Test elastic_beanstalk_environment"
    region                             = var.region
    availability_zone_selector         = "Any 2"
    elastic_beanstalk_application_name = module.elastic_beanstalk_application.elastic_beanstalk_application_name

    instance_type           = "t3.small"
    autoscale_min           = 1
    autoscale_max           = 2
    updating_min_in_service = 0
    updating_max_batch      = 1

    loadbalancer_type    = "application"
    vpc_id               = module.vpc.vpc_id
    loadbalancer_subnets = module.subnets.public_subnet_ids
    application_subnets  = module.subnets.private_subnet_ids
    security_group_rules = [
      {
        type                     = "egress"
        from_port                = 0
        to_port                  = 65535
        protocol                 = "-1"
        cidr_blocks              = ["0.0.0.0/0"]
        source_security_group_id = null
        description              = "Allow all outbound traffic"
      },
      {
        type                     = "ingress"
        from_port                = 0
        to_port                  = 65535
        protocol                 = "-1"
        source_security_group_id = [module.vpc.vpc_default_security_group_id]
        cidr_blocks              = null
        description              = "Allow all ingress traffic from trusted Security Groups"
      },
    ]
    prefer_legacy_service_policy = false

    // https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html
    // https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html#platforms-supported.docker
    solution_stack_name = "64bit Amazon Linux 2018.03 v2.12.17 running Docker 18.06.1-ce"

    additional_settings = [
      {
        namespace = "aws:elasticbeanstalk:application:environment"
        name      = "DB_HOST"
        value     = "xxxxxxxxxxxxxx"
      },
      {
        namespace = "aws:elasticbeanstalk:application:environment"
        name      = "DB_USERNAME"
        value     = "yyyyyyyyyyyyy"
      },
      {
        namespace = "aws:elasticbeanstalk:application:environment"
        name      = "DB_PASSWORD"
        value     = "zzzzzzzzzzzzzzzzzzz"
      },
      {
        namespace = "aws:elasticbeanstalk:application:environment"
        name      = "ANOTHER_ENV_VAR"
        value     = "123456789"
      }
    ]
  }
```






## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | cloudposse/security-group/aws | 0.3.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_elastic_beanstalk_environment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_environment) | resource |
| [aws_iam_instance_profile.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecr_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.elastic_beanstalk_multi_container_docker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.enhanced_health](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_automation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.web_tier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.worker_tier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.elb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_ssm_activation.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_activation) | resource |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.elb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.extended](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_settings"></a> [additional\_settings](#input\_additional\_settings) | Additional Elastic Beanstalk setttings. For full list of options, see https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html | <pre>list(object({<br>    namespace = string<br>    name      = string<br>    value     = string<br>  }))</pre> | `[]` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_alb_zone_id"></a> [alb\_zone\_id](#input\_alb\_zone\_id) | ALB zone id | `map(string)` | <pre>{<br>  "af-south-1": "Z1EI3BVKMKK4AM",<br>  "ap-east-1": "ZPWYUBWRU171A",<br>  "ap-northeast-1": "Z1R25G3KIG2GBW",<br>  "ap-northeast-2": "Z3JE5OI70TWKCP",<br>  "ap-south-1": "Z18NTBI3Y7N9TZ",<br>  "ap-southeast-1": "Z16FZ9L249IFLT",<br>  "ap-southeast-2": "Z2PCDNR3VC2G1N",<br>  "ca-central-1": "ZJFCZL7SSZB5I",<br>  "eu-central-1": "Z1FRNW7UH4DEZJ",<br>  "eu-north-1": "Z23GO28BZ5AETM",<br>  "eu-south-1": "Z10VDYYOA2JFKM",<br>  "eu-west-1": "Z2NYPWQ7DFZAZH",<br>  "eu-west-2": "Z1GKAAAUGATPF1",<br>  "eu-west-3": "Z3Q77PNBQS71R4",<br>  "me-south-1": "Z2BBTEKR2I36N2",<br>  "sa-east-1": "Z10X7K2B4QSOFV",<br>  "us-east-1": "Z117KPS5GTRQ2G",<br>  "us-east-2": "Z14LCN19Q5QHIC",<br>  "us-gov-east-1": "Z2NIFVYYW2VKV1",<br>  "us-gov-west-1": "Z31GFT0UA1I2HV",<br>  "us-west-1": "Z1LQECGX5PH1X",<br>  "us-west-2": "Z38NKT9BP95V3O"<br>}</pre> | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The id of the AMI to associate with the Amazon EC2 instances | `string` | `null` | no |
| <a name="input_application_port"></a> [application\_port](#input\_application\_port) | Port application is listening on | `number` | `80` | no |
| <a name="input_application_subnets"></a> [application\_subnets](#input\_application\_subnets) | List of subnets to place EC2 instances | `list(string)` | n/a | yes |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to associate public IP addresses to the instances | `bool` | `false` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_autoscale_lower_bound"></a> [autoscale\_lower\_bound](#input\_autoscale\_lower\_bound) | Minimum level of autoscale metric to remove an instance | `number` | `20` | no |
| <a name="input_autoscale_lower_increment"></a> [autoscale\_lower\_increment](#input\_autoscale\_lower\_increment) | How many Amazon EC2 instances to remove when performing a scaling activity. | `number` | `-1` | no |
| <a name="input_autoscale_max"></a> [autoscale\_max](#input\_autoscale\_max) | Maximum instances to launch | `number` | `3` | no |
| <a name="input_autoscale_measure_name"></a> [autoscale\_measure\_name](#input\_autoscale\_measure\_name) | Metric used for your Auto Scaling trigger | `string` | `"CPUUtilization"` | no |
| <a name="input_autoscale_min"></a> [autoscale\_min](#input\_autoscale\_min) | Minumum instances to launch | `number` | `2` | no |
| <a name="input_autoscale_statistic"></a> [autoscale\_statistic](#input\_autoscale\_statistic) | Statistic the trigger should use, such as Average | `string` | `"Average"` | no |
| <a name="input_autoscale_unit"></a> [autoscale\_unit](#input\_autoscale\_unit) | Unit for the trigger measurement, such as Bytes | `string` | `"Percent"` | no |
| <a name="input_autoscale_upper_bound"></a> [autoscale\_upper\_bound](#input\_autoscale\_upper\_bound) | Maximum level of autoscale metric to add an instance | `number` | `80` | no |
| <a name="input_autoscale_upper_increment"></a> [autoscale\_upper\_increment](#input\_autoscale\_upper\_increment) | How many Amazon EC2 instances to add when performing a scaling activity | `number` | `1` | no |
| <a name="input_availability_zone_selector"></a> [availability\_zone\_selector](#input\_availability\_zone\_selector) | Availability Zone selector | `string` | `"Any 2"` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_deployment_batch_size"></a> [deployment\_batch\_size](#input\_deployment\_batch\_size) | Percentage or fixed number of Amazon EC2 instances in the Auto Scaling group on which to simultaneously perform deployments. Valid values vary per deployment\_batch\_size\_type setting | `number` | `1` | no |
| <a name="input_deployment_batch_size_type"></a> [deployment\_batch\_size\_type](#input\_deployment\_batch\_size\_type) | The type of number that is specified in deployment\_batch\_size\_type | `string` | `"Fixed"` | no |
| <a name="input_deployment_ignore_health_check"></a> [deployment\_ignore\_health\_check](#input\_deployment\_ignore\_health\_check) | Do not cancel a deployment due to failed health checks | `bool` | `false` | no |
| <a name="input_deployment_timeout"></a> [deployment\_timeout](#input\_deployment\_timeout) | Number of seconds to wait for an instance to complete executing commands | `number` | `600` | no |
| <a name="input_description"></a> [description](#input\_description) | Short description of the Environment | `string` | `""` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_elastic_beanstalk_application_name"></a> [elastic\_beanstalk\_application\_name](#input\_elastic\_beanstalk\_application\_name) | Elastic Beanstalk application name | `string` | n/a | yes |
| <a name="input_elb_scheme"></a> [elb\_scheme](#input\_elb\_scheme) | Specify `internal` if you want to create an internal load balancer in your Amazon VPC so that your Elastic Beanstalk application cannot be accessed from outside your Amazon VPC | `string` | `"public"` | no |
| <a name="input_enable_log_publication_control"></a> [enable\_log\_publication\_control](#input\_enable\_log\_publication\_control) | Copy the log files for your application's Amazon EC2 instances to the Amazon S3 bucket associated with your application | `bool` | `false` | no |
| <a name="input_enable_spot_instances"></a> [enable\_spot\_instances](#input\_enable\_spot\_instances) | Enable Spot Instance requests for your environment | `bool` | `false` | no |
| <a name="input_enable_stream_logs"></a> [enable\_stream\_logs](#input\_enable\_stream\_logs) | Whether to create groups in CloudWatch Logs for proxy and deployment logs, and stream logs from each instance in your environment | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_enhanced_reporting_enabled"></a> [enhanced\_reporting\_enabled](#input\_enhanced\_reporting\_enabled) | Whether to enable "enhanced" health reporting for this environment.  If false, "basic" reporting is used.  When you set this to false, you must also set `enable_managed_actions` to false | `bool` | `true` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Map of custom ENV variables to be provided to the application running on Elastic Beanstalk, e.g. env\_vars = { DB\_USER = 'admin' DB\_PASS = 'xxxxxx' } | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | Environment type, e.g. 'LoadBalanced' or 'SingleInstance'.  If setting to 'SingleInstance', `rolling_update_type` must be set to 'Time', `updating_min_in_service` must be set to 0, and `loadbalancer_subnets` will be unused (it applies to the ELB, which does not exist in SingleInstance environments) | `string` | `"LoadBalanced"` | no |
| <a name="input_extended_ec2_policy_document"></a> [extended\_ec2\_policy\_document](#input\_extended\_ec2\_policy\_document) | Extensions or overrides for the IAM role assigned to EC2 instances | `string` | `"{}"` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Force destroy the S3 bucket for load balancer logs | `bool` | `false` | no |
| <a name="input_health_streaming_delete_on_terminate"></a> [health\_streaming\_delete\_on\_terminate](#input\_health\_streaming\_delete\_on\_terminate) | Whether to delete the log group when the environment is terminated. If false, the health data is kept RetentionInDays days. | `bool` | `false` | no |
| <a name="input_health_streaming_enabled"></a> [health\_streaming\_enabled](#input\_health\_streaming\_enabled) | For environments with enhanced health reporting enabled, whether to create a group in CloudWatch Logs for environment health and archive Elastic Beanstalk environment health data. For information about enabling enhanced health, see aws:elasticbeanstalk:healthreporting:system. | `bool` | `false` | no |
| <a name="input_health_streaming_retention_in_days"></a> [health\_streaming\_retention\_in\_days](#input\_health\_streaming\_retention\_in\_days) | The number of days to keep the archived health data before it expires. | `number` | `7` | no |
| <a name="input_healthcheck_url"></a> [healthcheck\_url](#input\_healthcheck\_url) | Application Health Check URL. Elastic Beanstalk will call this URL to check the health of the application running on EC2 instances | `string` | `"/"` | no |
| <a name="input_http_listener_enabled"></a> [http\_listener\_enabled](#input\_http\_listener\_enabled) | Enable port 80 (http) | `bool` | `true` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_instance_refresh_enabled"></a> [instance\_refresh\_enabled](#input\_instance\_refresh\_enabled) | Enable weekly instance replacement. | `bool` | `true` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instances type | `string` | `"t2.micro"` | no |
| <a name="input_keypair"></a> [keypair](#input\_keypair) | Name of SSH key that will be deployed on Elastic Beanstalk and DataPipeline instance. The key should be present in AWS | `string` | `""` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_loadbalancer_certificate_arn"></a> [loadbalancer\_certificate\_arn](#input\_loadbalancer\_certificate\_arn) | Load Balancer SSL certificate ARN. The certificate must be present in AWS Certificate Manager | `string` | `""` | no |
| <a name="input_loadbalancer_crosszone"></a> [loadbalancer\_crosszone](#input\_loadbalancer\_crosszone) | Configure the classic load balancer to route traffic evenly across all instances in all Availability Zones rather than only within each zone. | `bool` | `true` | no |
| <a name="input_loadbalancer_managed_security_group"></a> [loadbalancer\_managed\_security\_group](#input\_loadbalancer\_managed\_security\_group) | Load balancer managed security group | `string` | `""` | no |
| <a name="input_loadbalancer_security_groups"></a> [loadbalancer\_security\_groups](#input\_loadbalancer\_security\_groups) | Load balancer security groups | `list(string)` | `[]` | no |
| <a name="input_loadbalancer_ssl_policy"></a> [loadbalancer\_ssl\_policy](#input\_loadbalancer\_ssl\_policy) | Specify a security policy to apply to the listener. This option is only applicable to environments with an application load balancer | `string` | `""` | no |
| <a name="input_loadbalancer_subnets"></a> [loadbalancer\_subnets](#input\_loadbalancer\_subnets) | List of subnets to place Elastic Load Balancer | `list(string)` | `[]` | no |
| <a name="input_loadbalancer_type"></a> [loadbalancer\_type](#input\_loadbalancer\_type) | Load Balancer type, e.g. 'application' or 'classic' | `string` | `"classic"` | no |
| <a name="input_logs_delete_on_terminate"></a> [logs\_delete\_on\_terminate](#input\_logs\_delete\_on\_terminate) | Whether to delete the log groups when the environment is terminated. If false, the logs are kept RetentionInDays days | `bool` | `false` | no |
| <a name="input_logs_retention_in_days"></a> [logs\_retention\_in\_days](#input\_logs\_retention\_in\_days) | The number of days to keep log events before they expire. | `number` | `7` | no |
| <a name="input_managed_actions_enabled"></a> [managed\_actions\_enabled](#input\_managed\_actions\_enabled) | Enable managed platform updates. When you set this to true, you must also specify a `PreferredStartTime` and `UpdateLevel` | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_prefer_legacy_service_policy"></a> [prefer\_legacy\_service\_policy](#input\_prefer\_legacy\_service\_policy) | Whether to use AWSElasticBeanstalkService (deprecated) or AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy policy | `bool` | `true` | no |
| <a name="input_prefer_legacy_ssm_policy"></a> [prefer\_legacy\_ssm\_policy](#input\_prefer\_legacy\_ssm\_policy) | Whether to use AmazonEC2RoleforSSM (will soon be deprecated) or AmazonSSMManagedInstanceCore policy | `bool` | `true` | no |
| <a name="input_preferred_start_time"></a> [preferred\_start\_time](#input\_preferred\_start\_time) | Configure a maintenance window for managed actions in UTC | `string` | `"Sun:10:00"` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_rolling_update_enabled"></a> [rolling\_update\_enabled](#input\_rolling\_update\_enabled) | Whether to enable rolling update | `bool` | `true` | no |
| <a name="input_rolling_update_type"></a> [rolling\_update\_type](#input\_rolling\_update\_type) | `Health` or `Immutable`. Set it to `Immutable` to apply the configuration change to a fresh group of instances | `string` | `"Health"` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | The size of the EBS root volume | `number` | `8` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | The type of the EBS root volume | `string` | `"gp2"` | no |
| <a name="input_s3_bucket_access_log_bucket_name"></a> [s3\_bucket\_access\_log\_bucket\_name](#input\_s3\_bucket\_access\_log\_bucket\_name) | Name of the S3 bucket where s3 access log will be sent to | `string` | `""` | no |
| <a name="input_s3_bucket_encryption_enabled"></a> [s3\_bucket\_encryption\_enabled](#input\_s3\_bucket\_encryption\_enabled) | When set to 'true' the resource will have aes256 encryption enabled by default | `bool` | `true` | no |
| <a name="input_s3_bucket_versioning_enabled"></a> [s3\_bucket\_versioning\_enabled](#input\_s3\_bucket\_versioning\_enabled) | When set to 'true' the s3 origin bucket will have versioning enabled | `bool` | `true` | no |
| <a name="input_scheduled_actions"></a> [scheduled\_actions](#input\_scheduled\_actions) | Define a list of scheduled actions | <pre>list(object({<br>    name            = string<br>    minsize         = string<br>    maxsize         = string<br>    desiredcapacity = string<br>    starttime       = string<br>    endtime         = string<br>    recurrence      = string<br>    suspend         = bool<br>  }))</pre> | `[]` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | The Security Group description. | `string` | `"Elastic Beanstalk environment Security Group"` | no |
| <a name="input_security_group_enabled"></a> [security\_group\_enabled](#input\_security\_group\_enabled) | Whether to create Security Group. | `bool` | `true` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | A list of maps of Security Group rules.<br>The values of map is fully complated with `aws_security_group_rule` resource.<br>To get more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule . | `list(any)` | <pre>[<br>  {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Allow all outbound traffic",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "to_port": 65535,<br>    "type": "egress"<br>  }<br>]</pre> | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Whether to create a default Security Group with unique name beginning with the normalized prefix. | `bool` | `false` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of Security Group IDs to associate with EC2 instances. | `list(string)` | `[]` | no |
| <a name="input_solution_stack_name"></a> [solution\_stack\_name](#input\_solution\_stack\_name) | Elastic Beanstalk stack, e.g. Docker, Go, Node, Java, IIS. For more info, see https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html | `string` | n/a | yes |
| <a name="input_spot_fleet_on_demand_above_base_percentage"></a> [spot\_fleet\_on\_demand\_above\_base\_percentage](#input\_spot\_fleet\_on\_demand\_above\_base\_percentage) | The percentage of On-Demand Instances as part of additional capacity that your Auto Scaling group provisions beyond the SpotOnDemandBase instances. This option is relevant only when enable\_spot\_instances is true. | `number` | `-1` | no |
| <a name="input_spot_fleet_on_demand_base"></a> [spot\_fleet\_on\_demand\_base](#input\_spot\_fleet\_on\_demand\_base) | The minimum number of On-Demand Instances that your Auto Scaling group provisions before considering Spot Instances as your environment scales up. This option is relevant only when enable\_spot\_instances is true. | `number` | `0` | no |
| <a name="input_spot_max_price"></a> [spot\_max\_price](#input\_spot\_max\_price) | The maximum price per unit hour, in US$, that you're willing to pay for a Spot Instance. This option is relevant only when enable\_spot\_instances is true. Valid values are between 0.001 and 20.0 | `number` | `-1` | no |
| <a name="input_ssh_listener_enabled"></a> [ssh\_listener\_enabled](#input\_ssh\_listener\_enabled) | Enable SSH port | `bool` | `false` | no |
| <a name="input_ssh_listener_port"></a> [ssh\_listener\_port](#input\_ssh\_listener\_port) | SSH port | `number` | `22` | no |
| <a name="input_ssh_source_restriction"></a> [ssh\_source\_restriction](#input\_ssh\_source\_restriction) | Used to lock down SSH access to the EC2 instances | `string` | `"0.0.0.0/0"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | Elastic Beanstalk Environment tier, 'WebServer' or 'Worker' | `string` | `"WebServer"` | no |
| <a name="input_update_level"></a> [update\_level](#input\_update\_level) | The highest level of update to apply with managed platform updates | `string` | `"minor"` | no |
| <a name="input_updating_max_batch"></a> [updating\_max\_batch](#input\_updating\_max\_batch) | Maximum number of instances to update at once | `number` | `1` | no |
| <a name="input_updating_min_in_service"></a> [updating\_min\_in\_service](#input\_updating\_min\_in\_service) | Minimum number of instances in service during update | `number` | `1` | no |
| <a name="input_version_label"></a> [version\_label](#input\_version\_label) | Elastic Beanstalk Application version to deploy | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC in which to provision the AWS resources | `string` | n/a | yes |
| <a name="input_wait_for_ready_timeout"></a> [wait\_for\_ready\_timeout](#input\_wait\_for\_ready\_timeout) | The maximum duration to wait for the Elastic Beanstalk Environment to be in a ready state before timing out | `string` | `"20m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_settings"></a> [all\_settings](#output\_all\_settings) | List of all option settings configured in the environment. These are a combination of default settings and their overrides from setting in the configuration |
| <a name="output_application"></a> [application](#output\_application) | The Elastic Beanstalk Application specified for this environment |
| <a name="output_autoscaling_groups"></a> [autoscaling\_groups](#output\_autoscaling\_groups) | The autoscaling groups used by this environment |
| <a name="output_ec2_instance_profile_role_name"></a> [ec2\_instance\_profile\_role\_name](#output\_ec2\_instance\_profile\_role\_name) | Instance IAM role name |
| <a name="output_elb_zone_id"></a> [elb\_zone\_id](#output\_elb\_zone\_id) | ELB zone id |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Fully qualified DNS name for the environment |
| <a name="output_id"></a> [id](#output\_id) | ID of the Elastic Beanstalk environment |
| <a name="output_instances"></a> [instances](#output\_instances) | Instances used by this environment |
| <a name="output_launch_configurations"></a> [launch\_configurations](#output\_launch\_configurations) | Launch configurations in use by this environment |
| <a name="output_load_balancers"></a> [load\_balancers](#output\_load\_balancers) | Elastic Load Balancers in use by this environment |
| <a name="output_name"></a> [name](#output\_name) | Name |
| <a name="output_queues"></a> [queues](#output\_queues) | SQS queues in use by this environment |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Elastic Beanstalk environment Security Group ARN |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Elastic Beanstalk environment Security Group ID |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | Elastic Beanstalk environment Security Group name |
| <a name="output_setting"></a> [setting](#output\_setting) | Settings specifically set for this environment |
| <a name="output_tier"></a> [tier](#output\_tier) | The environment tier |
| <a name="output_triggers"></a> [triggers](#output\_triggers) | Autoscaling triggers in use by this environment |
<!-- markdownlint-restore -->



## Share the Love

Like this project? Please give it a ★ on [our GitHub](https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment)! (it helps us **a lot**)

Are you using this project or any of our other projects? Consider [leaving a testimonial][testimonial]. =)



## Related Projects

Check out these related projects.

- [terraform-aws-jenkins](https://github.com/cloudposse/terraform-aws-jenkins) - Terraform module to build Docker image with Jenkins, save it to an ECR repo, and deploy to Elastic Beanstalk running Docker stack
- [terraform-aws-elastic-beanstalk-application](https://github.com/cloudposse/terraform-aws-elastic-beanstalk-application) - Terraform Module to define an ElasticBeanstalk Application
- [geodesic](https://github.com/cloudposse/geodesic) -  Geodesic is the fastest way to get up and running with a rock solid, production grade cloud platform built on strictly Open Source tools.
- [terraform-aws-elasticache-cloudwatch-sns-alarms](https://github.com/cloudposse/terraform-aws-elasticache-cloudwatch-sns-alarms) -  Terraform module that configures CloudWatch SNS alerts for ElastiCache

## Help

**Got a question?** We got answers.

File a GitHub [issue](https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment/issues), send us an [email][email] or join our [Slack Community][slack].

[![README Commercial Support][readme_commercial_support_img]][readme_commercial_support_link]

## DevOps Accelerator for Startups


We are a [**DevOps Accelerator**][commercial_support]. We'll help you build your cloud infrastructure from the ground up so you can own it. Then we'll show you how to operate it and stick around for as long as you need us.

[![Learn More](https://img.shields.io/badge/learn%20more-success.svg?style=for-the-badge)][commercial_support]

Work directly with our team of DevOps experts via email, slack, and video conferencing.

We deliver 10x the value for a fraction of the cost of a full-time engineer. Our track record is not even funny. If you want things done right and you need it done FAST, then we're your best bet.

- **Reference Architecture.** You'll get everything you need from the ground up built using 100% infrastructure as code.
- **Release Engineering.** You'll have end-to-end CI/CD with unlimited staging environments.
- **Site Reliability Engineering.** You'll have total visibility into your apps and microservices.
- **Security Baseline.** You'll have built-in governance with accountability and audit logs for all changes.
- **GitOps.** You'll be able to operate your infrastructure via Pull Requests.
- **Training.** You'll receive hands-on training so your team can operate what we build.
- **Questions.** You'll have a direct line of communication between our teams via a Shared Slack channel.
- **Troubleshooting.** You'll get help to triage when things aren't working.
- **Code Reviews.** You'll receive constructive feedback on Pull Requests.
- **Bug Fixes.** We'll rapidly work with you to fix any bugs in our projects.

## Slack Community

Join our [Open Source Community][slack] on Slack. It's **FREE** for everyone! Our "SweetOps" community is where you get to talk with others who share a similar vision for how to rollout and manage infrastructure. This is the best place to talk shop, ask questions, solicit feedback, and work together as a community to build totally *sweet* infrastructure.

## Discourse Forums

Participate in our [Discourse Forums][discourse]. Here you'll find answers to commonly asked questions. Most questions will be related to the enormous number of projects we support on our GitHub. Come here to collaborate on answers, find solutions, and get ideas about the products and services we value. It only takes a minute to get started! Just sign in with SSO using your GitHub account.

## Newsletter

Sign up for [our newsletter][newsletter] that covers everything on our technology radar.  Receive updates on what we're up to on GitHub as well as awesome new projects we discover.

## Office Hours

[Join us every Wednesday via Zoom][office_hours] for our weekly "Lunch & Learn" sessions. It's **FREE** for everyone!

[![zoom](https://img.cloudposse.com/fit-in/200x200/https://cloudposse.com/wp-content/uploads/2019/08/Powered-by-Zoom.png")][office_hours]

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or [help out](https://cpco.io/help-out) with our other projects, we would love to hear from you! Shoot us an [email][email].

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!


## Copyright

Copyright © 2017-2021 [Cloud Posse, LLC](https://cpco.io/copyright)



## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```









## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

This project is maintained and funded by [Cloud Posse, LLC][website]. Like it? Please let us know by [leaving a testimonial][testimonial]!

[![Cloud Posse][logo]][website]

We're a [DevOps Professional Services][hire] company based in Los Angeles, CA. We ❤️  [Open Source Software][we_love_open_source].

We offer [paid support][commercial_support] on all of our projects.

Check out [our other projects][github], [follow us on twitter][twitter], [apply for a job][jobs], or [hire us][hire] to help with your cloud strategy and implementation.



### Contributors

<!-- markdownlint-disable -->
|  [![Erik Osterman][osterman_avatar]][osterman_homepage]<br/>[Erik Osterman][osterman_homepage] | [![Igor Rodionov][goruha_avatar]][goruha_homepage]<br/>[Igor Rodionov][goruha_homepage] | [![Andriy Knysh][aknysh_avatar]][aknysh_homepage]<br/>[Andriy Knysh][aknysh_homepage] | [![Guillaume Delacour][guikcd_avatar]][guikcd_homepage]<br/>[Guillaume Delacour][guikcd_homepage] | [![Viktor Erpylev][velmoga_avatar]][velmoga_homepage]<br/>[Viktor Erpylev][velmoga_homepage] | [![Lucas Pearson][pearson-lucas-dev_avatar]][pearson-lucas-dev_homepage]<br/>[Lucas Pearson][pearson-lucas-dev_homepage] | [![Chris Green][DirectRoot_avatar]][DirectRoot_homepage]<br/>[Chris Green][DirectRoot_homepage] | [![Vladimir Syromyatnikov][SweetOps_avatar]][SweetOps_homepage]<br/>[Vladimir Syromyatnikov][SweetOps_homepage] |
|---|---|---|---|---|---|---|---|
<!-- markdownlint-restore -->


  [osterman_homepage]: https://github.com/osterman
  [osterman_avatar]: http://s.gravatar.com/avatar/88c480d4f73b813904e00a5695a454cb?s=144


  [goruha_homepage]: https://github.com/goruha/
  [goruha_avatar]: http://s.gravatar.com/avatar/bc70834d32ed4517568a1feb0b9be7e2?s=144


  [aknysh_homepage]: https://github.com/aknysh/
  [aknysh_avatar]: https://avatars0.githubusercontent.com/u/7356997?v=4&u=ed9ce1c9151d552d985bdf5546772e14ef7ab617&s=144

  [guikcd_homepage]: https://github.com/guikcd
  [guikcd_avatar]: https://img.cloudposse.com/150x150/https://github.com/guikcd.png
  [velmoga_homepage]: https://github.com/velmoga
  [velmoga_avatar]: https://img.cloudposse.com/150x150/https://github.com/velmoga.png
  [pearson-lucas-dev_homepage]: https://github.com/pearson-lucas-dev
  [pearson-lucas-dev_avatar]: https://img.cloudposse.com/150x150/https://github.com/pearson-lucas-dev.png
  [DirectRoot_homepage]: https://github.com/DirectRoot
  [DirectRoot_avatar]: https://img.cloudposse.com/150x150/https://github.com/DirectRoot.png
  [SweetOps_homepage]: https://github.com/SweetOps
  [SweetOps_avatar]: https://img.cloudposse.com/150x150/https://github.com/SweetOps.png

[![README Footer][readme_footer_img]][readme_footer_link]
[![Beacon][beacon]][website]

  [logo]: https://cloudposse.com/logo-300x69.svg
  [docs]: https://cpco.io/docs?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=docs
  [website]: https://cpco.io/homepage?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=website
  [github]: https://cpco.io/github?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=github
  [jobs]: https://cpco.io/jobs?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=jobs
  [hire]: https://cpco.io/hire?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=hire
  [slack]: https://cpco.io/slack?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=slack
  [linkedin]: https://cpco.io/linkedin?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=linkedin
  [twitter]: https://cpco.io/twitter?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=twitter
  [testimonial]: https://cpco.io/leave-testimonial?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=testimonial
  [office_hours]: https://cloudposse.com/office-hours?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=office_hours
  [newsletter]: https://cpco.io/newsletter?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=newsletter
  [discourse]: https://ask.sweetops.com/?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=discourse
  [email]: https://cpco.io/email?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=email
  [commercial_support]: https://cpco.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=commercial_support
  [we_love_open_source]: https://cpco.io/we-love-open-source?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=we_love_open_source
  [terraform_modules]: https://cpco.io/terraform-modules?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=terraform_modules
  [readme_header_img]: https://cloudposse.com/readme/header/img
  [readme_header_link]: https://cloudposse.com/readme/header/link?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=readme_header_link
  [readme_footer_img]: https://cloudposse.com/readme/footer/img
  [readme_footer_link]: https://cloudposse.com/readme/footer/link?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=readme_footer_link
  [readme_commercial_support_img]: https://cloudposse.com/readme/commercial-support/img
  [readme_commercial_support_link]: https://cloudposse.com/readme/commercial-support/link?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-elastic-beanstalk-environment&utm_content=readme_commercial_support_link
  [share_twitter]: https://twitter.com/intent/tweet/?text=terraform-aws-elastic-beanstalk-environment&url=https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment
  [share_linkedin]: https://www.linkedin.com/shareArticle?mini=true&title=terraform-aws-elastic-beanstalk-environment&url=https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment
  [share_reddit]: https://reddit.com/submit/?url=https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment
  [share_facebook]: https://facebook.com/sharer/sharer.php?u=https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment
  [share_googleplus]: https://plus.google.com/share?url=https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment
  [share_email]: mailto:?subject=terraform-aws-elastic-beanstalk-environment&body=https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment
  [beacon]: https://ga-beacon.cloudposse.com/UA-76589703-4/cloudposse/terraform-aws-elastic-beanstalk-environment?pixel&cs=github&cm=readme&an=terraform-aws-elastic-beanstalk-environment
