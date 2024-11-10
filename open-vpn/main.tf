data "aws_ami" "openvpn" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}
locals {
  security_group_rules = {
    "http" = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "allow egress to internet" = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "Allow OpenVPN" = {
      type        = "ingress"
      from_port   = 1194
      to_port     = 1194
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    "Allow HTTPS" = {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "Allow SSH" = {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
resource "aws_instance" "openvpn_server" {
  ami                         = data.aws_ami.openvpn.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.openvpn_sg.id]
  key_name                    = var.key_name #need to create key-pair in aws then save the pem file 

  user_data = <<-EOF
              #!/bin/bash
              sudo -i
              # Resolve yum lock if exists and update system
              if pgrep yum > /dev/null; then
              pkill yum
              fi
              yum update -y
              amazon-linux-extras install epel -y
              # Install required packages
              yum install -y openvpn easy-rsa iptables-services

              # Set up Easy RSA
              mkdir -p /etc/openvpn/easy-rsa
              cd /etc/openvpn/easy-rsa
              cp -r /usr/share/easy-rsa/3/* /etc/openvpn/easy-rsa/
              ./easyrsa init-pki
              ./easyrsa --batch build-ca nopass req-cn=""
              ./easyrsa gen-dh
              ./easyrsa build-server-full server nopass
              ./easyrsa build-client-full client1 nopass
              openvpn --genkey --secret /etc/openvpn/ta.key

              # Configure OpenVPN server
              bash -c 'cat <<EOF1 > /etc/openvpn/server.conf
              port 1194
              proto udp
              dev tun
              ca /etc/openvpn/easy-rsa/pki/ca.crt
              cert /etc/openvpn/easy-rsa/pki/issued/server.crt
              key /etc/openvpn/easy-rsa/pki/private/server.key
              dh /etc/openvpn/easy-rsa/pki/dh.pem
              tls-auth /etc/openvpn/ta.key 0
              cipher AES-256-CBC
              auth SHA256
              server 10.8.0.0 255.255.255.0
              ifconfig-pool-persist ipp.txt
              push "redirect-gateway def1 bypass-dhcp"
              push "dhcp-option DNS 8.8.8.8"
              push "dhcp-option DNS 8.8.4.4"
              keepalive 10 120
              persist-key
              persist-tun
              status openvpn-status.log
              verb 3
              EOF1'

              systemctl enable openvpn@server
              systemctl start openvpn@server

              # Enable IP forwarding and configure NAT
              bash -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
              sysctl -p
              iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
              service iptables save
              systemctl enable iptables
              systemctl start iptables

              # Create client configuration directory and files
              mkdir -p /etc/openvpn/client-configs
              bash -c 'cat <<EOF2 > /etc/openvpn/client-configs/client1.ovpn
              client
              dev tun
              proto udp
              remote $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) 1194
              resolv-retry infinite
              nobind
              persist-key
              persist-tun
              ca ca.crt
              cert client1.crt
              key client1.key
              remote-cert-tls server
              tls-auth ta.key 1
              cipher AES-256-CBC
              auth SHA256
              verb 3
              EOF2'

              cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/client-configs/ -f
              cp /etc/openvpn/easy-rsa/pki/issued/client1.crt /etc/openvpn/client-configs/ -f
              cp /etc/openvpn/easy-rsa/pki/private/client1.key /etc/openvpn/client-configs/ -f
              cp /etc/openvpn/ta.key /etc/openvpn/client-configs/ -f
              chmod 644 /etc/openvpn/client-configs/* -f
              chown -R ec2-user:ec2-user /etc/openvpn/client-configs -f
              EOF

  tags = {
    Name = "${var.name_prefix}-openvpn-server"
  }
}

resource "aws_security_group" "openvpn_sg" {
  name        = "${var.name_prefix}-openvpn-sg"
  description = "Security group for OpenVPN server"

  /*   ingress {
    description = "Allow OpenVPN"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } */
}
resource "aws_security_group_rule" "rules_assigment" {
  for_each = local.security_group_rules

  security_group_id = aws_security_group.openvpn_sg.id
  description       = each.key
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
}