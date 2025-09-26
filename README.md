# K6 Fargate with CloudWatch on AWS

## Introduction
This sample project provides an easy way to run load test with a K6 container in an ECS Fargate Task.
The metrics are collected by the CloudWatch Agent sidecar in the Fargate Task. 
This project also provides a CloudWatch Dashboard to view the load testing result in the CloudWatch.

## Architecture Diagram
![Architecture](img/k6-fargate.png?raw=true "Architecture")
## Requirements
- Terraform >= 1.5
- AWS CLI v2 (configured with appropriate credentials)
- Docker (to build and push the k6 image)

## Setup
- Create the infrastructure with Terraform
```
cd terraform
terraform init
terraform apply
```
- Note the output ecr_repository_url.
- Build and push the k6 image located in k6-scripts/ to the ECR repository created by Terraform:
```
AWS_REGION=${AWS_DEFAULT_REGION:-us-east-1}
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL
cd ../k6-scripts
docker build -t $ECR_URL:latest .
docker push $ECR_URL:latest
```

## Deploy 
The infrastructure is deployed by Terraform using the steps above (terraform init && terraform apply). Once applied, proceed to build and push the Docker image as described.

## Run Load Test
An ECS Cluster and a Task Definition will be deployed by Terraform.
Access the AWS Console, find the ECS Cluster.
Run a new task using the ECS Task Definition.

![Run Fargate Task](img/run_fargate_task.png?raw=true "Run Fargate Task")

### Types of Load testing

1. Smoke Testing - Basic tests with minimal load to verify system functionality
    - Validates if critical functions work under minimal load
    - Usually runs with few virtual users for a short duration
    - Used as a sanity check before more intensive testing

2. Load Testing - Tests system behavior under expected normal and peak load conditions
    - Measures system performance under specific expected load levels
    - Helps determine if the system meets performance requirements
    - Identifies bottlenecks under normal operating conditions

3. Stress Testing - Tests system behavior under extreme load conditions
    - Pushes system beyond normal operating capacity
    - Helps identify breaking points and failure modes
    - Validates system recovery capabilities

4. Spike Testing - Tests system response to sudden large spikes in load
    - Evaluates how system handles dramatic changes in user load
    - Tests system's ability to scale up and down quickly
    - Identifies performance issues during rapid load changes

5. Soak Testing (Endurance Testing) - Tests system behavior under sustained load
    - Runs for extended periods (hours or days)
    - Identifies memory leaks and performance degradation
    - Validates system stability over time

6. Scalability / Breakpoint Testing - Tests system's ability to scale with increasing load
    - Gradually increases load to identify scaling limits
    - Helps determine infrastructure requirements
    - Validates auto-scaling configurations

## Monitoring
This sample also include a CloudWatch Dashboard to simply monitoring the metrics for the load test.

![CloudWatch Dashboard](img/cloudwatch_dashboard.png?raw=true "CloudWatch Dashboard")

## References
* https://k6.io/docs/results-visualization/amazon-cloudwatch/
* https://github.com/aws/amazon-cloudwatch-agent/blob/master/amazon-cloudwatch-container-insights/ecs-task-definition-templates/deployment-mode/sidecar/cwagent-emf/README.md
* https://github.com/grafana/k6-example-cloudwatch-dashboards

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

