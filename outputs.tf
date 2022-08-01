output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "ami_id" {
  value = data.aws_ami.latest_ubuntu.image_id
}