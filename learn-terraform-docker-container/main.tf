# Define CloudComp group number
variable "group_number" {
  type    = string
  default = "14"
}

## OpenStack credentials can be used in a more secure way by using
## cloud.yaml from https://private-cloud.informatik.hs-fulda.de/project/api_access/clouds.yaml/

# or by using env vars exported from openrc here,
# e.g., using 'export TF_VAR_os_password=$OS_PASSWORD'

# Define OpenStack credentials, project config etc.
locals {
  auth_url        = "https://10.32.4.29:5000/v3"
  user_name       = "CloudComp${var.group_number}"
  user_password   = "demo"
  tenant_name     = "CloudComp${var.group_number}"
  router_name     = "CloudComp${var.group_number}-router"
  image_name      = "ubuntu-22.04-jammy-server-cloud-image-amd64"
  flavor_name     = "m1.small"
  region_name     = "RegionOne"
  floating_net    = "ext_net"
  dns_nameservers = ["10.33.16.100"]
}

# Define OpenStack provider
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 2.0.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = local.user_name
  tenant_name = local.tenant_name
  password    = local.user_password
  auth_url    = local.auth_url
  region      = local.region_name
  insecure    = true
}

###########################################################################
#
# create ssh keypair
#
###########################################################################

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "openstack_compute_keypair_v2" "terraform-keypair" {
  name       = "bonus-project-pubkey"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content          = tls_private_key.ssh_key.private_key_pem
  filename         = "${path.module}/ssh_keys/generated_private_key.pem"
  file_permission  = "0600"
}


###########################################################################
#
# create security group
#
###########################################################################

resource "openstack_networking_secgroup_v2" "terraform-secgroup" {
  name        = "my-terraform-secgroup"
  description = "for terraform instances"
}

resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup.id
}

###########################################################################
#
# create network
#
###########################################################################

resource "openstack_networking_network_v2" "terraform-network-1" {
  name           = "my-terraform-network-1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "terraform-subnet-1" {
  name            = "my-terraform-subnet-1"
  network_id      = openstack_networking_network_v2.terraform-network-1.id
  cidr            = "192.168.250.0/24"
  ip_version      = 4
  dns_nameservers = local.dns_nameservers
}

resource "openstack_networking_port_v2" "port_1" {
  name               = "port_1"
  network_id         = openstack_networking_network_v2.terraform-network-1.id
  admin_state_up     = "true"
  security_group_ids = [openstack_networking_secgroup_v2.terraform-secgroup.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.terraform-subnet-1.id
  }
}

data "openstack_networking_router_v2" "router-1" {
  name = local.router_name
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = data.openstack_networking_router_v2.router-1.id
  subnet_id = openstack_networking_subnet_v2.terraform-subnet-1.id
}

###########################################################################
#
# create instance
#
###########################################################################

resource "openstack_compute_instance_v2" "terraform-instance-1" {
  name            = "my-terraform-instance-1"
  image_name      = local.image_name
  flavor_name     = local.flavor_name
  key_pair        = openstack_compute_keypair_v2.terraform-keypair.name
  security_groups = [openstack_networking_secgroup_v2.terraform-secgroup.id]

  depends_on = [openstack_networking_subnet_v2.terraform-subnet-1]

  network {
    port = openstack_networking_port_v2.port_1.id
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get -y install apache2
    rm /var/www/html/index.html
    cat > /var/www/html/index.html << INNEREOF
    <!DOCTYPE html>
    <html>
      <body>
        <h1>It works!</h1>
        <p>hostname</p>
      </body>
    </html>
    INNEREOF
    sed -i "s/hostname/terraform-instance-1/" /var/www/html/index.html
    sed -i "1s/$/ terraform-instance-1/" /etc/hosts
  EOF
}

###########################################################################
#
# assign floating IP to instance
#
###########################################################################

resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = local.floating_net
}

resource "openstack_networking_floatingip_associate_v2" "terraform-instance-1-ip" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  port_id     = openstack_networking_port_v2.port_1.id
}

###########################################################################
#
# outputs
#
###########################################################################

output "vip_addr" {
  value = openstack_networking_floatingip_v2.fip_1
}

output "private_key_pem" {
  description = "Private SSH Key PEM"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

resource "local_file" "floating_ip" {
  content  = openstack_networking_floatingip_v2.fip_1.address
  filename = "${path.module}/floating_ip/floating_ip.txt"
}
