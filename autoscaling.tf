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
      resource_label = "elasticbeanstalk:environment-name:${var.name}"
    }
    target_value     = var.tt_target_value
    disable_scale_in = var.tt_disable_scale_in
  }
}
