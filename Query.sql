CREATE TABLE Customer
( 
  CustomerID INT NOT NULL,
  firstname VARCHAR(10) NOT NULL,
  middlename VARCHAR(10) NOT NULL,
  lastname VARCHAR(10) NOT NULL,
  email VARCHAR(20) NOT NULL,
  city VARCHAR(20) NOT NULL,
  street VARCHAR(20),
  postalcode VARCHAR(20),
  Age INT NOT NULL,
  country VARCHAR(20) NOT NULL,
  PRIMARY KEY (CustomerID),
);

CREATE TABLE Customer_contact_number
( 
  contact_number VARCHAR(12) NOT NULL,
  CustomerID INT NOT NULL,
  PRIMARY KEY (contact_number,CustomerID),
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE
);
CREATE TABLE Hotel
( 
  HotelID INT NOT NULL,
  street VARCHAR(20),
  postalcode VARCHAR(20),
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
CREATE TABLE Hotel_contact_number
( 
  contact_number VARCHAR(12) NOT NULL,
  HotelID INT NOT NULL,
  PRIMARY KEY (contact_number, HotelID),
  FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID) ON DELETE CASCADE
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
CREATE TABLE Bill
( 
  BillID INT NOT NULL,
  Amount INT,
  lastname VARCHAR(10) ,
  firstname VARCHAR(10),
  middlename VARCHAR(10),
  HotelID INT NOT NULL,
  reservationID INT NOT NULL,
  currentdate date DEFAULT GETDATE() ,
  CustomerID INT NOT NULL,
  PRIMARY KEY (BillID),
  FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID) ON DELETE CASCADE,
  FOREIGN KEY (reservationID) REFERENCES payment_details(reservationID) ON DELETE CASCADE,
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE
);

CREATE TABLE AUDIT_DETAILS
( 
 BillID INT,
 start_date date,
 end_date date,
 number_of_days INT,
 total_amount_paid INT
);

alter table Customer add constraint customer_valid check (
email like '%_@__%.__%' AND
Age>=18  AND
postalcode like '[0-9][0-9][0-9][0-9][0-9][0-9]'
);

alter table  Customer_contact_number add constraint cus_ph_chk check(
contact_number like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
);

/*alter table Customer DROP CONSTRAINT customer_valid;
alter table Customer DROP CONSTRAINT  customer_valid ;
*/
alter table Rooms add constraint chk_room check (
end_date>=start_date AND
room_category IN ('Single','Double','Triple','Quad','King','Connecting','Suite') AND
number_of_beds<=4
);

alter table Hotel_contact_number add constraint chk_hotel_contact check (
contact_number like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
);

alter table Hotel add constraint chk_hotel check (
postalcode like '[0-9][0-9][0-9][0-9][0-9][0-9]'
);

alter table Bill add constraint chk_bill check(
Amount>0 
);

alter table payment_details add constraint chk_payment_details check(
payment_method IN ('Cash','Card','Netbanking','UPI') AND 
payment_status IN ('Failed','successful')
);


CREATE TRIGGER income_trigger ON Bill AFTER INSERT AS
BEGIN
	DECLARE @bill_temp INT;
	DECLARE @id INT;
	SELECT 
		@id=inserted.CustomerID,
		@bill_temp=inserted.BillID
	from inserted;
	DECLARE @sd date;
	DECLARE @ed date;
	DECLARE @current_price INT;
	DECLARE @fname VARCHAR(10);
	DECLARE @mname VARCHAR(10);
	DECLARE @lname VARCHAR(10);
	DECLARE @temp_amount INT;
		SELECT @fname=Customer.firstname,
			   @mname=Customer.middlename,
			   @lname=Customer.lastname
		from Customer WHERE Customer.CustomerID=@id;

		SELECT @sd=Rooms.start_date,
			   @ed=Rooms.end_date,
			   @current_price=Rooms.current_price,
			   @temp_amount=DATEDIFF(DAY,@sd,@ed)*@current_price
		FROM Rooms WHERE Rooms.CustomerID=@id;
		UPDATE Bill
			SET Amount=DATEDIFF(DAY,@sd,@ed)*@current_price, firstname = @fname,lastname= @lname,middlename= @mname
			WHERE Bill.CustomerID=@id

		INSERT INTO AUDIT_DETAILS(BillID,total_amount_paid,start_date,end_date)VALUES (@bill_temp,@temp_amount,@sd,@ed)

		UPDATE AUDIT_DETAILS
			SET number_of_days=DATEDIFF(DAY,@sd,@ed),total_amount_paid=DATEDIFF(DAY,@sd,@ed)*@current_price
			WHERE AUDIT_DETAILS.BillID=@bill_temp

	   

END

INSERT INTO Customer VALUES (8999,'Anand','V','hegde','anand@gmail.com','bangalore','street2','560072',20,'India');
INSERT INTO Customer_contact_number VALUES('6362142068',8999);
INSERT INTO Hotel VALUES (9999,'street2','560061','bangalore','ITC');
INSERT INTO payment_details VALUES (69696,'Cash','successful');
INSERT INTO Hotel_contact_number VALUES ('8262134545',9999);
INSERT INTO Rooms VALUES (1093,'King',2,'2008-11-11','2008-11-15',5000,69696,110,8999,9999);
INSERT INTO  Bill(BillID,HotelID,reservationID,CustomerID) VALUES (1111,9999,69696,8999);


INSERT INTO Customer VALUES (8998,'John','G','K','abcd@gmail.com','bangalore','street3','560061',22,'India');
INSERT INTO Customer_contact_number VALUES('9740299869',8998);
INSERT INTO Hotel VALUES (9998,'street1','560060','bangalore','Leela');
INSERT INTO payment_details VALUES (69695,'Cash','successful');
INSERT INTO  Hotel_contact_number VALUES ('8262134542',9998);
INSERT INTO Rooms VALUES (1092,'king',1,'2009-12-11','2009-12-14',6500,69695,102,8998,9998);
INSERT INTO  Bill(BillID,Amount,HotelID,reservationID,CustomerID) VALUES (1110,6500,9998,69695,8998);

INSERT INTO Customer VALUES (8997,'mack','K','M','bcde@gmail.com','bangalore','street3','560061',30,'India');
INSERT INTO Customer_contact_number VALUES('9748299869',8997);
INSERT INTO Hotel VALUES (9997,'street1','550043','chennai','Leela');
INSERT INTO payment_details VALUES (69694,'Cash','successful');
INSERT INTO  Hotel_contact_number VALUES ('8262004542',9997);
INSERT INTO Rooms VALUES (1091,'king',2,'2010-09-01','2010-09-05',7500,69695,102,8997,9997);
INSERT INTO  Bill(BillID,Amount,HotelID,reservationID,CustomerID) VALUES (1109,7500,9997,69694,8997);

INSERT INTO Customer VALUES (8996,'Max','L','K','bcdfe@gmail.com','bangalore','street2','560161',25,'India');
INSERT INTO Customer_contact_number VALUES('9782299869',8997);
INSERT INTO Hotel VALUES (9996,'street4','560001','bangalore','ITC');
INSERT INTO payment_details VALUES (69693,'Card','successful');
INSERT INTO  Hotel_contact_number VALUES ('8262134545',9996);
INSERT INTO Rooms VALUES (1094,'King',1,'2008-10-24','2008-10-26',8000,69693,110,8996,9996);
INSERT INTO Bill(BillID,Amount,HotelID,reservationID,CustomerID) VALUES (1108,8000,9996,69693,8996);


INSERT INTO Customer VALUES (8995,'Alex','K','T','sjufe@gmail.com','bangalore','street1','563461',60,'India');
INSERT INTO Customer_contact_number VALUES('9088299869',8995);
INSERT INTO Hotel VALUES (9995,'street3','563001','bangalore','Leela');
INSERT INTO payment_details VALUES (69692,'Card','successful');
INSERT INTO  Hotel_contact_number VALUES ('8362134545',9995);
INSERT INTO Rooms VALUES (1095,'King',3,'2008-10-25','2008-10-29',12000,69692,201,8995,9995);
INSERT INTO Bill(BillID,Amount,HotelID,reservationID,CustomerID) VALUES (1107,12000,9995,69692,8995);
