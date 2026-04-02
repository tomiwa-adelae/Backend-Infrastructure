resource "aws_vpc" "main_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-${count.index}"
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.vpc_name}-private-${count.index}"
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.vpc_name}-igw"
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

#resource "aws_eip" "nat_eip" {
 # tags = {
 #   Name = "${var.vpc_name}-nat-eip"
 #   map-migrated = "mig26763"
  #  aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
   # environment = "Prod"
  #}
#}

#resource "aws_nat_gateway" "nat_gw" {
 # allocation_id = aws_eip.nat_eip.id
  #subnet_id     = aws_subnet.public_subnets[0].id
  #depends_on    = [aws_internet_gateway.igw]

  #tags = {
   # Name = "${var.vpc_name}-nat-gw"
   # map-migrated = "mig26763"
   # aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
   # environment = "Prod"
  #}
#}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.vpc_name}-public-rt"
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.vpc_name}-private-rt"
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

#resource "aws_route" "private_route" {
 # route_table_id         = aws_route_table.private_rt.id
 # destination_cidr_block = "0.0.0.0/0"
 # #nat_gateway_id         = aws_nat_gateway.nat_gw.id
#}


resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


resource "aws_route_table_association" "public_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_security_group" "alb_sg" {
  name        = "${var.vpc_name}-alb-sg"
  vpc_id      = aws_vpc.main_vpc.id
  description = "Allow inbound traffic to ALB"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-alb-sg"
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}


resource "aws_security_group" "ecs_sg" {
  name        = "${var.vpc_name}-ecs-sg"
  vpc_id      = aws_vpc.main_vpc.id
  description = "Allow traffic to ECS instances from ALB"

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-ecs-sg"
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.vpc_name}-rds-sg"
  vpc_id      = aws_vpc.main_vpc.id
  description = "Allow traffic to RDS instances from ECS"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-rds-sg"
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

resource "aws_security_group" "redis_sg" {
  name        = "${var.vpc_name}-redis-sg"
  vpc_id      = aws_vpc.main_vpc.id
  description = "Allow traffic to REDIS from ECS"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-redis-sg"
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

