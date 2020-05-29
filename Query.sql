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


CREATE TRIGGER income_trigger ON Bill
FOR INSERT AS
BEGIN

	DECLARE @temp INT;
	DECLARE @bill_temp INT;
	DECLARE @id INT;
	SELECT 
		@temp=COALESCE(max(Bill.index_1),0)
	from Bill;
	SELECT 
		@id=inserted.CustomerID,
		@bill_temp=inserted.BillID
	from inserted;
		
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
	DECLARE @current_price INT;
	DECLARE @fname VARCHAR(10);
	DECLARE @mname VARCHAR(10);
	DECLARE @lname VARCHAR(10);
		SELECT @fname=Customer.firstname,
			   @mname=Customer.middlename,
			   @lname=Customer.lastname
		from Customer WHERE Customer.CustomerID=@id;

		SELECT @sd=Rooms.start_date,
			   @ed=Rooms.end_date,
			   @current_price=Rooms.current_price
		FROM Rooms WHERE Rooms.CustomerID=@id;

		UPDATE Bill
			SET Amount=DATEDIFF(DAY,@sd,@ed)*@current_price, firstname = @fname,lastname= @lname,middlename= @mname
			WHERE Bill.CustomerID=@id
		UPDATE AUDIT_DETAILS
			SET number_of_days=DATEDIFF(DAY,@sd,@ed),total_amount_paid=DATEDIFF(DAY,@sd,@ed)*@current_price
			WHERE AUDIT_DETAILS.BillID=@bill_temp

	   

END

INSERT INTO Customer VALUES (8999,'Anand','V','hegde','anand@gmail.com','bangalore','street2','560072',20,'India');
INSERT INTO Customer_contact_number VALUES('6362142068',8999);
INSERT INTO Hotel VALUES (9999,'street2','560061','bangalore','ITC');
INSERT INTO payment_details VALUES (69696,'Cash','successful');
INSERT INTO Hotel_contact_number VALUES ('8262134545',9999);
INSERT INTO Rooms VALUES (1,1093,'King',2,'2008-11-11','2008-11-15',5000,69696,110,8999,9999);
INSERT INTO  Bill(index_1,BillID,HotelID,reservationID,CustomerID) VALUES (1,1111,9999,69696,8999);


INSERT INTO Customer VALUES (8998,'John','G','K','abcd@gmail.com','bangalore','street3','560061',22,'India');
INSERT INTO Customer_contact_number VALUES('9740299869',8998);
INSERT INTO Hotel VALUES (9998,'street1','560060','bangalore','Leela');
INSERT INTO payment_details VALUES (69695,'Cash','successful');
INSERT INTO  Hotel_contact_number VALUES ('8262134542',9998);
INSERT INTO Rooms VALUES (2,1092,'king',1,'2009-12-11','2009-12-14',6500,69695,102,8998,9998);
INSERT INTO  Bill(index_1,BillID,Amount,HotelID,reservationID,CustomerID) VALUES (2,1110,6500,9998,69695,8998);
