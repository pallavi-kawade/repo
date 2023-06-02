resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-task-family" # Replace with your desired task family name
  requires_compatibilities = ["FARGATE"]      # Add this line to specify FARGATE compatibility
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    task_role_arn            = aws_iam_role.ecs_task_role.arn



  network_mode = "awsvpc"
  cpu          = 256 # Define the CPU value
  memory       = 512 # Define the memory value



  container_definitions = <<EOF
[
  {
    "name": "vault-container",
    "image": "${aws_ecr_repository.vault_repo.repository_url}",
    "cpu": 256,
    "memory": 512,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "VAULT_ADDR",
        "value": "http://localhost:8200"
      },
      {
        "name": "VAULT_TOKEN",
        "value": "your-vault-token"
      }
    ]
  }
]
EOF
}

