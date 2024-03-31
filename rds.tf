resource "aws_db_instance" "rds_instance" {
  allocated_storage      = 20
  engine                 = "mariadb"
  engine_version         = "10.5"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = var.db_password
  storage_type           = "Standard"
  identifier             = "task-pro-rds"
  publicly_accessible    = true
  apply_immediately      = true
  db_name                = "TaskPro"
  multi_az               = false
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.security_group.id]

  tags = {
    Name = "rds-instance"
  }
}

output "rds_connection_url" {
  value = aws_db_instance.rds_instance.endpoint
}

resource "aws_db_subnet_group" "db_subnet" {
  name = "dev-db-subnet"
  subnet_ids = [
    aws_subnet.public_subnet_az1.id,
    aws_subnet.public_subnet_az2.id,
  ]
}

variable "db_password" {
  description = "Password for the RDS MariaDB instance"
}