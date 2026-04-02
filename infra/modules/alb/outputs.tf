output "backend_target_group_arn" {
  value = aws_lb_target_group.backend_target_group.arn
}


output "dns_name" {
  value = aws_lb.app_lb.dns_name
}

output "listener_arn" {
  description = "The ARN of the application load balancer listener"
  value       = aws_lb_listener.http_listener.arn
}

output "alb_name" {
  value = aws_lb.app_lb.name
  description = "The name of the Application Load Balancer"
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.app_lb.arn
}
