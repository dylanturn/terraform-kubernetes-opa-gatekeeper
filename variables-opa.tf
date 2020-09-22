variable "namespace" {
  type        = string
  description = "The namespace this Open Policy Agent deployment will reside in."
  default     = "opa"
}
variable "opa_version" {
  type        = string
  description = "The version of OPA to pull"
  default     = "0.11.0"
}
variable "kube_mgmt_version" {
  type        = string
  description = "The version of the `kube-mgmt` image to pull"
  default     = "0.8"
}
variable "opa_image_name" {
  type        = string
  description = "The image to use for the `opa` deployment"
  default     = "openpolicyagent/opa"
}
variable "kube_mgmt_image_name" {
  type        = string
  description = "The image to use for the `opa-kube-mgmt` deployment"
  default     = "openpolicyagent/kube-mgmt"
}
variable "image_repository" {
  type        = string
  description = "The image repository to use when pulling images."
  default     = "registry.hub.docker.com"
}
variable "image_pull_policy" {
  type        = string
  description = "Determines when the image should be pulled prior to starting the container. `Always`: Always pull the image. | `IfNotPresent`: Only pull the image if it does not already exist on the node. | `Never`: Never pull the image"
  default     = "Always"
}
variable "cluster_certificate_authority" {
  type        = string
  description = "The certificate authority data for the cluster this deployment is running in."
}
variable "labels" {
  type        = map(string)
  description = "Extra Kubernetes labels to include with the resources created by this module"
  default     = {}
}