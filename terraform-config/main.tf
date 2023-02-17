provider "google" {
  project = var.project-id
}


variable "ssh-keys" {}
variable "project-id" {}
variable "ssh-keys-private" {}
variable "root-pass" {}


resource "google_compute_instance" "jenkins" {

  # count = 3
  project      = "protean-bit-376817"
  name         = "jenkins"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  
 boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
  tags = ["project-instances","http-server"]

  metadata = {
    "ssh-keys" = var.ssh-keys
  }

  provisioner "local-exec" {
    working_dir = "../ansible-config"
    command = "ssh-keygen -R ${google_compute_instance.jenkins.network_interface.0.access_config.0.nat_ip} && ansible-playbook --inventory ${google_compute_instance.jenkins.network_interface.0.access_config.0.nat_ip}, --private-key=${var.ssh-keys-private} -e 'ansible_become_password=${var.root-pass}' install-jenkins.yaml"
    
  }

}


resource "google_compute_instance" "sonarqube" {

  # count = 3
  project      = "protean-bit-376817"
  name         = "sonarqube"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  
 boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
  tags = ["project-instances","http-server"]

  metadata = {
    "ssh-keys" = var.ssh-keys
  }

  provisioner "local-exec" {
    working_dir = "../ansible-config"
    command = "ssh-keygen -R ${google_compute_instance.sonarqube.network_interface.0.access_config.0.nat_ip} && ansible-playbook --inventory ${google_compute_instance.sonarqube.network_interface.0.access_config.0.nat_ip}, --private-key=${var.ssh-keys-private} -e 'ansible_become_password=${var.root-pass}' install-sonarqube.yaml"
    
  }

}

# resource "google_compute_instance" "nexus" {

#   # count = 3
#   project      = "protean-bit-376817"
#   name         = "nexus"
#   machine_type = "n1-standard-1"
#   zone         = "us-central1-a"
  
#  boot_disk {
#     initialize_params {
#       image = "ubuntu-os-cloud/ubuntu-2004-lts"
#     }
#   }

#   network_interface {
#     network = "default"
#     access_config {
#     }
#   }
#   tags = ["project-instances","http-server"]

#   metadata = {
#     "ssh-keys" = var.ssh-keys
#   }

#   provisioner "local-exec" {
#     working_dir = "../ansible-config"
#     command = "ssh-keygen -R ${google_compute_instance.nexus.network_interface.0.access_config.0.nat_ip} && ansible-playbook --inventory ${google_compute_instance.nexus.network_interface.0.access_config.0.nat_ip}, --private-key=${var.ssh-keys-private} -e 'ansible_become_password=${var.root-pass}' install-nexus.yaml"
    
#   }

# }





resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080","8081","9000"] # 8080 for jenkins , 8081 for nexus , 9000 for sonarqube
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["project-instances"]
}
  






# resource "google_container_cluster" "primary" {
#   name               = "primary-k8s-cluster"
#   location           = "us-central1-a"

#   remove_default_node_pool = true
#   initial_node_count = 1

  
# }

# resource "google_container_node_pool" "primary_nodes" {
#   name       = google_container_cluster.primary.name
#   location   = "us-central1-a"
#   cluster    = google_container_cluster.primary.name
#   node_count = 2

#   node_config {
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#     ]

#     labels = {
#       env = var.project-id
#     }

#     # preemptible  = true
#     machine_type = "n1-standard-1"
#     tags         = ["gke-node", "${var.project-id}-gke"]
#     metadata = {
#       disable-legacy-endpoints = "true"
#     }
#   }
# }
  




