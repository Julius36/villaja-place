terraform{
  required_providers{
    minikube = {
      source = "scott-the-programmer/minikube"
      version = "0.4.2"
    }
  }
} 

provider "minikube" {
  kubernetes_version = "v1.30.2"
}

resource "minikube_cluster" "docker" {
  driver       = "docker"
  cluster_name = "terraform-provider-minikube-acc-docker"
  addons = [
    "default-storageclass",
    "storage-provisioner"
  ]
}