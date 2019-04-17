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
    echo "\$conn = new mysqli('mydatabase.fdavis.internal', 'root', 'secret', 'test');" >> /var/www/html/calldb.php
    echo "\$sql = 'SELECT * FROM mytable'; " >> /var/www/html/calldb.php
    echo "\$result = \$conn->query(\$sql); " >> /var/www/html/calldb.php
    echo "while(\$row = \$result->fetch_assoc()) { echo 'the value is: ' . \$row['mycol'] ;} " >> /var/www/html/calldb.php
    echo "\$conn->close(); " >> /var/www/html/calldb.php
    echo "?>" >> /var/www/html/calldb.php
    HEREDOC

  provisioner "file" {
    source      = "calldbdos.php"
    destination = "~/calldbdos.php"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("myKey.pem")}"
      timeout     = "10m"
      agent       = "false"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /var/www/html",
      "sudo cp ~/calldbdos.php /var/www/html/calldbdos.php",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("myKey.pem")}"
      timeout     = "10m"
      agent       = "false"
    }
  }
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

  # subnet_id                = "${aws_subnet.PrivateAZA.id}"
  subnet_id              = "${aws_subnet.PublicAZA.id}"
  vpc_security_group_ids = ["${aws_security_group.Database.id}"]

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
    mysql -u root -psecret -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';" mysql
    mysql -u root -psecret -e 'CREATE DATABASE test;'
    mysql -u root -psecret -e 'CREATE TABLE mytable (mycol varchar(255));' test
    mysql -u root -psecret -e "INSERT INTO mytable (mycol) values ('Hey Fer... Linux Academy is the Best') ;" test
    HEREDOC
}

# QUERY:
# mysql -u root -psecret -e "SHOW tables" mysql


/* 
 AFTER RUNNING TERRAFORM:
-------------------------
 ... and after a few minutes, the process should be completed and you can go to your AWS console
 and get the public ip address of the phpapp EC2 server/machine. 

 Visit the url in your browser, and you will see the result of the php command.

   http://pub-ip-add-phpapp-EC2-server/calldb.php
     
     the value is: Hey Fer...Linux Academy is the Best

   http://pub-ip-add-phpapp-EC2-server/calldbdos.php

      This is the output from MySQL DB "test"


TESTING THE ZONE
----------------
 To test your internal DNS routing system, you can log in inside the web server machine to run 
 a DNS query for the private zone like this:

     $ host mydatabase.fdavis.internal
     mydatabase.fdavis.internal has address 172.xx.x.xxx
 
 If you try to do it from a machine outside the vpc, you will have:

     host mydatabase.fdavis.internal.
     Host mydatabase.fdavis.internal. not found: 3(NXDOMAIN)

*/
/*
MANUAL SQL COMMANDS TO TROUBLESHOOT THE PHP/MySQL issue connecion:
-------------------------------------------------------------------
mysql -u root -psecret mysql
mysql> SELECT User FROM mysql.user;
mysql> SELECT * FROM mysql.user;
mysql> desc mysql.user;

mysql -u root -psecret mysql
mysql> show databases;
mysql> use test;
mysql> show tables;

mysql -u root -psecret test
INSERT INTO mytable (mycol) values ('Hey Fer... Linux Academy the best');

mysql -u root -psecret test
select * from mytable;

mysql -u USERNAME -pPASSWORD -h HOSTNAMEORIP DATABASENAME 
mysql -u root -psecret -h mydatabase.fdavis.internal test
select * from mytable;

mysql> show grants for 'root';
+----------------------------------+
| Grants for root@%                |
+----------------------------------+
| GRANT USAGE ON *.* TO 'root'@'%' |
+----------------------------------+

mysql> show grants for 'root'@'localhost';
+---------------------------------------------------------------------+
| Grants for root@localhost                                           |
+---------------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION |
| GRANT PROXY ON ''@'' TO 'root'@'localhost' WITH GRANT OPTION        |
+---------------------------------------------------------------------+

mysql> GRANT ALL PRIVILEGES ON database_name.* TO 'username'@'localhost';

mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';

mysql -u root -psecret -h mydatabase.fdavis.internal test
SELECT * FROM mytable;

mysql -u root -psecret -e "create user 'root'@'%' identified by 'secret';" mysql
mysql -u root -psecret -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';" mysql

*/