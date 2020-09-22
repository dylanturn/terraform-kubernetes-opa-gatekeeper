resource "kubernetes_namespace" "opa_namespace" {
  metadata {
    name = var.namespace
    labels = merge({
      "app.kubernetes.io/name" : var.namespace
      "app.kubernetes.io/component" : "namespace"
      "openpolicyagent.org/webhook" : "ignore"
    }, local.resource_labels)
  }
}