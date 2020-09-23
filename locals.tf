locals {
  versions = {
    "0.11.0" : {
      "opa" : "0.11.0"
      "kube-mgmt" : "0.8"
    }
    "0.23.2" : {
      "opa" : "0.23.2"
      "kube-mgmt" : "0.11"
    }
  }
  resource_labels = merge({
    "app.kubernetes.io/part-of" : "opa"
  }, var.labels)
}
