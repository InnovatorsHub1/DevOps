output "alb_target_group_arn" {
  value = aws_alb_target_group.alb_target_group.arn
}

output "alb_dns_name" {
  value = aws_alb.application_load_balancer.dns_name 
}

output "alb_zone_id" {
  value = aws_alb.application_load_balancer.zone_id
}