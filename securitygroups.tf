#
# We have two security groups: 
#   - one for the web application, 
#   - and another for the database. 
# 
# They both need to have the outbound (egress) rule to have internet access because yum will install the Apache and MySQL servers, 
# but the connection to the MySQL port will be allowed only from instances that belong to the webapp security group.
# 
# I have left the ssh port open only for debug reason, but you can also delete that rule.

resource "aws_security_group" "FrontEnd" {
  name = "FrontEnd"

  tags {
    Name = "FrontEnd"
  }

  description = "ONLY HTTP CONNECTION INBOUD"
  vpc_id      = "${aws_vpc.terraformmain.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "Database" {
  name = "Database"

  tags {
    Name = "Database"
  }

  description = "ONLY tcp CONNECTION INBOUND"
  vpc_id      = "${aws_vpc.terraformmain.id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    security_groups = ["${aws_security_group.FrontEnd.id}"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
