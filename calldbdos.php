<html>
   <head>
      <title>PHP with MySQL</title>
   </head>
   
   <body>

    <h1>This is the output from MySQL DB "test"</h1>

   <?php
   $servername = "mydatabase.fdavis.internal";
   $username = "root";
   $password = "secret";
   $dbname = "test";

   // Create connection
   $conn = new mysqli($servername, $username, $password, $dbname);

   // Check connection
   if ($conn->connect_error) {
       die("Connection failed: " . $conn->connect_error);
   } 

   $sql = "SELECT * FROM mytable";
   $result = $conn->query($sql);

   if ($result->num_rows > 0) {

       // output data of each row
       // while($row = $result->fetch_assoc()) {
       //   echo "<br> id: ". $row["id"]. " - Name: ". $row["firstname"]. " " . $row["lastname"] . "<br>";
       // }

       while($row = $result->fetch_assoc()) { 
           echo 'the value is: ' . $row['mycol'] ;
       }

   } else {
       echo "0 results";
   }

   $conn->close();
   ?> 

   </body>

</html>