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
resource "kubernetes_default_service_account" "example" {
  metadata {
    namespace = kubernetes_namespace.opa_namespace.metadata.0.name
  }
  secret {
    name = kubernetes_secret.namespace_default_token.metadata.0.name
  }
}

resource "kubernetes_secret" "namespace_default_token" {
  metadata {
    generate_name = "${kubernetes_namespace.opa_namespace.metadata.0.name}-token-"
    labels        = merge({}, local.resource_labels)
  }
}