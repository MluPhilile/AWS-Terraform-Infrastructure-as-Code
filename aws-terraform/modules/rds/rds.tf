resource "aws_subnet" "db_sub_1" {
  vpc_id            = module.vpc.id
  cidr_block        = module.vpc.cidr
  availability_zone = "eu-north-1a"
}
resource "aws_subnet" "db_sub_2" {
  vpc_id            = module.vpc.id
  cidr_block        = module.vpc.cidr
  availability_zone = "eu-north-1b"
}
resource "aws_db_subnet_group" "db_subnets" {
  name       = "local-db-subnet-group"
  subnet_ids = [aws_subnet.db_sub_1.id, aws_subnet.db_sub_2.id]
}

module "db" {


  source = "terraform-aws-modules/rds/aws"

  identifier = "myrdsdb"

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3a.large"
  allocated_storage = 5

  db_name  = "rds-db"
  username = "user"
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = module.vpc.default_sg_id#["sgr-03d80fa11410d7a44"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.subnet_group#aws_db_subnet_group.db_subnets["subnet-06734a0d5c9e5e2d2", "subnet-02877832e1db33389"]

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

