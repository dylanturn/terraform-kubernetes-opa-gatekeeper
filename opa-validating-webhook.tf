resource "kubernetes_validating_webhook_configuration" "opa_validating_webhook" {
  metadata {
    name = "opa-validating-webhook"
    labels = merge({

    }, local.resource_labels)
  }
  webhook {
    name = "validating-webhook.openpolicyagent.org"
    namespace_selector {
      match_expressions {
        key      = "openpolicyagent.org/webhook"
        operator = "NotIn"
        values = [
          "ignore"
        ]
      }
    }
    rule {
      api_groups   = ["*"]
      api_versions = ["*"]
      operations   = ["CREATE", "UPDATE"]
      resources    = ["*"]
    }
    client_config {
      ca_bundle = var.cluster_certificate_authority
      service {
        name      = kubernetes_service.opa.metadata.0.name
        namespace = kubernetes_namespace.opa_namespace.metadata.0.name
      }
    }
  }
}