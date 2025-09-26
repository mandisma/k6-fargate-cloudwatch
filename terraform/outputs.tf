output "ecr_repository_url" {
  description = "ECR repository URL to push your k6 image"
  value       = aws_ecr_repository.k6.repository_url
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "The name of the ECS Cluster"
}

# output "vpc_id" {
#   value       = aws_vpc.this.id
#   description = "The ID of the VPC"
# }
#
# output "public_subnet_ids" {
#   value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
#   description = "The IDs of the public subnets"
# }

output "security_group_id" {
  value       = aws_security_group.task.id
  description = "The ID of the task security group"
}