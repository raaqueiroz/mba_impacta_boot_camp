variable role_arn {
    description = "Arn completo da role AWS"
    type = string
}

variable eks_name {
    description = "Nome do cluster"
    type = string
    default = "jenkins"
}

variable efs_token {
    description = "Token do EFS"
    type = string
    default = "jenkins-efs"
}

variable nodegroup_instance_types {
    description = "Tipos de instancias do node group"
    type = list
    default = ["t3.medium"]
}

variable nodegroup_disk_size {
    description = "Tamanho do disco das instancias do node group"
    type = string
    default = "20"
}

variable nodegroup_capacity_type {
    description = "Tipos de capacity das instancias do node group"
    type = string
    default = "SPOT"
}
