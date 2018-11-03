variable "gcp_project_id" {}
variable "gcp_region" {}
variable "gcp_zone" {}
variable "server_port_web" {}
variable "num_instances" {
  default = 4
}

provider "google" {
  project = "${var.gcp_project_id}"
  region  = "${var.gcp_region}"
  zone    = "${var.gcp_zone}"
}

resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_compute_instance" "default" {
  count        = "${var.num_instances}"
  name         = "flask-vm-${random_id.instance_id.hex}-${count.index}"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Make sure flask is installed on all new instances for later steps
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; echo Hello-World > index.html; nohup python -m SimpleHTTPServer ${var.server_port_web} &"

  network_interface {
    # A default network is created for all GCP projects
    network       = "${google_compute_network.vpc_network.self_link}"
    access_config = {}
  }
}

resource "google_compute_firewall" "default" {
  name    = "app-firewall"
  network = "terraform-network"

  allow {
    protocol = "tcp"
    ports    = ["${var.server_port_web}"]
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

output "ipv4_address" {
  value = "${google_compute_instance.default.0.network_interface.0.access_config.0.nat_ip}"
}
