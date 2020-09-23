resource "kubernetes_config_map" "opa_default_system_main" {
  metadata {
    name      = "opa-default-system-main"
    namespace = kubernetes_namespace.opa_namespace.metadata.0.name
    annotations = {
      openpolicyagent.org/policy-status = {}
    }
    labels = merge({
      # Other labels go here
    }, local.resource_labels)
  }
  data = {
    "main" : templatefile("${path.module}/templates/opa-default-system-main.tmpl", {})
  }
  lifecycle {
    ignore_changes = [
      metadata.0.annotations["openpolicyagent.org/policy-status"]
    ]
  }
}