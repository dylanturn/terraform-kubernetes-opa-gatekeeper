locals {

  resource_labels = merge({
    "app.kubernetes.io/part-of" : "opa"
  }, var.labels)
}