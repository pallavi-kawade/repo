# Define provider and region
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# Create ECS cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-ecs-cluster" # Replace with your desired cluster name
}

# Create IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach necessary policies to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  role       = aws_iam_role.ecs_task_execution_role.name
}


# Create a service to run the task
resource "aws_ecs_service" "my_service" {
  name            = "my-ecs-service" # Replace with your desired service name
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1


  deployment_controller {
    type = "ECS"
  }

  launch_type = "FARGATE"

  network_configuration {
    subnets         = ["subnet-04def20bc441967fe", "subnet-0c53950d5213f8db7"] # Replace with your subnet IDs
    security_groups = ["sg-80e53fd5"]                                          # Replace with your security group IDs
  }

  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:897708493501:targetgroup/target-gr/01fbfb5ffda5c2b4"
    # Replace with your target group ARN
    container_name = "vault-container"
    container_port =  80

  }

  depends_on = [
    aws_ecs_task_definition.my_task_definition

  ]
}



resource "aws_iam_role_policy_attachment" "ecs_service_role_attachment" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}



# Define the ECR repository
resource "aws_ecr_repository" "vault_repo" {
  name = "vault-repo"
}

resource "null_resource" "build_and_push_image" {
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
      aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 897708493501.dkr.ecr.us-east-1.amazonaws.com
      docker build -t vault-repo .
      docker tag vault-repo:latest 897708493501.dkr.ecr.us-east-1.amazonaws.com/vault-repo:latest
      docker push 897708493501.dkr.ecr.us-east-1.amazonaws.com/vault-repo:latest

    EOF
  }
}

