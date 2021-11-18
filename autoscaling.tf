resource "aws_autoscaling_policy" "target_tracking" {
  count                     = var.target_tracking ? 1 : 0
  name                      = "target-tracking ${var.elastic_beanstalk_application_name}"
  scaling_adjustment        = var.tt_scaling_adjustment
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = var.tt_cooldown
  estimated_instance_warmup = var.tt_warmup
  autoscaling_group_name    = aws_elastic_beanstalk_environment.default.autoscaling_groups[0]

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.tt_metric_type
    }
    target_value     = var.tt_target_value
    disable_scale_in = var.tt_disable_scale_in
  }
}
