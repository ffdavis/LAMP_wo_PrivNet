<?php
$conn = new mysqli('mydatabase.fdavis.internal', 'root', 'secret', 'test');
$sql = 'SELECT * FROM mytable';
$result = $conn->query($sql);
while($row = $result->fetch_assoc()) { echo 'the value is: ' . $row['mycol'] ;}
$conn->close();
?>
