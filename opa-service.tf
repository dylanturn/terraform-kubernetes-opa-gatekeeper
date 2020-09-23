resource "kubernetes_service" "opa" {
  metadata {
    name      = "opa"
    namespace = kubernetes_namespace.opa_namespace.metadata.0.name
    labels = merge({
      # Other labels go here
    }, local.resource_labels)
  }
  spec {
    selector = {
      "app" : "opa"
    }
    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = 443
    }
  }
}
