resource "kubernetes_deployment" "opa" {
  metadata {
    name      = "opa"
    namespace = kubernetes_namespace.opa_namespace.metadata.0.name
    labels = merge({
      "app" : "opa"
    }, local.resource_labels)
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" : "opa"
      }
    }
    template {
      metadata {
        name      = "opa"
        namespace = kubernetes_namespace.opa_namespace.metadata.0.name
        labels = merge({
          "app" : "opa"
        }, local.resource_labels)
      }
      spec {
        automount_service_account_token = true
        container {
          # WARNING: OPA is NOT running with an authorization policy configured. This
          # means that clients can read and write policies in OPA. If you are
          # deploying OPA in an insecure environment, be sure to configure
          # authentication and authorization on the daemon. See the Security page for
          # details: https://www.openpolicyagent.org/docs/security.html.
          name              = "opa"
          image             = "${var.image_repository}/${var.opa_image_name}:${local.versions[var.opa_version]["opa"]}"
          image_pull_policy = var.image_pull_policy
          args = [
            "run",
            "--server",
            "--tls-cert-file=/certs/tls.crt",
            "--tls-private-key-file=/certs/tls.key",
            "--addr=0.0.0.0:443",
            "--addr=http://127.0.0.1:8181",
            "--log-format=json-pretty",
            "--set=decision_logs.console=true"
          ]
          volume_mount {
            name       = "opa-server"
            mount_path = "/certs"
            read_only  = true
          }
          port {
            container_port = 443
          }
          readiness_probe {
            http_get {
              path   = "/health?plugins&bundle"
              scheme = "HTTPS"
              port   = 443
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }
          liveness_probe {
            http_get {
              path   = "/health"
              scheme = "HTTPS"
              port   = 443
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }
        }
        container {
          name              = "kube-mgmt"
          image             = "${var.image_repository}/${var.kube_mgmt_image_name}:${local.versions[var.opa_version]["kube-mgmt"]}"
          image_pull_policy = var.image_pull_policy
          args = [
            "--replicate-cluster=v1/namespaces",
            "--replicate=extensions/v1beta1/ingresses"
          ]
        }
        volume {
          name = "opa-server"
          secret {
            secret_name = kubernetes_secret.opa_server_cert.metadata.0.name
          }
        }
      }
    }
  }
}