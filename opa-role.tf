resource "kubernetes_role" "configmap_modifier" {
  metadata {
    name      = "configmap-modifier"
    namespace = kubernetes_namespace.opa_namespace.metadata.0.name
    labels = merge({
      # Other labels go here
    }, local.resource_labels)
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["update", "patch"]
  }
}
resource "kubernetes_role_binding" "opa_configmap_modifier" {
  metadata {
    name      = "opa-configmap-modifier"
    namespace = kubernetes_namespace.opa_namespace.metadata.0.name
    labels = merge({
      # Other labels go here
    }, local.resource_labels)
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.configmap_modifier.metadata.0.name

  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "system:serviceaccounts:opa"
    namespace = kubernetes_namespace.opa_namespace.metadata.0.name
  }
}
