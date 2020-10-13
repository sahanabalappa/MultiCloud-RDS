# MultiCloud-RDS

## Multi-Cloud: RDS on AWS and Kubernetes Cluster on GCP
Task Description:
####Deploy the WordPress application on Kubernetes and AWS using terraform including the following steps;
1. Write an Infrastructure as code using Terraform, which automatically deploy the WordPress application
2. On AWS, use RDS service for the relational database for WordPress application.
3. Deploy WordPress as a container either on top of Minikube or EKS or Fargate service on AWS
4. The WordPress application should be accessible from the public world if deployed on AWS or through workstation if deployed on Minikube.
####Amazon Relational Database Service (Amazon RDS):
  It's a web service that makes it easier to set up, operate, and scale a relational database in the AWS Cloud. It provides cost-efficient, resizable capacity for an industry-standard relational database and manages common database administration tasks. (from the internet)
So, we can use Amazon RDS to create a Database. We want our WordPress to be managed my k8s to avoid downtime, for that we can either use minikube or amazon EKS service. But EKS is not very convenient to use. So, we can use the Kubernetes engine on GCP. So, this will be a Multi-Cloud Setup.
For understanding the project, you need some prior knowledge. 
##### Before starting with the project, you should have the following things
GCP Account
AWS Account
Terraform
Kubectl command installed
AWS CLI
Google Cloud SDK installed
AWS IAM User
GCP credentials

###Terraform
provider "google" {
    credentials = file("C:\\Users\\Rajnish - The Great\\Downloads\\credentials.json")
    project     = "ordinal-tower-287507"
 region      = "asia-south1"
}
provider "aws" {
    region     = "ap-south-1"
}module "MultiCloud" {
    source = "./modules"
    
}
### We have written code for launching different services in different files known as modules for better management purposes.
## 1. Creating VPC, Subnet, and Firewall in GCP
// create a VPC
resource "google_compute_network" "gcp_vpc" {
 name =  "gcp-vpc"
 auto_create_subnetworks=false
 project= "ordinal-tower-287507"
}// create a subnetwork
resource "google_compute_subnetwork" "gcp_subnet" {
    name          = "gcp-subnet"
 ip_cidr_range = "10.0.2.0/24"
 region        = "asia-southeast1"
 network       = google_compute_network.gcp_vpc.id
}// create a firewall
resource "google_compute_firewall" "default" {
 name    = "gcp-firewall"
 network = google_compute_network.gcp_vpc.name
 allow {
        protocol = "icmp"
 }
 allow {
        protocol = "tcp"
        ports    = ["80","22"]
 }
}
This will create a VPC, subnet, and firewall for launching the k8s cluster.
### 2. Creating Cluster on GCP
resource "google_container_cluster" "gcp_cluster" {
 name               = "gcp-cluster"
 location           = "asia-southeast1"
 initial_node_count = 1
 master_auth {
        username = ""
        password = ""
        client_certificate_config {
            issue_client_certificate = false
        }
    }
    node_config {
        machine_type= "n1-standard-1"
    }
    network= google_compute_network.gcp_vpc.name
    project="ordinal-tower-287507"
    subnetwork=google_compute_subnetwork.gcp_subnet.name
}// running the command to update the kubeconfig file
resource "null_resource" "cluster" {
provisioner "local-exec" {
 command ="gcloud container clusters get-credentials ${google_container_cluster.gcp_cluster.name}  --region ${google_container_cluster.gcp_cluster.location} --project ${google_container_cluster.gcp_cluster.project}"
 }
}
This will create our cluster and we have disabled certificate checking. If you enable it, you have to provide the certificates otherwise you will get error x509 certificate signed by unknown authority.
Note: Create Cluster in Asia-southeast1. In other regions, you may encounter errors. You can run only one cluster at a time if you are a basic GCP user.
### 3. Creating Database on Amazon RDS
resource "aws_db_instance" "wp_db" {
        allocated_storage    = 20
        storage_type         = "gp2"
        engine               = "mysql"
        engine_version       = 5.7
        instance_class       = "db.t2.micro"
        name                 = "db"
        username             = "admin"
        password             = "the_great"
        parameter_group_name = "default.mysql5.7"
        publicly_accessible  = true
        skip_final_snapshot  = true
 }
This will create our RDS database and it will be publicly accessible. You can create separate security groups and vpc for this, but I have used default one.
Note: Source in inbound and outbound rule of sg should be set to anywhere otherwise you won't be able to connect to the database
