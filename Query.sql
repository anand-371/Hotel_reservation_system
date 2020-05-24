CREATE TABLE Customer
(
  SSN INT NOT NULL,
  CustomerID INT NOT NULL,
  email VARCHAR(20) NOT NULL,
  city VARCHAR(20) NOT NULL,
  street VARCHAR(20),
  postalcode INT NOT NULL,
  firstname VARCHAR(10) NOT NULL,
  lastname VARCHAR(10) NOT NULL,
  middlename VARCHAR(10) NOT NULL,
  Age INT NOT NULL,
  primary_contact_number CHAR(12) NOT NULL,
  country VARCHAR(20) NOT NULL,
  PRIMARY KEY (CustomerID),
  UNIQUE (SSN)
);
CREATE TABLE Hotel
(
  HotelID INT NOT NULL,
  street VARCHAR(20),
  postalcode INT NOT NULL,
  city VARCHAR(20) NOT NULL,
  hotelname VARCHAR(20) NOT NULL,
  PRIMARY KEY (HotelID)
);
CREATE TABLE payment_details
(
  reservationID INT NOT NULL,
  payment_method VARCHAR(10) NOT NULL,
  payment_status VARCHAR(10) NOT NULL,
  PRIMARY KEY (reservationID)
);
CREATE TABLE Hotel_Hotel_contact_number
(
  Hotel_contact_number VARCHAR(12) NOT NULL,
  HotelID INT NOT NULL,
  PRIMARY KEY (Hotel_contact_number, HotelID),
  FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID) ON DELETE CASCADE
);

CREATE TABLE Bill
(
  BillID INT NOT NULL,
  Amount INT NOT NULL,
  lastname VARCHAR(10) NOT NULL,
  firstname VARCHAR(10) NOT NULL,
  middlename VARCHAR(10) NOT NULL,
  HotelID INT NOT NULL,
  reservationID INT NOT NULL,
  currentdate date DEFAULT GETDATE() ,
  CustomerID INT NOT NULL,
  PRIMARY KEY (BillID),
  FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID) ON DELETE CASCADE,
  FOREIGN KEY (reservationID) REFERENCES payment_details(reservationID) ON DELETE CASCADE,
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE
);

CREATE TABLE Rooms
(
  RoomID INT NOT NULL,
  room_category VARCHAR(10) NOT NULL,
  number_of_beds INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  current_price INT NOT NULL,
  ReservationID INT NOT NULL,
  roomnumber INT NOT NULL,
  CustomerID INT NOT NULL,
  HotelID INT NOT NULL,
  PRIMARY KEY (RoomID),
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE,
  FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID) ON DELETE CASCADE,
  FOREIGN KEY (reservationID) REFERENCES payment_details(reservationID) ON DELETE CASCADE
);


CREATE TABLE Income_details
(
 BillID INT NOT NULL,
 amount_paid INT  
);

alter table Customer add constraint customer_valid check (
email like '%_@__%.__%' AND
Age>=18 
);


/*alter table Customer DROP CONSTRAINT customer_valid;
alter table Customer DROP CONSTRAINT  customer_valid ;
*/
alter table Rooms add constraint chk_room check (
end_date>=start_date AND
room_category IN ('Single','Double','Triple','Quad','King','Connecting','Suite') AND
number_of_beds<=4
);

alter table Hotel_Hotel_contact_number add constraint chk_hotel_contact check (
Hotel_contact_number like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
);
/*
alter table Hotel_Hotel_contact_number DROP CONSTRAINT chk_hotel_contact;
alter table Hotel add constraint chk_hotel check (
postalcode like '[0-9]*6'
alter table Hotel DROP CONSTRAINT chk_hotel;
);
*/


alter table Bill add constraint chk_bill check(
Amount>0 
);

alter table payment_details add constraint chk_payment_details check(
payment_method IN ('Cash','Card','Netbanking','UPI') AND 
payment_status IN ('Failed','successful')
);

CREATE TRIGGER income_trigger ON Bill
FOR INSERT AS
BEGIN

    INSERT INTO 
    Income_details
    (
        BillID,
        amount_paid
    )
    SELECT 
        BillID,
        Amount
    FROM 
        INSERTED

END


INSERT INTO Customer VALUES (12345,8999,'anand@gmail.com','bangalore','blahblah',560062,'meh','huh','uff',22,'6362134545','India');
INSERT INTO Hotel VALUES (9999,'hehe',560061,'bangalore','abc');
INSERT INTO payment_details VALUES (69696,'Cash','successful');
INSERT INTO  Hotel_Hotel_contact_number VALUES ('8262134545',9999); 
INSERT INTO  Bill(BillID,Amount,lastname,firstname,middlename,HotelID,reservationID,CustomerID) VALUES (1111,32,'meh','huh','pfft',9999,69696,8999);
INSERT INTO Rooms VALUES (1093,'king',2,'2008-11-11','2008-12-11',10,69696,978,8999,9999);

SELECT SUM(amount_paid)
FROM Income_details
WHERE amount_paid>0;

Select r.ReservationID,r.CustomerID,b.BillID
from Rooms as r
JOIN Bill b on r.CustomerID=b.CustomerID

SELECT * from Customer;
SELECT * from Hotel;
SELECT * from payment_details;
SELECT * from Hotel_Hotel_contact_number;
SELECT * from Bill;
SELECT * from Rooms;
SELECT * from Income_details;
/*
DROP TABLE Hotel_Hotel_contact_number;
DROP TABLE Hotel;
DROP TABLE Customer;
DROP TABLE payment_details;
DROP TABLE Rooms;
DROP TABLE Bill;
*/