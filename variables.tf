/*
** NOTE:

VPC: 172.28.0.0/16
------------------------------------------------------ route53----
I  AZ Data Center 1                 AZ Data Center 2             I
I  ------------------------         ------------------------     I
I  subnet-1 (priv)                  subnet-2 (priv)              I
I  172.28.0.0/74                    172.28.3.0/24                I
I  -------------                    -------------                I
I  http apache                      MySql                        I
I                                                                I
I  instance                         instance                     I
------------------------------------------------------------------
*/

variable "region" {
  default = "us-east-1"

  # default = "us-west-2"
}

variable "AmiLinux" {
  type = "map"

  default = {
    # us-east-1 = "ami-0de53d8956e8dcf80" # Amazon Linux 2 AMI (HVM), SSD Volume Type - ami-0de53d8956e8dcf80 (64-bit x86) / ami-06b382aba6c5a4f2c (64-bit Arm)
    us-east-1 = "ami-0080e4c5bc078760e" # Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type - ami-0080e4c5bc078760e

    #   us-west-2 = "ami-5ec1673e"
    #   eu-west-1 = "ami-9398d3e0"

    # US East (N. Virginia) - us-east-1
    # US West (Oregon)      - us-west-2
    # EU (Ireland)          - eu-west-1
  }

  description = "I add only 3 regions (Virginia, Oregon, Ireland) to show the map feature but you can add all the r"
}

/*
variable "aws_access_key" {
  default     = "xxx"
  description = "the user aws access key"
}

variable "aws_secret_key" {
  default     = "xxx"
  description = "the user aws secret key"
}
*/

variable "credentialsfile" {
  # default = "/Users/giuseppe/.aws/credentials" #replace your home directory
  default     = "/Users/Fer/.aws/credentials"
  description = "where your access and secret_key are stored, you create the file when you run the aws config"
}

variable "vpc-fullcidr" {
  default     = "172.28.0.0/16"
  description = "the vpc cdir"
}

variable "Subnet-Public-AzA-CIDR" {
  default     = "172.28.0.0/24"
  description = "the cidr of the subnet"
}

variable "Subnet-Private-AzA-CIDR" {
  default     = "172.28.3.0/24"
  description = "the cidr of the subnet"
}

variable "key_name" {
  default     = "myKey"
  description = "the ssh key to use in the EC2 machines"
}

variable "DnsZoneName" {
  default = "fdavis.internal"

  # default     = "linuxacademy.internal"
  description = "the internal dns name"
}
