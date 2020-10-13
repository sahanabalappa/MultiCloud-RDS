// create a VPC
resource "google_compute_network" "gcp_vpc" {
	name =  "gcp-vpc"
	auto_create_subnetworks=false
	project= "ordinal-tower-287507"
}


// create a subnetwork
resource "google_compute_subnetwork" "gcp_subnet" {
    name          = "gcp-subnet"
	ip_cidr_range = "10.0.2.0/24"
	region        = "asia-southeast1"
	network       = google_compute_network.gcp_vpc.id
}


// create a firewall
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
