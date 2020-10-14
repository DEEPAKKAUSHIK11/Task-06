# Task-06

Task-06:- In this Task We will launch the WordPress application over Kubernetes (from minikube) & the DataBase over AWS through RDS service of AWS. We will also create a LoadBalancer to expose the deployment of our WordPress. This whole Infrastructure, we will launch using Terraform with just one single command.

Introducing the Amazon Relational Database Service, or RDS. At RDS, you still run a relational database of the flavor of your choosing, whether you're talking about a MySQL database, an Oracle database, a PostgreSQL database, or other flavors.

Kubernetes: It is an example of container orchestration engine programs, that manages the containers. It is a single program that offers fault tolerance, Scaling, loadbalancing , reverse proxy, service discovery. So, basically it is a PAAS , here, the developer need not worry about the architecture and can directly deploy its application.

Task:-

So, we going to deploy our WordPress application over Kubernetes, and since this application requires a database, we will create a database in Amazon RDS service.

Deploy the WordPress application on Kubernetes and AWS using terraform including the following steps:-

    Write an Infrastructure as code using Terraform, which automatically deploy the WordPress application
    On AWS, use RDS service for the relational database for WordPress application.
    Deploy WordPress as a container either on top of Minikube or EKS or Fargate service on AWS.
    The WordPress application should be accessible from the public world if deployed on AWS or through workstation if deployed on Minikube.

Pre-Requisites:-

    Should have an AWS account i.e., the login to AWS from CLI using the command:
    Minikube and Kubernetes must be installed and configured
    Terraform should be installed and configured in your system

Step 1: First configure the terraform code which is the basis of this project as it will automatically launch the whole infrastructure for us.

* Set provider for Cloud services, here it is AWS

provider "aws" {
  region = "ap-south-1"
  profile = "Deepak"

}

* Security_group:-

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

No alt text provided for this image


* Set or initialize provider for Kubernetes (K8S)

we are launching Kubernetes through Minikube but there are other ways for the same as from EKS & Fargate service from AWS or GKE service from GCP.

provider "kubernetes" {
 config_context_cluster = "minikube"

}

Create Deployment for WordPress Application

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



This code will launch a deployment having two pods each having word press site running also deployment will watch the pods and ig due to any reason pod will go down it will launch another pod.

Now we expose the deployment for outside connectivity and also will only allow to connect to 80 port which is port for wordpress site

* Creating Load Balancer for the above Deployment, to expose our WordPress app to the outer world:

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


* Creating AWS RDS which is a DB service to connect to our WordPress Application:

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

* print the IP address of our MySQL DB launched using AWS RDS:-

output "ip" {
  value = aws_db_instance.myrds.address

  
}

Step2: We will use the Terraform code that we created above to launch the whole infrastructure.

Initiate the terraform code:-

This command will initialize the terraform code & download the required plugins from the internet.

terraform init

No alt text provided for this image

Validate the Terraform code:-
No alt text provided for this image

Execute or apply the Terraform code:-

terraform apply -auto-approve

No alt text provided for this image

* The whole infrastructure launched successfully & it also printed the DB IP address (DB Host):-
No alt text provided for this image

Here we can see that our WordPress deployment was launched & also exposed to the outer world.

The WordPress app is also accessible, let’s login:
No alt text provided for this image

*Enter DB details provided while configuring AWS RDS, also enter the DB Host:

through this, the WordPress Application connects to the DB launched by AWS RDS.

* Now create a username & password, then log in.

* Here we are in the Dashboard, now we can create our Blog post.
No alt text provided for this image

* We can see even from the AWS console that AWS RDS was created for us by Terraform.
No alt text provided for this image

* Destroying the infrastructure:

this was just a project which we completed successfully, & now we don’t require this infrastructure any more, hence we should destroy it to prevent unnecessary billing. To destroy the whole infrastructure we require just one command:

terraform destroy -auto-approve

No alt text provided for this image

This was a great project which demonstrated End-to-End Automation while working with multiple different technologies, here namely Kubernetes & AWS RDS. The most crucial thing about AWS RDS is that the DB is managed by AWS, which is a painful thing to do manually. The complete infrastructure we launched over AWS Cloud with the help of Terraform which was created & destroyed with just one command.

Thank You....

Blog Link:- https://www.linkedin.com/pulse/task-06-deploying-wordpress-server-using-aws-rds-minikube-kaushik/
