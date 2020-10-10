provider "aws" {
  region = "ap-south-1"
  profile = "Deepak"


}

resource "aws_security_group" "allow_sql" {


  name        = "allow_sql"
  description = "Allow sql inbound traffic"
  vpc_id      = "vpc-cd879aa5"


  ingress {
    description = "sql from VPC"
    from_port   = 3306
    to_port     = 3306
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
    Name = "allow_sql"
  }
}


provider "kubernetes" {
 config_context_cluster = "minikube"


}

resource "kubernetes_deployment" "wpapp" {
  metadata {
    name = "mywp"
    labels = {
            type = "frontendapp"
        }
 }
spec {
  replicas = 1
  strategy {
    type = "RollingUpdate"
  }
  selector {
    match_labels = {
      app = "wordpress"
      dc = "IN"
      env = "prod"
    } 
 }
  template {
    metadata {
      labels = {
        app = "wordpress"
        dc = "IN"
        env = "prod"
   }
  }
  spec {
    container {
      image = "wordpress:4.8-apache"
      name = "wpcont" 
    }
   }
  }
 }


}


resource "kubernetes_service" "mylb" {
  depends_on = [
      kubernetes_deployment.wpapp,
    ]
 metadata {
  name = "wplb"
 }
 spec {
  selector = {
    app = "wordpress"
  }
  port {
    protocol = "TCP"
    node_port   = 30081 
    port = 80
    target_port = 80
  }
  type = "NodePort"
 }


}


resource "aws_db_instance" "myrds" {
  allocated_storage    = 20
  identifier           = "db-instance"
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.30"
  instance_class       = "db.t2.micro"
  name                 = "myrds"
  username             = "Deepak"
  password             = "dp12311"
  iam_database_authentication_enabled = true
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible = truedepends_on = [
      kubernetes_service.mylb,
    ]
  tags = {
    Name = "mydb"
  }
}