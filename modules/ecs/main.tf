locals {
  region = var.region
  name   = "${var.project_name}-${var.environment}"

  container_name = "backend"
  container_port = var.container_port

  mongodb_name = "mongodb"
  mongodb_port = 27017
}

# Cluster

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = local.name

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

   tags = merge({
    Environment = var.environment
  })
}

# Service

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name        = local.name
  cluster_arn = module.ecs_cluster.arn

  cpu    = 2048    # Changed to 2 vCPU (valid Fargate value)
  memory = 4096    # Changed to 4GB (valid Fargate value)

  enable_execute_command = true

  container_definitions = {
    
    (local.container_name) = {
      cpu       = 1024     # 1 vCPU
      memory    = 2048     # 2GB
      essential = true
      image     = "${var.ecr_repository_url}:latest"
      command   = ["npm", "run", "dev"]
      port_mappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "MONGODB_URI"
          value = "mongodb://${var.mongodb_username}:${var.mongodb_password}@${local.mongodb_name}:27017/test?authSource=admin"
        },
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "PUPPETEER_EXECUTABLE_PATH"
          value = "/usr/bin/chromium-browser"
        }
      ]

      linuxParameters = {
        capabilities = {
          add = ["SYS_ADMIN"]
        }
        sharedMemorySize = 1024  # 1GB in MB
      }

      readonly_root_filesystem = false
    }

    (local.mongodb_name) = {
      cpu       = 512      # 0.5 vCPU
      memory    = 1024     # 1GB
      essential = true
      image     = "mongo:6.0"
      port_mappings = [
        {
          name          = local.mongodb_name
          containerPort = local.mongodb_port
          hostPort      = local.mongodb_port
          protocol      = "tcp"
        }
      ]

      mount_points = [
        {
          sourceVolume  = "mongodb-data"
          containerPath = "/data/db"
          readOnly      = false
        },
        {
          sourceVolume  = "mongodb-tmp"
          containerPath = "/tmp"
          readOnly      = false
        }
      ]
      environment = [
        {
          name  = "MONGO_INITDB_ROOT_USERNAME"
          value = var.mongodb_username
        },
        {
          name  = "MONGO_INITDB_ROOT_PASSWORD"
          value = var.mongodb_password
        }
      ]
    }
  }

  volume = {
    mongodb-data = {
      efs_volume_configuration = {
        file_system_id = aws_efs_file_system.mongodb.id
      }
    }
    mongodb-tmp = {}  # Add this volume for /tmp
    coverage-data = {}  # Add volume for coverage data
    app-tmp = {        # Add volume for shared memory
      host = {
        source_path = "/dev/shm"
      }
    }
  }

  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = {
      client_alias = {
        port     = local.container_port
        dns_name = local.container_name
      }
      port_name      = local.container_name
      discovery_name = local.container_name
    }
  }

  load_balancer = {
    service = {
      target_group_arn = var.target_group_arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = var.private_subnet_ids
  security_group_rules = {
    nlb_ingress = {
      type        = "ingress"
      from_port   = local.container_port
      to_port     = local.container_port
      protocol    = "tcp"
      description = "Backend service port"
      cidr_blocks = [var.vpc_cidr_block]
    }
    mongodb_ingress = {
      type        = "ingress"
      from_port   = local.mongodb_port
      to_port     = local.mongodb_port
      protocol    = "tcp"
      description = "MongoDB port"
      self        = true
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = merge({
    Environment = var.environment
  })
}

# Supporting Resources

resource "aws_service_discovery_http_namespace" "this" {
  name        = local.name
  description = "CloudMap namespace for ${local.name}"
   tags = merge({
    Environment = var.environment
  })
}

resource "aws_efs_file_system" "mongodb" {
  creation_token = "mongodb-data"
  encrypted      = true

  tags = merge({
    Environment = var.environment
  })
}

resource "aws_efs_mount_target" "mongodb" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.mongodb.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = "${local.name}-efs"
  description = "Allow EFS access from ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [module.ecs_service.security_group_id]
  }

  tags = merge({
    Environment = var.environment
  })
}