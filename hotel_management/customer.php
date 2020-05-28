<html>
<body style=" background-image: url(userlogin.png);
    height: 100%; 
    background-position: center;
    background-repeat: no-repeat;
    background-size: cover;" >

<?php 

require "db.php";

$SSN=$_POST["SSN"];
$custID=$_POST["custID"];
$fname=$_POST["fname"];
$mname=$_POST["mname"];
$lname=$_POST["lname"];
$email=$_POST["email"];
$city=$_POST["city"];
$street=$_POST["street"];
$postalcode=$_POST["postalcode"];
$age=$_POST["age"];
$contactnumber=$_POST["contactnumber"];
$country=$_POST["country"];
$sql = "INSERT INTO Customer (SSN,CustomerID,email,city,street,postalcode,firstname,lastname,middlename,Age,primary_contact_number,country) VALUES ('".$SSN."','".$custID."','".$email."','".$city."','".$street."','".$postalcode."','".$fname."','".$lname."','".$mname."','".$age."','".$contactnumber."','".$country."')";

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
