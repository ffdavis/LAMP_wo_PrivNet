/* In this file, 4 things were accomplished: 

   - the dhcp was created,
   - the private Route53 DNS zone was created, 
   - the association with the VPC was made, 
   - and the DNS record for the database was created. 

 Terraform perform the actions in the right order, the last component in this file will be the database dns record 
 because it depends on the private ip of the EC2 database machine. 
 This machine will be allocated during the database creation.
*/
resource "aws_vpc_dhcp_options" "mydhcp" {
  domain_name         = "${var.DnsZoneName}"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "My internal name"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.terraformmain.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.mydhcp.id}"
}

# DNS PART ZONE AND RECORDS
resource "aws_route53_zone" "main" {
  name = "${var.DnsZoneName}"

  vpc {
    vpc_id = "${aws_vpc.terraformmain.id}"
  }

  comment = "Managed by terraform"
}

resource "aws_route53_record" "database" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "mydatabase.${var.DnsZoneName}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.database.private_ip}"]
}
