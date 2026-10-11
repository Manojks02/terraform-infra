variable "cluster_name" {
  description = "Unique EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Approved EKS Kubernetes version"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets across at least two AZs"
  type        = list(string)

  validation {
    condition     = length(distinct(var.private_subnet_ids)) >= 2
    error_message = "Provide at least two distinct private subnet IDs."
  }
}

variable "admin_role_arn" {
  description = "Existing IAM role granted cluster administrator access"
  type        = string
}

variable "management_security_group_id" {
  description = "Security group of the management host that runs kubectl"
  type        = string
}

variable "node_instance_types" {
  description = "Compatible x86_64 worker instance types"
  type        = list(string)
  default     = ["m6i.large"]
}

variable "node_scaling" {
  description = "Worker-node minimum, desired, and maximum capacity"
  type = object({
    min     = number
    desired = number
    max     = number
  })

  default = {
    min     = 3
    desired = 3
    max     = 6
  }

  validation {
    condition = (
      var.node_scaling.min >= 2 &&
      var.node_scaling.desired >= var.node_scaling.min &&
      var.node_scaling.max >= var.node_scaling.desired &&
      alltrue([
        for n in [
          var.node_scaling.min,
          var.node_scaling.desired,
          var.node_scaling.max
        ] : n == floor(n)
      ])
    )
    error_message = "Use whole numbers with 2 <= min <= desired <= max."
  }
}

variable "addon_versions" {
  description = "Explicit compatible EKS add-on versions"
  type = object({
    vpc_cni    = string
    coredns    = string
    kube_proxy = string
  })
}

variable "tags" {
  description = "Common AWS resource tags"
  type        = map(string)
  default     = {}
}
