output "vpn_server_public_ip" {
  description = "The public IP address of the OpenVPN server"
  value       = aws_instance.openvpn_server.public_ip
}

output "client_config_files" {
  description = "Path to client configuration files on the VPN server"
  value       = "/etc/openvpn/client-configs/"
}
