/*
THE WEBAPP MACHINE
It is placed in the public subnet so it is possible to reach it from your browser using port 80. 
The userdata performs the following actions:

  * update the OS
  * install the Apache web server and its php module
  * start the Apache
  * using the echo command place in the public directory, a php file that reads the value inside 
    the database created in the other EC2
*/
resource "aws_instance" "phpapp" {
  ami           = "${lookup(var.AmiLinux, var.region)}"
  instance_type = "t2.micro"

  associate_public_ip_address = "true"
  subnet_id                   = "${aws_subnet.PublicAZA.id}"
  vpc_security_group_ids      = ["${aws_security_group.FrontEnd.id}"]

  key_name = "${var.key_name}"

  tags {
    Name = "phpapp"
  }

  user_data = <<-HEREDOC
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd24 
    sudo yum install -y php73
    sudo yum install -y php73-mysqlnd
    sudo service httpd start
    sudo chkconfig httpd on
    echo "<?php" >> /var/www/html/calldb.php
    echo "\$conn = new mysqli('mydatabase.linuxacademy.internal', 'root', 'secret', 'test');" >> /var/www/html/calldb.php
    echo "\$sql = 'SELECT * FROM mytable'; " >> /var/www/html/calldb.php
    echo "\$result = \$conn->query(\$sql); " >> /var/www/html/calldb.php
    echo "while(\$row = \$result->fetch_assoc()) { echo 'the value is: ' . \$row['mycol'] ;} " >> /var/www/html/calldb.php
    echo "\$conn->close(); " >> /var/www/html/calldb.php
    echo "?>" >> /var/www/html/calldb.php
    HEREDOC
}

/*
THE DATABASE MACHINE
This machine is placed in the private subnet and has its security group. 
The userdata performs the following actions:

  * update the OS
  * install the MySQL server and run it
  * configure the root user to grant access from other machines
  * create a table in the test database and add one line inside
*/
resource "aws_instance" "database" {
  ami           = "${lookup(var.AmiLinux, var.region)}"
  instance_type = "t2.micro"

  # associate_public_ip_address = "false"
  associate_public_ip_address = "true"
  subnet_id                   = "${aws_subnet.PrivateAZA.id}"
  vpc_security_group_ids      = ["${aws_security_group.Database.id}"]

  key_name = "${var.key_name}"

  tags {
    Name = "database"
  }

  user_data = <<-HEREDOC
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y mysql57-server
    sudo service mysqld start
    /usr/bin/mysqladmin -u root password 'secret'
    mysql -u root -psecret -e "create user 'root'@'%' identified by 'secret';" mysql
    mysql -u root -psecret -e 'CREATE TABLE mytable (mycol varchar(255));' test
    mysql -u root -psecret -e "INSERT INTO mytable (mycol) values ('Hey Fer!...linuxacademythebest') ;" test
    HEREDOC
}

# QUERY:
# mysql -u root -psecret -e "SHOW tables" mysql


/* 
 AFTER RUNNING TERRAFORM:

 ... and after a few minutes, the process should be completed and you can go to your AWS web console 
 and read the public ip of your EC2 machine. 
 Visit the url in your browser, and you will see the result of the php command.

   http://54.186.85.117/calldb.php
   the value is: Hey Fer!...linuxacademythebest

TESTING THE ZONE

 To test your internal DNS routing system, you can log in inside the web server machine to run 
 a DNS query for the private zone like this:

     $ host mydatabase.linuxacademy.internal
     mydatabase.linuxacademy.internal has address 172.28.3.142
 
 If you try to do it from a machine outside the vpc, you will have:

     host mydatabase.fdavis.internal.
     Host mydatabase.fdavis.internal. not found: 3(NXDOMAIN)

*/


/*
LATEST VERSIONS

sudo yum update -y
yum list httpd

sudo yum install -y httpd24
sudo yum install -y php73
sudo yum install -y php73-mysqlnd

sudo yum install -y mysql57-server

service httpd24 status

*/

