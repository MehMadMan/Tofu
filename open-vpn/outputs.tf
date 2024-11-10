output "vpn_server_public_ip" {
  description = "The public IP address of the OpenVPN server"
  value       = aws_instance.openvpn_server.public_ip
}

output "client_config_files" {
  description = "Path to client configuration files on the VPN server"
  value       = "/etc/openvpn/client-configs/"
}
output "scp_file_copy" {
  description = "copy files from openvpn server to connect to vpn"
  value       = "scp -i /c/Users/Yameen/Downloads/openvpn.pem ec2-user@${aws_instance.openvpn_server.public_ip}:/etc/openvpn/client-configs/* ./client-configs/"
}
output "ssh_login" {
  description = "ssh and check if 5 files are available in client config"
  value       = "ssh -i /c/Users/Yameen/Downloads/openvpn.pem ec2-user@${aws_instance.openvpn_server.public_ip}"
}