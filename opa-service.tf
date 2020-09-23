resource "kubernetes_service" "opa" {
  metadata {
    name      = "opa"
    namespace = kubernetes_namespace.opa_namespace.metadata.0.name
    labels = merge({
      # Other labels go here
    }, local.resource_labels)
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-internal": true
      "service.beta.kubernetes.io/load-balancer-source-ranges": "10.0.0.0/8"
    }
  }
  spec {
    type = "LoadBalancer"
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