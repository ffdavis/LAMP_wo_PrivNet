/* When you start from scratch, you need to attach an INTERNET GATEWAY to your VPC and define a network ACL. 
 There aren’t restriction at network ACL level because the restriction rules will be enforced by security group.

 Declare the data source
 One thing worth noting is that the data called aws_availability_zones provide the correct name of the availability zones in the chosen region. 
 This way we don’t need to add letters to the region variable and we can avoid mistakes. 
 For example, the North Virginia region where region b does not exist, and in other regions where there are 2 or 4 AZs .
*/
data "aws_availability_zones" "available" {}

# EXTERNAL NETWORK , IG, ROUTE TABLE
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.terraformmain.id}"

  tags {
    Name = "internet gw terraform generated"
  }
}

resource "aws_network_acl" "all" {
  vpc_id = "${aws_vpc.terraformmain.id}"

  egress {
    protocol   = "-1"
    rule_no    = 2
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 1
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "open acl"
  }
}

# There are two routing tables: one for PUBLIC access, and the other one for PRIVATE access

# PUBLIC access
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.terraformmain.id}"

  tags {
    Name = "Public"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

# PRIVATE access
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.terraformmain.id}"

  tags {
    Name = "Private"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.PublicAZA.id}"
  }
}

# In our case, we also need to have access to the internet from the database machine since we use it to install MySQL Server. 
# We will use the AWS NAT GATEWAY in order to increase our security and be sure that there aren’t incoming connections coming 
# from outside the database. 
# As you can see, defining a NAT gateway is pretty easy since it consists of only four lines of code. 
# It is important, though, to deploy it in a public subnet and associate an elastic ip to it. 
# The depends_on allows us to avoid errors and create the NAT gateway only after the internet gateway is in the available state.

# ELASTIC IP 
resource "aws_eip" "forNat" {
  vpc = true
}

# NAT GATEWAY
resource "aws_nat_gateway" "PublicAZA" {
  allocation_id = "${aws_eip.forNat.id}"
  subnet_id     = "${aws_subnet.PublicAZA.id}"
  depends_on    = ["aws_internet_gateway.gw"]
}
