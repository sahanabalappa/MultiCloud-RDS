provider "google" {
    credentials = file("C:\\Users\\sahanab\\Downloads\\credentials.json")
    project     = "ordinal-tower-287507"
	region      = "asia-south1"
}
provider "aws" {
    region     = "ap-south-1"
}

module "MultiCloud" {
    source = "./modules"
    
}