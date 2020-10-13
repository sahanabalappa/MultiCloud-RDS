// configure GCE
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
}


// running the command to update the kubeconfig file
resource "null_resource" "cluster" {
provisioner "local-exec" {
	command ="gcloud container clusters get-credentials ${google_container_cluster.gcp_cluster.name}  --region ${google_container_cluster.gcp_cluster.location} --project ${google_container_cluster.gcp_cluster.project}"
	}
}