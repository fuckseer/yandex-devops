terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

resource "yandex_vpc_network" "network" {
  name = "portnova"
  subnet {
    name           = "portnova-a"
    zone           = var.yandex_zone
    v4_cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "yandex_compute_instance" "vm" {
  name         = "project"
  zone         = var.yandex_zone
  platform_id  = "standard-v1"
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "docker:${var.docker_image}"
    }
  }
  metadata = {
    ssh-keys = "${file("~/.ssh/id_ed25519.pub")}"
  }
  network_interface {
    subnet_id = yandex_vpc_network.network.subnet[0].id
    nat       = true
  }
}

variable "yandex_token" {
  description = "Yandex.Cloud OAuth token"
}

variable "yandex_cloud_id" {
  description = "Yandex.Cloud ID"
}

variable "yandex_folder_id" {
  description = "Yandex.Cloud folder ID"
}

variable "yandex_zone" {
  description = "Yandex.Cloud zone"
  default     = "ru-central1-a"
}

variable "docker_image" {
  description = "Docker image to deploy"
}
