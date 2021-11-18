resource "aws_autoscaling_policy" "target_tracking" {
  count                     = var.target_tracking ? 1 : 0
  name                      = "target-tracking-${var.name}"
  adjustment_type           = "ChangeInCapacity"
  estimated_instance_warmup = var.tt_warmup
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_elastic_beanstalk_environment.default.autoscaling_groups[0]

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.tt_metric_type
      resource_label = "app/${regex(data.aws_lb.eb-alb.arn, "\\/awseb\\-AWSEB-[a-zA-Z0-9]+\\/[a-zA-Z0-9]+")}/${regex(data.aws_resourcegroupstaggingapi_resources.eb-alb-tg.resource_tag_mapping_list.0.resource_arn, "\\/awseb\\-AWSEB-[a-zA-Z0-9]+\\/[a-zA-Z0-9]+")}"
    }
    target_value     = var.tt_target_value
    disable_scale_in = var.tt_disable_scale_in
  }
}

data "aws_lb" "eb-alb" {
  arn  = aws_elastic_beanstalk_environment.default.load_balancers[0]
}

# Regex \/awseb\-AWSEB-[a-zA-Z0-9]+\/[a-zA-Z0-9]+
data "aws_resourcegroupstaggingapi_resources" "eb-alb-tg" {
  resource_type_filters = ["elasticloadbalancingv2:targetgroup"]
  tag_filter {
    key    = "elasticbeanstalk:environment-name"
    values = ["${var.name}",]
  }
}
