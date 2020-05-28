CREATE TABLE Customer
( 
  SSN INT NOT NULL,
  CustomerID INT NOT NULL,
  email VARCHAR(20) NOT NULL,
  city VARCHAR(20) NOT NULL,
  street VARCHAR(20),
  postalcode VARCHAR(20),
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
CREATE TABLE Hotel_Hotel_contact_number
( 
  Hotel_contact_number VARCHAR(12) NOT NULL,
  HotelID INT NOT NULL,
  PRIMARY KEY (Hotel_contact_number, HotelID),
  FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID) ON DELETE CASCADE
);
CREATE TABLE Rooms
( index_1 INT NOT NULL,
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
( index_1 INT NOT NULL,
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


CREATE TRIGGER income_trigger ON Bill
FOR INSERT AS
BEGIN

	DECLARE @temp INT
	SELECT 
		@temp=COALESCE(max(Bill.index_1),0)
	from Bill;
		INSERT INTO 
		AUDIT_DETAILS
		(
			BillID,
			total_amount_paid,
		start_date,
		end_date
		)
		SELECT Bill.BillID, Bill.Amount, Rooms.start_date, Rooms.end_date
		FROM Bill
		INNER JOIN Rooms ON Bill.CustomerID=Rooms.CustomerID WHERE Bill.index_1=COALESCE(@temp,0);

	

	DECLARE @sd date;
	DECLARE @ed date;
		SELECT @sd=Rooms.start_date,
			   @ed=Rooms.end_date
		FROM Rooms ;

		UPDATE AUDIT_DETAILS
			SET number_of_days=DATEDIFF(DAY,@sd,@ed)
	   
	

END

INSERT INTO Customer VALUES (12345,8999,'anand@gmail.com','bangalore','street2','560072','Anand','V','hegde',20,'6362134545','India');
INSERT INTO Hotel VALUES (9999,'street2','560061','bangalore','ITC');
INSERT INTO payment_details VALUES (69696,'Cash','successful');
INSERT INTO  Hotel_Hotel_contact_number VALUES ('8262134545',9999);
INSERT INTO Rooms VALUES (1,1093,'King',2,'2008-11-11','2008-11-15',5000,69696,110,8999,9999);
INSERT INTO  Bill(index_1,BillID,Amount,firstname,middlename,lastname,HotelID,reservationID,CustomerID) VALUES (1,1111,5000,'Anand','V','hegde',9999,69696,8999);

INSERT INTO Customer VALUES (12344,8998,'abcd@gmail.com','bangalore','street3',560061,'John','G','K',22,'9740299869','India');
INSERT INTO Hotel VALUES (9998,'street1','560060','bangalore','Leela');
INSERT INTO payment_details VALUES (69695,'Cash','successful');
INSERT INTO  Hotel_Hotel_contact_number VALUES ('8262134542',9998);
INSERT INTO Rooms VALUES (2,1092,'king',1,'2009-12-11','2009-12-14',6500,69695,102,8998,9998);
INSERT INTO  Bill(index_1,BillID,Amount,firstname,middlename,lastname,HotelID,reservationID,CustomerID) VALUES (2,1110,6500,'John','G','K',9998,69695,8998);

INSERT INTO Customer VALUES (12343,8997,'bcde@gmail.com','bangalore','street3',560061,'Jack','K','M',30,'9748299869','India');
INSERT INTO Hotel VALUES (9997,'street1','550043','chennai','Leela');
INSERT INTO payment_details VALUES (69694,'Cash','successful');
INSERT INTO  Hotel_Hotel_contact_number VALUES ('8262004542',9997);
INSERT INTO Rooms VALUES (3,1091,'king',2,'2010-09-01','2010-09-05',7500,69695,102,8997,9997);
INSERT INTO  Bill(index_1,BillID,Amount,firstname,middlename,lastname,HotelID,reservationID,CustomerID) VALUES (3,1109,7500,'Jack','K','M',9997,69694,8997);

INSERT INTO Customer VALUES (12342,8996,'bcdfe@gmail.com','bangalore','street2',560161,'Max','L','K',25,'9782299869','India');
INSERT INTO Hotel VALUES (9996,'street4','560001','bangalore','ITC');
INSERT INTO payment_details VALUES (69693,'Card','successful');
INSERT INTO  Hotel_Hotel_contact_number VALUES ('8262134545',9996);
INSERT INTO Rooms VALUES (4,1094,'King',1,'2008-10-24','2008-10-26',8000,69693,110,8996,9996);
INSERT INTO Bill(index_1,BillID,Amount,firstname,middlename,lastname,HotelID,reservationID,CustomerID) VALUES (4,1108,8000,'Max','L','K',9996,69693,8996);


INSERT INTO Customer VALUES (12341,8995,'sjufe@gmail.com','bangalore','street1',563461,'Alex','K','T',60,'9088299869','India');
INSERT INTO Hotel VALUES (9995,'street3','563001','bangalore','Leela');
INSERT INTO payment_details VALUES (69692,'Card','successful');
INSERT INTO  Hotel_Hotel_contact_number VALUES ('8362134545',9995);
INSERT INTO Rooms VALUES (5,1095,'King',3,'2008-10-25','2008-10-29',12000,69692,201,8995,9995);
INSERT INTO Bill(index_1,BillID,Amount,firstname,middlename,lastname,HotelID,reservationID,CustomerID) VALUES (5,1107,12000,'Alex','K','T',9995,69692,8995);
