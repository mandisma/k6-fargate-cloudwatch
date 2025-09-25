output "ecr_repository_url" {
  description = "ECR repository URL to push your k6 image"
  value       = aws_ecr_repository.k6.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "security_group_id" {
  value = aws_security_group.task.id
}