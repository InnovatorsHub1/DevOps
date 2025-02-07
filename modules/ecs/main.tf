locals {
  region = var.region
  name   = "${var.project_name}-${var.environment}"

  container_name = "backend"
  container_port = var.container_port
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

  cpu    = 1024    # Changed to 1 vCPU
  memory = 2048    # Changed to 2GB

  enable_execute_command = true

  container_definitions = {
    (local.container_name) = {
      cpu       = 512      # 0.5 vCPU
      memory    = 1024     # 1GB
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
        sharedMemorySize = 1024
      }

      readonly_root_filesystem = false
    }
  }

  volume = {
    coverage-data = {}
    app-tmp = {
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