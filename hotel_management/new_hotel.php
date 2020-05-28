<html>
<body style=" background-image: url(userlogin.png);
    height: 100%; 
    background-position: center;
    background-repeat: no-repeat;
    background-size: cover;" >

<?php 

require "db.php";

$hotelID=$_POST["hotelID"];
$hotelname=$_POST["hotelname"];
$street=$_POST["street"];
$city=$_POST["city"];
$postalcode=$_POST["postalcode"];
$contactnumber=$_POST["contactnumber"];

$sql = "INSERT INTO Hotel (HotelID,street,postalcode,city,hotelname) VALUES ('".$hotelID."','".$street."','".$postalcode."','".$city."','".$hotelname."')";

// echo $sql;

if ($conn->query($sql) === TRUE) 
{
 echo ", <a href=\"http://localhost/hotel_management/index.html\"> Click here </a> to browse through our website!!! " ;
} 
else 
{
 echo "Error:" . $conn->error. "<br> <a href=\"http://localhost/railway/new_user_form.htm\">Go Back to Login!!!</a> ";
}

$conn->close(); 
?>

</body>
</html>
