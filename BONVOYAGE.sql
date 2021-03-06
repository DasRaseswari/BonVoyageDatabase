USE [master]
GO
IF EXISTS ( SELECT name 
			FROM sys.databases 
			WHERE name='BonVoyage')
	DROP DATABASE [BonVoyage]
GO
CREATE DATABASE [BonVoyage]
GO

USE [BonVoyage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Address](
	[AddressID] [int] IDENTITY(1,1) NOT NULL,
	[AddressType] [varchar](20) NOT NULL,
	[AddressLine1] [varchar](20) NOT NULL,
	[AddressLine2] [varchar](20) NULL,
	[CityID] [int] NOT NULL,
	[Zipcode] [int] NOT NULL,
 CONSTRAINT [PK_Address___] PRIMARY KEY CLUSTERED 
(
	[AddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Bookings](
	[BookingID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[BookingDate] [datetime] NOT NULL,
	[NoOfGuests] [int] NOT NULL,
	[OrganizerID] [int] NULL,
	[BookingTypeID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[TotalPrice] [money] NOT NULL,
	[TimeStamp] [datetime] NOT NULL,
	[ResturantID] [int] NULL,
 CONSTRAINT [PK_Bookings] PRIMARY KEY CLUSTERED 
(
	[BookingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[BookingType](
	[BookingTypeID] [int] IDENTITY(1,1) NOT NULL,
	[BookingTypeName] [varchar](20) NOT NULL,
 CONSTRAINT [PK_BookingType] PRIMARY KEY CLUSTERED 
(
	[BookingTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Cities](
	[CityID] [int] IDENTITY(1,1) NOT NULL,
	[CityName] [varchar](20) NOT NULL,
	[State] [varchar](20) NOT NULL,
	[CountryName] [varchar](20) NOT NULL,
 CONSTRAINT [PK_Cities] PRIMARY KEY CLUSTERED 
(
	[CityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[CustomerAddresses](
	[CustomerID] [int] NOT NULL,
	[AddressID] [int] NOT NULL,
 CONSTRAINT [PK_CustomerAddresses] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC,
	[AddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerFirstName] [varchar](20) NOT NULL,
	[CustomerLastName] [varchar](20) NOT NULL,
	[DOB] [datetime] NOT NULL,
	[Gender] [varchar](20) NOT NULL,
	[PhoneNumber] [varbinary](200) NOT NULL,
	[MemberSince] [datetime] NOT NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

/****************COMPUTED COLUMN AGE***********/
ALTER TABLE [dbo].[Customers]
 ADD [Age] AS DATEDIFF(hour,DOB,GETDATE())/8766

/****************COMPUTED COLUMN MEMBER TIME***********/
 ALTER TABLE [dbo].[Customers]
 ADD [MemberTimeInYears] AS DATEDIFF(hour,MemberSince,GETDATE())/8766

GO

/**************encrypt column*********************/
CREATE TRIGGER tr_EncryptCustPhoneNo
ON [dbo].[Customers]
AFTER INSERT AS
BEGIN
	 -- Create DMK
	 CREATE MASTER KEY
	 ENCRYPTION BY PASSWORD = 'Test_P@sswOrd';

	 -- Create certificate to protect symmetric key
	 CREATE CERTIFICATE TestCertificate
	 WITH SUBJECT = 'BonVoyage Test Certificate',
	 EXPIRY_DATE = '2026-12-31';

	 -- Create symmetric key to encrypt data
	 CREATE SYMMETRIC KEY TestSymmetricKey
	 WITH ALGORITHM = AES_128
	 ENCRYPTION BY CERTIFICATE TestCertificate;

	 -- Open symmetric key
	 OPEN SYMMETRIC KEY TestSymmetricKey DECRYPTION BY CERTIFICATE TestCertificate;

	 -- Insert 
	 UPDATE [dbo].[Customers] SET [PhoneNumber]=(EncryptByKey(Key_GUID(N'TestSymmetricKey'), (SELECT [PhoneNumber] FROM inserted)))
	 WHERE CustomerID=(SELECT CustomerID FROM inserted);

	 -- Update the temp table with decrypted names
	 --UPDATE [dbo].[Customers]
	 --SET  [PhoneNumber] = DecryptByKey( [PhoneNumber]);

	 -- Close the symmetric key
	CLOSE SYMMETRIC KEY TestSymmetricKey;

	-- Drop the symmetric key
	DROP SYMMETRIC KEY TestSymmetricKey;

	-- Drop the certificate
	DROP CERTIFICATE TestCertificate;

	--Drop the DMK
	DROP MASTER KEY;
END
GO

CREATE TABLE [dbo].[EventOrganizer](
	[OrganizerID] [int] IDENTITY(1,1) NOT NULL,
	[OrganizerAddressID] [int] NOT NULL,
	[OrganizerName] [varchar](20) NOT NULL,
	[PhoneNo] [varchar](20) NOT NULL,
	[Description] [varchar](20) NULL,
	[Website] [varchar](20) NULL,
 CONSTRAINT [PK_EventOrganizer] PRIMARY KEY CLUSTERED 
(
	[OrganizerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Events](
	[EventID] [int] IDENTITY(1,1) NOT NULL,
	[OrganizerID] [int] NOT NULL,
	[EventAddressID] [int] NOT NULL,
	[EventName] [varchar](20) NOT NULL,
	[PricePerGuest] [money] NOT NULL,
	[Description] [varchar](20) NOT NULL,
	[Website] [varchar](20) NULL,
 CONSTRAINT [PK_Events] PRIMARY KEY CLUSTERED 
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[EventSchedule](
	[EventID] [int] NOT NULL,
	[OrganizerID] [int] NOT NULL,
 CONSTRAINT [PK_EventSchedule] PRIMARY KEY CLUSTERED 
(
	[EventID] ASC,
	[OrganizerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Hotels](
	[HotelID] [int] IDENTITY(1,1) NOT NULL,
	[CityID] [int] NOT NULL,
	[HotelAddressID] [int] NOT NULL,
	[HotelName] [varchar](20) NOT NULL,
	[PhoneNumber] [varchar](20) NOT NULL,
	[Description] [varchar](10) NULL,
 CONSTRAINT [PK_Hotels] PRIMARY KEY CLUSTERED 
(
	[HotelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[PaymentDate] [datetime] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[TotalPrice] [money] NOT NULL,
	[BookingID] [int] NOT NULL,
	[PaymentMethodID] [int] NOT NULL,
	[BillingAddressID] [int] NOT NULL,
	[Timestamp] [datetime] NOT NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[PaymentMethod](
	[PaymentMethodID] [int] IDENTITY(1,1) NOT NULL,
	[PaymentType] [varchar](20) NOT NULL,
 CONSTRAINT [PK_PaymentMethod] PRIMARY KEY CLUSTERED 
(
	[PaymentMethodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Restaurants](
	[RestaurantID] [int] IDENTITY(1,1) NOT NULL,
	[RestaurantAddressID] [int] NOT NULL,
	[RestaurantName] [varchar](20) NOT NULL,
	[PhoneNO] [varchar](20) NOT NULL,
	[CityID] [int] NOT NULL,
 CONSTRAINT [PK_Restaurants] PRIMARY KEY CLUSTERED 
(
	[RestaurantID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Reviews](
	[ReviewID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[Ratings] [int] NOT NULL,
	[ReviewDate] [datetime] NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[RestaurantID] [int] NULL,
	[RoomID] [int] NULL,
	[OrganizerID] [int] NULL,
	[Description] [varchar](100) NULL,
 CONSTRAINT [PK_Reviews] PRIMARY KEY CLUSTERED 
(
	[ReviewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[RoomBookings](
	[RoomID] [int] NOT NULL,
	[BookingID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RoomBookings] PRIMARY KEY CLUSTERED 
(
	[RoomID] ASC,
	[BookingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Rooms](
	[RoomID] [int] IDENTITY(1,1) NOT NULL,
	[HotelID] [int] NOT NULL,
	[RoomType] [varchar](20) NOT NULL,
	[NoOfBeds] [int] NOT NULL,
	[IsSmoking] [bit] NOT NULL,
	[IsAC] [bit] NOT NULL,
	[IsMiniBar] [bit] NOT NULL,
	[Description] [varchar](20) NOT NULL,
	[IsPetFriendly] [bit] NOT NULL,
	[PricePerNight] [money] NOT NULL,
	[AvailableRooms] [int] NOT NULL,
 CONSTRAINT [PK_Rooms] PRIMARY KEY CLUSTERED 
(
	[RoomID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[TouristAttractions](
	[PlaceID] [int] IDENTITY(1,1) NOT NULL,
	[PlaceAddressID] [int] NOT NULL,
	[PreferedStartTime] [datetime] NOT NULL,
	[PreferedEndTime] [datetime] NOT NULL,
	[CityID] [int] NOT NULL,
	[Name] [varchar](20) NOT NULL,
 CONSTRAINT [PK_TouristAttractions] PRIMARY KEY CLUSTERED 
(
	[PlaceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_CustomerAddresses] ON [dbo].[CustomerAddresses]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Address]  WITH CHECK ADD  CONSTRAINT [FK_Address_Cities] FOREIGN KEY([CityID])
REFERENCES [dbo].[Cities] ([CityID])
GO
ALTER TABLE [dbo].[Address] CHECK CONSTRAINT [FK_Address_Cities]
GO
ALTER TABLE [dbo].[Bookings]  WITH CHECK ADD  CONSTRAINT [FK_Bookings_BookingType] FOREIGN KEY([BookingTypeID])
REFERENCES [dbo].[BookingType] ([BookingTypeID])
GO
ALTER TABLE [dbo].[Bookings] CHECK CONSTRAINT [FK_Bookings_BookingType]
GO
ALTER TABLE [dbo].[Bookings]  WITH CHECK ADD  CONSTRAINT [FK_Bookings_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Bookings] CHECK CONSTRAINT [FK_Bookings_Customers]
GO
ALTER TABLE [dbo].[Bookings]  WITH CHECK ADD  CONSTRAINT [FK_Bookings_EventOrganizer] FOREIGN KEY([OrganizerID])
REFERENCES [dbo].[EventOrganizer] ([OrganizerID])
GO
ALTER TABLE [dbo].[Bookings] CHECK CONSTRAINT [FK_Bookings_EventOrganizer]
GO
ALTER TABLE [dbo].[Bookings]  WITH CHECK ADD  CONSTRAINT [FK_Bookings_Restaurants] FOREIGN KEY([ResturantID])
REFERENCES [dbo].[Restaurants] ([RestaurantID])
GO
ALTER TABLE [dbo].[Bookings] CHECK CONSTRAINT [FK_Bookings_Restaurants]
GO
ALTER TABLE [dbo].[CustomerAddresses]  WITH CHECK ADD  CONSTRAINT [FK_CustomerAddresses_Address] FOREIGN KEY([AddressID])
REFERENCES [dbo].[Address] ([AddressID])
GO
ALTER TABLE [dbo].[CustomerAddresses] CHECK CONSTRAINT [FK_CustomerAddresses_Address]
GO
ALTER TABLE [dbo].[CustomerAddresses]  WITH CHECK ADD  CONSTRAINT [FK_CustomerAddresses_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[CustomerAddresses] CHECK CONSTRAINT [FK_CustomerAddresses_Customers]
GO
ALTER TABLE [dbo].[EventOrganizer]  WITH CHECK ADD  CONSTRAINT [FK_EventOrganizer_Address] FOREIGN KEY([OrganizerAddressID])
REFERENCES [dbo].[Address] ([AddressID])
GO
ALTER TABLE [dbo].[EventOrganizer] CHECK CONSTRAINT [FK_EventOrganizer_Address]
GO
ALTER TABLE [dbo].[Events]  WITH CHECK ADD  CONSTRAINT [FK_Events_Address] FOREIGN KEY([EventAddressID])
REFERENCES [dbo].[Address] ([AddressID])
GO
ALTER TABLE [dbo].[Events] CHECK CONSTRAINT [FK_Events_Address]
GO
ALTER TABLE [dbo].[Events]  WITH CHECK ADD  CONSTRAINT [FK_Events_EventOrganizer] FOREIGN KEY([OrganizerID])
REFERENCES [dbo].[EventOrganizer] ([OrganizerID])
GO
ALTER TABLE [dbo].[Events] CHECK CONSTRAINT [FK_Events_EventOrganizer]
GO
ALTER TABLE [dbo].[EventSchedule]  WITH CHECK ADD  CONSTRAINT [FK_EventSchedule_EventOrganizer] FOREIGN KEY([OrganizerID])
REFERENCES [dbo].[EventOrganizer] ([OrganizerID])
GO
ALTER TABLE [dbo].[EventSchedule] CHECK CONSTRAINT [FK_EventSchedule_EventOrganizer]
GO
ALTER TABLE [dbo].[EventSchedule]  WITH CHECK ADD  CONSTRAINT [FK_EventSchedule_Events] FOREIGN KEY([EventID])
REFERENCES [dbo].[Events] ([EventID])
GO
ALTER TABLE [dbo].[EventSchedule] CHECK CONSTRAINT [FK_EventSchedule_Events]
GO
ALTER TABLE [dbo].[Hotels]  WITH CHECK ADD  CONSTRAINT [FK_Hotels_Address] FOREIGN KEY([HotelAddressID])
REFERENCES [dbo].[Address] ([AddressID])
GO
ALTER TABLE [dbo].[Hotels] CHECK CONSTRAINT [FK_Hotels_Address]
GO
ALTER TABLE [dbo].[Hotels]  WITH CHECK ADD  CONSTRAINT [FK_Hotels_Cities] FOREIGN KEY([CityID])
REFERENCES [dbo].[Cities] ([CityID])
GO
ALTER TABLE [dbo].[Hotels] CHECK CONSTRAINT [FK_Hotels_Cities]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Address] FOREIGN KEY([BillingAddressID])
REFERENCES [dbo].[Address] ([AddressID])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Address]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Bookings] FOREIGN KEY([BookingID])
REFERENCES [dbo].[Bookings] ([BookingID])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Bookings]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_PaymentMethod] FOREIGN KEY([PaymentMethodID])
REFERENCES [dbo].[PaymentMethod] ([PaymentMethodID])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_PaymentMethod]
GO
ALTER TABLE [dbo].[Restaurants]  WITH CHECK ADD  CONSTRAINT [FK_Restaurants_Address] FOREIGN KEY([RestaurantAddressID])
REFERENCES [dbo].[Address] ([AddressID])
GO
ALTER TABLE [dbo].[Restaurants] CHECK CONSTRAINT [FK_Restaurants_Address]
GO
ALTER TABLE [dbo].[Restaurants]  WITH CHECK ADD  CONSTRAINT [FK_Restaurants_Cities] FOREIGN KEY([CityID])
REFERENCES [dbo].[Cities] ([CityID])
GO
ALTER TABLE [dbo].[Restaurants] CHECK CONSTRAINT [FK_Restaurants_Cities]
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD  CONSTRAINT [FK_Reviews_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [FK_Reviews_Customers]
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD  CONSTRAINT [FK_Reviews_EventOrganizer] FOREIGN KEY([OrganizerID])
REFERENCES [dbo].[EventOrganizer] ([OrganizerID])
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [FK_Reviews_EventOrganizer]
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD  CONSTRAINT [FK_Reviews_Restaurants] FOREIGN KEY([RestaurantID])
REFERENCES [dbo].[Restaurants] ([RestaurantID])
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [FK_Reviews_Restaurants]
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD  CONSTRAINT [FK_Reviews_Rooms] FOREIGN KEY([RoomID])
REFERENCES [dbo].[Rooms] ([RoomID])
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [FK_Reviews_Rooms]
GO
ALTER TABLE [dbo].[RoomBookings]  WITH CHECK ADD  CONSTRAINT [FK_RoomBookings_Bookings] FOREIGN KEY([BookingID])
REFERENCES [dbo].[Bookings] ([BookingID])
GO
ALTER TABLE [dbo].[RoomBookings] CHECK CONSTRAINT [FK_RoomBookings_Bookings]
GO
ALTER TABLE [dbo].[RoomBookings]  WITH CHECK ADD  CONSTRAINT [FK_RoomBookings_Rooms] FOREIGN KEY([RoomID])
REFERENCES [dbo].[Rooms] ([RoomID])
GO
ALTER TABLE [dbo].[RoomBookings] CHECK CONSTRAINT [FK_RoomBookings_Rooms]
GO
ALTER TABLE [dbo].[Rooms]  WITH CHECK ADD  CONSTRAINT [FK_Rooms_Hotels] FOREIGN KEY([HotelID])
REFERENCES [dbo].[Hotels] ([HotelID])
GO
ALTER TABLE [dbo].[Rooms] CHECK CONSTRAINT [FK_Rooms_Hotels]
GO
ALTER TABLE [dbo].[TouristAttractions]  WITH CHECK ADD  CONSTRAINT [FK_TouristAttractions_Address] FOREIGN KEY([PlaceAddressID])
REFERENCES [dbo].[Address] ([AddressID])
GO
ALTER TABLE [dbo].[TouristAttractions] CHECK CONSTRAINT [FK_TouristAttractions_Address]
GO
ALTER TABLE [dbo].[TouristAttractions]  WITH CHECK ADD  CONSTRAINT [FK_TouristAttractions_Cities] FOREIGN KEY([CityID])
REFERENCES [dbo].[Cities] ([CityID])
GO
ALTER TABLE [dbo].[TouristAttractions] CHECK CONSTRAINT [FK_TouristAttractions_Cities]
GO

-- view to see event organizers and their details
CREATE VIEW vw_EventOrganizerDetails
AS
SELECT TOP 20   eo.[OrganizerName],
				ad.[AddressLine1] AS Address,
				eo.[PhoneNo],
				ct.[CityName],
				eo.[Website]   
FROM [dbo].[EventOrganizer] AS eo
JOIN [dbo].[Address] AS ad
	ON eo.[OrganizerAddressID] = ad.[AddressID] 
JOIN [dbo].[Cities] AS ct
	ON  ad.[CityID] = ct.[CityID]
ORDER BY [OrganizerName] ASC;
GO

-- view to see first 100 hotel bookings based on hotels, ordered by the no. of bookings
CREATE VIEW vw_HotelMaxBookings
AS
SELECT TOP 20  h.HotelName,
			   (SELECT CityName FROM Cities city
					WHERE city.CityID = h.CityID) [CityName],
			   a.AddressLine1 [Address],
			   h.PhoneNumber,
			   (SELECT COUNT(booking.BookingID)
					FROM [dbo].[RoomBookings] booking
					WHERE r.RoomID = booking.RoomID) AS 'NumberOfBookings'
FROM [dbo].[Hotels] h,
	 [dbo].[Rooms] r,
	 [dbo].[Address] a
WHERE h.HotelID = r.HotelID AND h.HotelAddressID = a.AddressID
ORDER BY [NumberOfBookings] DESC;
GO

SET IDENTITY_INSERT [dbo].[Customers] OFF
SET IDENTITY_INSERT [dbo].[BookingType] ON 

INSERT [dbo].[BookingType] ([BookingTypeID], [BookingTypeName]) VALUES (1, N'resturant booking')
INSERT [dbo].[BookingType] ([BookingTypeID], [BookingTypeName]) VALUES (2, N'hotel booking')
INSERT [dbo].[BookingType] ([BookingTypeID], [BookingTypeName]) VALUES (3, N'event booking')
INSERT [dbo].[BookingType] ([BookingTypeID], [BookingTypeName]) VALUES (4, N'travel booking')
INSERT [dbo].[BookingType] ([BookingTypeID], [BookingTypeName]) VALUES (5, N'advanced booking')
INSERT [dbo].[BookingType] ([BookingTypeID], [BookingTypeName]) VALUES (6, N'hybrid booking')

SET IDENTITY_INSERT [dbo].[BookingType] OFF
SET IDENTITY_INSERT [dbo].[Cities] ON 

INSERT [dbo].[Cities] ([CityID], [CityName], [State], [CountryName]) VALUES (1, N'New York', N'NY', N'United State')
INSERT [dbo].[Cities] ([CityID], [CityName], [State], [CountryName]) VALUES (2, N'boston', N'MA', N'United State')
INSERT [dbo].[Cities] ([CityID], [CityName], [State], [CountryName]) VALUES (3, N'twin city', N'WA', N'United State')
INSERT [dbo].[Cities] ([CityID], [CityName], [State], [CountryName]) VALUES (4, N'las vegas', N'NEA', N'United State')
INSERT [dbo].[Cities] ([CityID], [CityName], [State], [CountryName]) VALUES (5, N'tokyo', N'TKO', N'United State')
INSERT [dbo].[Cities] ([CityID], [CityName], [State], [CountryName]) VALUES (6, N'seattle', N'WA', N'United State')
INSERT [dbo].[Cities] ([CityID], [CityName], [State], [CountryName]) VALUES (7, N'portland', N'NH', N'United State')
INSERT [dbo].[Cities] ([CityID], [CityName], [State], [CountryName]) VALUES (8, N'DC', N'DC', N'United State')
INSERT [dbo].[Cities] ([CityID], [CityName], [State], [CountryName]) VALUES (9, N'cambridge', N'LONDON', N'United Kindom')
INSERT [dbo].[Cities] ([CityID], [CityName], [State], [CountryName]) VALUES (10, N'shanghai', N'SH', N'China')
INSERT [dbo].[Cities] ([CityID], [CityName], [State], [CountryName]) VALUES (11, N'seol', N'INCHEONG', N'South Korea')

SET IDENTITY_INSERT [dbo].[Cities] OFF
SET IDENTITY_INSERT [dbo].[Address] ON 

INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (1, N'Business', N'110 park drive', N'boston', 2, 2115)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (2, N'Business', N'111 park drive', N'boston', 2, 2114)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (3, N'Residential', N'113 75 avenue', N'New York', 1, 1234)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (4, N'Business', N'128 Huntington', N'New York', 1, 1235)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (5, N'Business', N'103 fenway park', N'boston', 2, 21158)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (6, N'Business', N'112 back bay', N'boston', 2, 11587)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (7, N'Residential', N'971 flagstaff', N'las vegas', 4, 11589)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (8, N'Residential', N'1020 green hill', N'las vegas', 4, 8596)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (9, N'Residential', N'1031 broadway west', N'New York', 1, 7854)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (10, N'Business', N'Blue village 116', N'Shanghai', 10, 589)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (11, N'Business', N'West land 123', N'Seol', 11, 4598)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (12, N'Business', N'longwood 9801', N'Seol', 11, 7854)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (13, N'Business', N'5 Darling St', N'Boston', 2, 2120)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (18, N'Business', N'879 Huntington Ave', N'New York', 1, 1254)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (19, N'Business', N'3 Parker Hill', N'Las Vegas', 4, 56346)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (20, N'Business', N'78 Rocksbury St', N'Seattle', 4, 8970)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (21, N'Business', N'678 Blue Hill', N'Cambridge', 9, 67345)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (22, N'Business', N'45 Ford St', N'New York', 1, 89678)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (23, N'Business', N'5 Goan High', N'Tokyo', 5, 34907)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (24, N'Business', N'678 Tall Hill', N'TwinCity', 3, 45890)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (25, N'Business', N'East Village 23', N'Portland', 7, 78567)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (26, N'Business', N'123 BackBay', N'DC', 8, 45367)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (27, N'Business', N'7 Pali Hill', N'Twin City', 3, 45267)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (28, N'Business', N'67 East bandra', N'Tokyo', 5, 12356)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (29, N'Business', N'5th Avenue', N'Seattle', 6, 8456)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (30, N'Business', N'12th Avenue', N'Portland', 7, 34789)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (31, N'Business', N'8 Greater Park', N'DC', 8, 67349)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (32, N'Business', N'7 Central Park', N'Seol', 11, 67345)
INSERT [dbo].[Address] ([AddressID], [AddressType], [AddressLine1], [AddressLine2], [CityID], [Zipcode]) VALUES (33, N'Business', N'65 East Village', N'Cambridge', 9, 89345)

SET IDENTITY_INSERT [dbo].[Address] OFF
SET IDENTITY_INSERT [dbo].[Customers] ON 

INSERT [dbo].[Customers] ([CustomerID], [CustomerFirstName], [CustomerLastName], [DOB], [Gender], [PhoneNumber], [MemberSince]) VALUES (1, N'emily', N'munson', CAST(N'1991-08-01T00:00:00.000' AS DateTime), N'female', CAST('6178965439' AS varbinary(200)), CAST(N'2012-02-04T00:00:00.000' AS DateTime))
INSERT [dbo].[Customers] ([CustomerID], [CustomerFirstName], [CustomerLastName], [DOB], [Gender], [PhoneNumber], [MemberSince]) VALUES (2, N'andy', N'chen', CAST(N'1992-02-09T00:00:00.000' AS DateTime), N'male', CAST('6785904789' AS varbinary(200)), CAST(N'2013-09-07T00:00:00.000' AS DateTime))
INSERT [dbo].[Customers] ([CustomerID], [CustomerFirstName], [CustomerLastName], [DOB], [Gender], [PhoneNumber], [MemberSince]) VALUES (3, N'kikyo', N'Satuki', CAST(N'1995-06-30T00:00:00.000' AS DateTime), N'female', CAST('8906789090' AS varbinary(200)), CAST(N'2014-09-11T00:00:00.000' AS DateTime))
INSERT [dbo].[Customers] ([CustomerID], [CustomerFirstName], [CustomerLastName], [DOB], [Gender], [PhoneNumber], [MemberSince]) VALUES (4, N'lexi', N'robinson', CAST(N'1994-09-01T00:00:00.000' AS DateTime), N'female', CAST('5674908378' AS varbinary(200)), CAST(N'2013-01-05T00:00:00.000' AS DateTime))
INSERT [dbo].[Customers] ([CustomerID], [CustomerFirstName], [CustomerLastName], [DOB], [Gender], [PhoneNumber], [MemberSince]) VALUES (5, N'john', N'smith', CAST(N'1996-09-11T00:00:00.000' AS DateTime), N'female', CAST('2569045678' AS varbinary(200)), CAST(N'2015-08-11T00:00:00.000' AS DateTime))
INSERT [dbo].[Customers] ([CustomerID], [CustomerFirstName], [CustomerLastName], [DOB], [Gender], [PhoneNumber], [MemberSince]) VALUES (6, N'tereasa', N'kulk', CAST(N'1994-03-06T00:00:00.000' AS DateTime), N'male', CAST('7895634567' AS varbinary(200)), CAST(N'2011-01-31T00:00:00.000' AS DateTime))
INSERT [dbo].[Customers] ([CustomerID], [CustomerFirstName], [CustomerLastName], [DOB], [Gender], [PhoneNumber], [MemberSince]) VALUES (7, N'constance', N'tarvo', CAST(N'1995-06-14T00:00:00.000' AS DateTime), N'female', CAST('4563908256' AS varbinary(200)), CAST(N'2014-08-16T00:00:00.000' AS DateTime))
INSERT [dbo].[Customers] ([CustomerID], [CustomerFirstName], [CustomerLastName], [DOB], [Gender], [PhoneNumber], [MemberSince]) VALUES (8, N'lydia', N'diago', CAST(N'1998-08-11T00:00:00.000' AS DateTime), N'male', CAST('7859046789' AS varbinary(200)), CAST(N'2016-07-19T00:00:00.000' AS DateTime))
INSERT [dbo].[Customers] ([CustomerID], [CustomerFirstName], [CustomerLastName], [DOB], [Gender], [PhoneNumber], [MemberSince]) VALUES (9, N'mirana', N'lestrange', CAST(N'1997-12-13T00:00:00.000' AS DateTime), N'female', CAST('6589046790' AS varbinary(200)), CAST(N'2015-11-11T00:00:00.000' AS DateTime))
INSERT [dbo].[Customers] ([CustomerID], [CustomerFirstName], [CustomerLastName], [DOB], [Gender], [PhoneNumber], [MemberSince]) VALUES (10, N'ursa', N'polingski', CAST(N'1993-08-07T00:00:00.000' AS DateTime), N'male', CAST('3458925670' AS varbinary(200)), CAST(N'2017-02-19T00:00:00.000' AS DateTime))
INSERT [dbo].[Customers] ([CustomerID], [CustomerFirstName], [CustomerLastName], [DOB], [Gender], [PhoneNumber], [MemberSince]) VALUES (11, N'jugger', N'axe', CAST(N'1993-01-03T00:00:00.000' AS DateTime), N'male', CAST('7683456032' AS varbinary(200)), CAST(N'2017-10-16T00:00:00.000' AS DateTime))

SET IDENTITY_INSERT [dbo].[Customers] OFF

-- Lookup table: [CustomerAddresses]

INSERT [dbo].[CustomerAddresses] ([CustomerID], [AddressID]) VALUES (1, 1)
INSERT [dbo].[CustomerAddresses] ([CustomerID], [AddressID]) VALUES (2, 2)
INSERT [dbo].[CustomerAddresses] ([CustomerID], [AddressID]) VALUES (3, 3)
INSERT [dbo].[CustomerAddresses] ([CustomerID], [AddressID]) VALUES (4, 4)
INSERT [dbo].[CustomerAddresses] ([CustomerID], [AddressID]) VALUES (5, 5)
INSERT [dbo].[CustomerAddresses] ([CustomerID], [AddressID]) VALUES (6, 6)
INSERT [dbo].[CustomerAddresses] ([CustomerID], [AddressID]) VALUES (7, 7)
INSERT [dbo].[CustomerAddresses] ([CustomerID], [AddressID]) VALUES (8, 8)
INSERT [dbo].[CustomerAddresses] ([CustomerID], [AddressID]) VALUES (9, 9)
INSERT [dbo].[CustomerAddresses] ([CustomerID], [AddressID]) VALUES (10, 10)
INSERT [dbo].[CustomerAddresses] ([CustomerID], [AddressID]) VALUES (11, 11)

SET IDENTITY_INSERT [dbo].[EventOrganizer] ON 

INSERT [dbo].[EventOrganizer] ([OrganizerID], [OrganizerAddressID], [OrganizerName], [PhoneNo], [Description], [Website]) VALUES (1, 21, N'Alvon', N'8265123484', N'festival event', N'www.alvevent.com')
INSERT [dbo].[EventOrganizer] ([OrganizerID], [OrganizerAddressID], [OrganizerName], [PhoneNo], [Description], [Website]) VALUES (3, 22, N'Lydia', N'2344523423', N'child service', N'www.lovevoc.com')
INSERT [dbo].[EventOrganizer] ([OrganizerID], [OrganizerAddressID], [OrganizerName], [PhoneNo], [Description], [Website]) VALUES (4, 23, N'Mitkou', N'2971123446', N'carnival ', N'www.funevt.com')
INSERT [dbo].[EventOrganizer] ([OrganizerID], [OrganizerAddressID], [OrganizerName], [PhoneNo], [Description], [Website]) VALUES (5, 24, N'Yolanda', N'9814456114', N'parade', N'www.yoforvoa.com')
INSERT [dbo].[EventOrganizer] ([OrganizerID], [OrganizerAddressID], [OrganizerName], [PhoneNo], [Description], [Website]) VALUES (6, 21, N'Randy', N'9880146778', N'elder people', N'www.randytour.com')
INSERT [dbo].[EventOrganizer] ([OrganizerID], [OrganizerAddressID], [OrganizerName], [PhoneNo], [Description], [Website]) VALUES (7, 22, N'Bob', N'3526611221', N'large group', N'www.bobfun.com')
INSERT [dbo].[EventOrganizer] ([OrganizerID], [OrganizerAddressID], [OrganizerName], [PhoneNo], [Description], [Website]) VALUES (8, 23, N'Okinawa', N'1229771355', N'couple', N'www.couple.com')
INSERT [dbo].[EventOrganizer] ([OrganizerID], [OrganizerAddressID], [OrganizerName], [PhoneNo], [Description], [Website]) VALUES (9, 24, N'Walmart', N'1389913460', N'shopping tour', N'www.letsbuy.com')
INSERT [dbo].[EventOrganizer] ([OrganizerID], [OrganizerAddressID], [OrganizerName], [PhoneNo], [Description], [Website]) VALUES (10, 21, N'Peter', N'5421333333', N'duty free ', N'www.petetravel.com')
INSERT [dbo].[EventOrganizer] ([OrganizerID], [OrganizerAddressID], [OrganizerName], [PhoneNo], [Description], [Website]) VALUES (11, 23, N'Herb', N'3662113111', N'clinic', N'www.herb.com')

SET IDENTITY_INSERT [dbo].[EventOrganizer] OFF
SET IDENTITY_INSERT [dbo].[Events] ON 

INSERT [dbo].[Events] ([EventID], [OrganizerID], [EventAddressID], [EventName], [PricePerGuest], [Description], [Website]) VALUES (1, 1, 25, N'New year parade', 16.0000, N'new year ', N'www.newyear.com')
INSERT [dbo].[Events] ([EventID], [OrganizerID], [EventAddressID], [EventName], [PricePerGuest], [Description], [Website]) VALUES (2, 3, 26, N'duty free shopping', 8000.0000, N'pure shopping', N'www.letsbuy.com')
INSERT [dbo].[Events] ([EventID], [OrganizerID], [EventAddressID], [EventName], [PricePerGuest], [Description], [Website]) VALUES (3, 4, 27, N'herb', 40.0000, N'health and pill', N'www.herb.com')
INSERT [dbo].[Events] ([EventID], [OrganizerID], [EventAddressID], [EventName], [PricePerGuest], [Description], [Website]) VALUES (4, 5, 28, N'valentine journey', 2000.0000, N'romantic', N'www.couple.com')
INSERT [dbo].[Events] ([EventID], [OrganizerID], [EventAddressID], [EventName], [PricePerGuest], [Description], [Website]) VALUES (6, 6, 25, N'elder people', 300.0000, N'elder people', N'www.randytour.com')
INSERT [dbo].[Events] ([EventID], [OrganizerID], [EventAddressID], [EventName], [PricePerGuest], [Description], [Website]) VALUES (7, 7, 26, N'big fun', 300.0000, N'500 people on beach', N'www.petetravel.com')
INSERT [dbo].[Events] ([EventID], [OrganizerID], [EventAddressID], [EventName], [PricePerGuest], [Description], [Website]) VALUES (8, 8, 27, N'Lagend show', 230.0000, N'carnival parade', N'www.funevt.com')
INSERT [dbo].[Events] ([EventID], [OrganizerID], [EventAddressID], [EventName], [PricePerGuest], [Description], [Website]) VALUES (9, 9, 28, N'fantasy', 450.0000, N'saint patrick', N'www.alvevent.com')
INSERT [dbo].[Events] ([EventID], [OrganizerID], [EventAddressID], [EventName], [PricePerGuest], [Description], [Website]) VALUES (10, 10, 25, N'peter pan', 25.0000, N'children', N'www.lovevoc.com')
INSERT [dbo].[Events] ([EventID], [OrganizerID], [EventAddressID], [EventName], [PricePerGuest], [Description], [Website]) VALUES (11, 11, 26, N'dac', 100.0000, N'game', N'www.game.com')

SET IDENTITY_INSERT [dbo].[Events] OFF

-- Lookup table: [EventSchedule]

INSERT [dbo].[EventSchedule] ([EventID], [OrganizerID]) VALUES (1, 1)
INSERT [dbo].[EventSchedule] ([EventID], [OrganizerID]) VALUES (2, 3)
INSERT [dbo].[EventSchedule] ([EventID], [OrganizerID]) VALUES (3, 4)
INSERT [dbo].[EventSchedule] ([EventID], [OrganizerID]) VALUES (4, 5)
INSERT [dbo].[EventSchedule] ([EventID], [OrganizerID]) VALUES (6, 6)
INSERT [dbo].[EventSchedule] ([EventID], [OrganizerID]) VALUES (7, 7)
INSERT [dbo].[EventSchedule] ([EventID], [OrganizerID]) VALUES (8, 8)
INSERT [dbo].[EventSchedule] ([EventID], [OrganizerID]) VALUES (9, 9)
INSERT [dbo].[EventSchedule] ([EventID], [OrganizerID]) VALUES (10, 10)
INSERT [dbo].[EventSchedule] ([EventID], [OrganizerID]) VALUES (11, 11)

SET IDENTITY_INSERT [dbo].[Hotels] ON 

INSERT [dbo].[Hotels] ([HotelID], [CityID], [HotelAddressID], [HotelName], [PhoneNumber], [Description]) VALUES (1, 6, 29, N'mirage', N'3282655667', N'free wifi')
INSERT [dbo].[Hotels] ([HotelID], [CityID], [HotelAddressID], [HotelName], [PhoneNumber], [Description]) VALUES (2, 7, 30, N'linQ', N'7899444572', N'five star ')
INSERT [dbo].[Hotels] ([HotelID], [CityID], [HotelAddressID], [HotelName], [PhoneNumber], [Description]) VALUES (3, 8, 31, N'treasure island', N'6796945635', N'comfort ')
INSERT [dbo].[Hotels] ([HotelID], [CityID], [HotelAddressID], [HotelName], [PhoneNumber], [Description]) VALUES (4, 11, 32, N'circus resort', N'4337992376', N'casino ')
INSERT [dbo].[Hotels] ([HotelID], [CityID], [HotelAddressID], [HotelName], [PhoneNumber], [Description]) VALUES (5, 9, 33, N'golden nugget', N'2679647457', N'show')
INSERT [dbo].[Hotels] ([HotelID], [CityID], [HotelAddressID], [HotelName], [PhoneNumber], [Description]) VALUES (6, 6, 29, N'trump international', N'3254699580', N'four star')
INSERT [dbo].[Hotels] ([HotelID], [CityID], [HotelAddressID], [HotelName], [PhoneNumber], [Description]) VALUES (7, 7, 30, N'rio casino', N'1246899927', N'casino')
INSERT [dbo].[Hotels] ([HotelID], [CityID], [HotelAddressID], [HotelName], [PhoneNumber], [Description]) VALUES (8, 8, 31, N'plaza hotel', N'6468232210', N'buffet')
INSERT [dbo].[Hotels] ([HotelID], [CityID], [HotelAddressID], [HotelName], [PhoneNumber], [Description]) VALUES (9, 11, 32, N'wynn las vegas', N'2339572015', N'fountain')
INSERT [dbo].[Hotels] ([HotelID], [CityID], [HotelAddressID], [HotelName], [PhoneNumber], [Description]) VALUES (10, 9, 33, N'renaissance ', N'1554219489', N'landscape')
INSERT [dbo].[Hotels] ([HotelID], [CityID], [HotelAddressID], [HotelName], [PhoneNumber], [Description]) VALUES (11, 6, 29, N'THE D', N'9854124321', N'show')

SET IDENTITY_INSERT [dbo].[Hotels] OFF
SET IDENTITY_INSERT [dbo].[Restaurants] ON 

INSERT [dbo].[Restaurants] ([RestaurantID], [RestaurantAddressID], [RestaurantName], [PhoneNO], [CityID]) VALUES (1, 13, N'The Taj Vivanta', N'233435', 2)
INSERT [dbo].[Restaurants] ([RestaurantID], [RestaurantAddressID], [RestaurantName], [PhoneNO], [CityID]) VALUES (2, 18, N'Euphoria', N'5768565', 1)
INSERT [dbo].[Restaurants] ([RestaurantID], [RestaurantAddressID], [RestaurantName], [PhoneNO], [CityID]) VALUES (3, 19, N'Papa Johns', N'5683433', 4)
INSERT [dbo].[Restaurants] ([RestaurantID], [RestaurantAddressID], [RestaurantName], [PhoneNO], [CityID]) VALUES (4, 20, N'Wok N Tok', N'9568533', 4)

SET IDENTITY_INSERT [dbo].[Restaurants] OFF
SET IDENTITY_INSERT [dbo].[Bookings] ON

INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (1, 2, CAST(N'2012-08-17T00:00:00.000' AS DateTime), 3, NULL, 1, 75.0000, 225.0000, CAST(N'2012-08-17T08:30:00.000' AS DateTime), 1)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (2, 1, CAST(N'2012-09-08T00:00:00.000' AS DateTime), 4, 3, 3, 58.0000, 232.0000, CAST(N'2012-09-08T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (3, 4, CAST(N'2012-01-13T00:00:00.000' AS DateTime), 5, NULL, 1, 89.0000, 445.0000, CAST(N'2012-01-03T00:00:00.000' AS DateTime), 3)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (4, 3, CAST(N'2012-06-07T00:00:00.000' AS DateTime), 12, 4, 3, 50.0000, 600.0000, CAST(N'2012-06-07T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (5, 5, CAST(N'2014-05-16T00:00:00.000' AS DateTime), 1, NULL, 1, 1000.0000, 1000.0000, CAST(N'2014-05-16T00:00:00.000' AS DateTime), 2)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (6, 6, CAST(N'2014-05-20T00:00:00.000' AS DateTime), 4, NULL, 1, 86.0000, 144.0000, CAST(N'2014-05-20T00:00:00.000' AS DateTime), 4)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (7, 8, CAST(N'2015-09-06T00:00:00.000' AS DateTime), 2, 7, 3, 90.0000, 180.0000, CAST(N'2015-09-06T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (8, 9, CAST(N'2015-07-15T00:00:00.000' AS DateTime), 15, 8, 3, 1000.0000, 1500.0000, CAST(N'2015-07-15T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (9, 10, CAST(N'2016-01-01T00:00:00.000' AS DateTime), 7, 9, 3, 75.0000, 515.0000, CAST(N'2016-01-01T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (10, 11, CAST(N'2016-07-03T00:00:00.000' AS DateTime), 5, 10, 3, 50.0000, 250.0000, CAST(N'2016-01-01T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (11, 4, CAST(N'2016-12-13T00:00:00.000' AS DateTime), 4, 11, 3, 160.0000, 640.0000, CAST(N'2016-12-13T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (12, 1, CAST(N'2016-12-13T00:00:00.000' AS DateTime), 4, NULL, 2, 60.0000, 240.0000, CAST(N'2016-12-13T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (13, 3, CAST(N'2015-10-15T00:00:00.000' AS DateTime), 2, NULL, 2, 100.0000, 200.0000, CAST(N'2016-12-13T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (14, 2, CAST(N'2012-09-10T00:00:00.000' AS DateTime), 1, NULL, 2, 100.0000, 100.0000, CAST(N'2016-12-13T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (15, 5, CAST(N'2011-02-23T00:00:00.000' AS DateTime), 1, NULL, 2, 60.0000, 60.0000, CAST(N'2016-12-13T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (16, 7, CAST(N'2013-01-23T00:00:00.000' AS DateTime), 5, NULL, 2, 350.0000, 1750.0000, CAST(N'2016-12-13T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (17, 10, CAST(N'2016-11-17T00:00:00.000' AS DateTime), 3, NULL, 2, 60.0000, 180.0000, CAST(N'2016-12-13T00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Bookings] ([BookingID], [CustomerID], [BookingDate], [NoOfGuests], [OrganizerID], [BookingTypeID], [UnitPrice], [TotalPrice], [TimeStamp], [ResturantID]) VALUES (18, 9, CAST(N'2016-10-15T00:00:00.000' AS DateTime), 4, NULL, 2, 35.0000, 140.0000, CAST(N'2016-12-13T00:00:00.000' AS DateTime), NULL)

SET IDENTITY_INSERT [dbo].[Bookings] OFF
SET IDENTITY_INSERT [dbo].[PaymentMethod] ON 

INSERT [dbo].[PaymentMethod] ([PaymentMethodID], [PaymentType]) VALUES (1, N'visa')
INSERT [dbo].[PaymentMethod] ([PaymentMethodID], [PaymentType]) VALUES (2, N'cash')
INSERT [dbo].[PaymentMethod] ([PaymentMethodID], [PaymentType]) VALUES (3, N'paypal')
INSERT [dbo].[PaymentMethod] ([PaymentMethodID], [PaymentType]) VALUES (4, N'master card')
INSERT [dbo].[PaymentMethod] ([PaymentMethodID], [PaymentType]) VALUES (5, N'check')
INSERT [dbo].[PaymentMethod] ([PaymentMethodID], [PaymentType]) VALUES (6, N'debit card')
INSERT [dbo].[PaymentMethod] ([PaymentMethodID], [PaymentType]) VALUES (7, N'gift card')
INSERT [dbo].[PaymentMethod] ([PaymentMethodID], [PaymentType]) VALUES (8, N'online')
INSERT [dbo].[PaymentMethod] ([PaymentMethodID], [PaymentType]) VALUES (9, N'student card')
INSERT [dbo].[PaymentMethod] ([PaymentMethodID], [PaymentType]) VALUES (10, N'other')
INSERT [dbo].[PaymentMethod] ([PaymentMethodID], [PaymentType]) VALUES (11, N'employee')

SET IDENTITY_INSERT [dbo].[PaymentMethod] OFF
SET IDENTITY_INSERT [dbo].[Orders] ON 

INSERT [dbo].[Orders] ([OrderID], [PaymentDate], [Quantity], [UnitPrice], [TotalPrice], [BookingID], [PaymentMethodID], [BillingAddressID], [Timestamp]) VALUES (1, CAST(N'2012-09-14T00:00:00.000' AS DateTime), 2, 390.0000, 1200.0000, 1, 1, 1, CAST(N'2012-09-14T00:00:00.000' AS DateTime))
INSERT [dbo].[Orders] ([OrderID], [PaymentDate], [Quantity], [UnitPrice], [TotalPrice], [BookingID], [PaymentMethodID], [BillingAddressID], [Timestamp]) VALUES (2, CAST(N'2012-12-31T00:00:00.000' AS DateTime), 3, 1000.0000, 4000.0000, 2, 2, 2, CAST(N'2012-12-31T00:00:00.000' AS DateTime))
INSERT [dbo].[Orders] ([OrderID], [PaymentDate], [Quantity], [UnitPrice], [TotalPrice], [BookingID], [PaymentMethodID], [BillingAddressID], [Timestamp]) VALUES (3, CAST(N'2013-04-09T00:00:00.000' AS DateTime), 2, 230.0000, 500.0000, 3, 3, 3, CAST(N'2013-04-09T00:00:00.000' AS DateTime))
INSERT [dbo].[Orders] ([OrderID], [PaymentDate], [Quantity], [UnitPrice], [TotalPrice], [BookingID], [PaymentMethodID], [BillingAddressID], [Timestamp]) VALUES (4, CAST(N'2013-05-26T00:00:00.000' AS DateTime), 5, 430.0000, 2700.0000, 4, 4, 4, CAST(N'2013-05-26T00:00:00.000' AS DateTime))
INSERT [dbo].[Orders] ([OrderID], [PaymentDate], [Quantity], [UnitPrice], [TotalPrice], [BookingID], [PaymentMethodID], [BillingAddressID], [Timestamp]) VALUES (5, CAST(N'2014-08-06T00:00:00.000' AS DateTime), 8, 90.0000, 800.0000, 5, 5, 5, CAST(N'2014-08-06T00:00:00.000' AS DateTime))
INSERT [dbo].[Orders] ([OrderID], [PaymentDate], [Quantity], [UnitPrice], [TotalPrice], [BookingID], [PaymentMethodID], [BillingAddressID], [Timestamp]) VALUES (6, CAST(N'2014-11-12T00:00:00.000' AS DateTime), 7, 700.0000, 490.0000, 6, 6, 6, CAST(N'2014-11-12T00:00:00.000' AS DateTime))
INSERT [dbo].[Orders] ([OrderID], [PaymentDate], [Quantity], [UnitPrice], [TotalPrice], [BookingID], [PaymentMethodID], [BillingAddressID], [Timestamp]) VALUES (7, CAST(N'2014-12-28T00:00:00.000' AS DateTime), 1, 150.0000, 155.0000, 1, 7, 7, CAST(N'2014-12-28T00:00:00.000' AS DateTime))
INSERT [dbo].[Orders] ([OrderID], [PaymentDate], [Quantity], [UnitPrice], [TotalPrice], [BookingID], [PaymentMethodID], [BillingAddressID], [Timestamp]) VALUES (8, CAST(N'2015-02-01T00:00:00.000' AS DateTime), 6, 400.0000, 2900.0000, 1, 1, 8, CAST(N'2015-02-01T00:00:00.000' AS DateTime))
INSERT [dbo].[Orders] ([OrderID], [PaymentDate], [Quantity], [UnitPrice], [TotalPrice], [BookingID], [PaymentMethodID], [BillingAddressID], [Timestamp]) VALUES (9, CAST(N'2015-07-13T00:00:00.000' AS DateTime), 10, 250.0000, 4400.0000, 2, 2, 9, CAST(N'2015-07-13T00:00:00.000' AS DateTime))
INSERT [dbo].[Orders] ([OrderID], [PaymentDate], [Quantity], [UnitPrice], [TotalPrice], [BookingID], [PaymentMethodID], [BillingAddressID], [Timestamp]) VALUES (10, CAST(N'2016-06-19T00:00:00.000' AS DateTime), 4, 4000.0000, 17600.0000, 3, 3, 10, CAST(N'2016-06-19T00:00:00.000' AS DateTime))
INSERT [dbo].[Orders] ([OrderID], [PaymentDate], [Quantity], [UnitPrice], [TotalPrice], [BookingID], [PaymentMethodID], [BillingAddressID], [Timestamp]) VALUES (11, CAST(N'2016-07-19T00:00:00.000' AS DateTime), 1, 390.0000, 390.0000, 4, 4, 11, CAST(N'2016-07-19T00:00:00.000' AS DateTime))

SET IDENTITY_INSERT [dbo].[Orders] OFF
SET IDENTITY_INSERT [dbo].[Reviews] ON 

INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (1, 1, 5, CAST(N'2011-05-22T00:00:00.000' AS DateTime), CAST(N'2011-05-22T00:00:00.000' AS DateTime), 1, NULL, NULL, N'french resturant')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (2, 2, 5, CAST(N'2011-06-17T00:00:00.000' AS DateTime), CAST(N'2011-06-17T00:00:00.000' AS DateTime), 2, NULL, NULL, N'chineses cusine')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (3, 3, 4, CAST(N'2011-12-13T00:00:00.000' AS DateTime), CAST(N'2011-12-13T00:00:00.000' AS DateTime), 1, NULL, NULL, N'hot and spicy')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (4, 4, 3, CAST(N'2012-03-11T00:00:00.000' AS DateTime), CAST(N'2012-03-11T00:00:00.000' AS DateTime), 2, NULL, NULL, N'frozen yogurt')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (5, 5, 2, CAST(N'2012-04-22T00:00:00.000' AS DateTime), CAST(N'2012-04-22T00:00:00.000' AS DateTime), 3, NULL, NULL, N'noodle')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (6, 6, 2, CAST(N'2012-09-17T00:00:00.000' AS DateTime), CAST(N'2012-09-17T00:00:00.000' AS DateTime), 4, NULL, NULL, N'soup')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (7, 7, 4, CAST(N'2013-02-01T00:00:00.000' AS DateTime), CAST(N'2013-02-01T00:00:00.000' AS DateTime), NULL, NULL, 4, N'Great Event and Friendly Event Organzers')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (8, 8, 5, CAST(N'2014-03-17T00:00:00.000' AS DateTime), CAST(N'2014-03-17T00:00:00.000' AS DateTime), NULL, NULL, 5, N'Very helpful & organized group')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (9, 9, 5, CAST(N'2015-04-12T00:00:00.000' AS DateTime), CAST(N'2015-04-12T00:00:00.000' AS DateTime), NULL, NULL, 1, N'traditional')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (10, 10, 4, CAST(N'2015-11-27T00:00:00.000' AS DateTime), CAST(N'2015-11-27T00:00:00.000' AS DateTime), NULL, NULL, 3, N'middle east')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (11, 11, 4, CAST(N'2016-05-30T00:00:00.000' AS DateTime), CAST(N'2016-05-30T00:00:00.000' AS DateTime), 3, NULL, NULL, N'awesom chicken dishes')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (12, 1, 5, CAST(N'2014-02-17T00:00:00.000' AS DateTime), CAST(N'2014-02-17T00:00:00.000' AS DateTime), NULL, NULL, 7, N'Very helpful & organized group')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (13, 2, 4, CAST(N'2015-01-27T00:00:00.000' AS DateTime), CAST(N'2015-01-27T00:00:00.000' AS DateTime), NULL, NULL, 8, N'Good Events')
INSERT [dbo].[Reviews] ([ReviewID], [CustomerID], [Ratings], [ReviewDate], [Timestamp], [RestaurantID], [RoomID], [OrganizerID], [Description]) VALUES (14, 3, 3, CAST(N'2016-10-08T00:00:00.000' AS DateTime), CAST(N'2016-10-08T00:00:00.000' AS DateTime), NULL, NULL, 9, N'Good Location & experienced organizers')

SET IDENTITY_INSERT [dbo].[Reviews] OFF
SET IDENTITY_INSERT [dbo].[Rooms] ON 

INSERT [dbo].[Rooms] ([RoomID], [HotelID], [RoomType], [NoOfBeds], [IsSmoking], [IsAC], [IsMiniBar], [Description], [IsPetFriendly], [PricePerNight], [AvailableRooms]) VALUES (9, 1, N'single', 2, 1, 1, 1, N'sweet room', 1, N'50', 5.0000)
INSERT [dbo].[Rooms] ([RoomID], [HotelID], [RoomType], [NoOfBeds], [IsSmoking], [IsAC], [IsMiniBar], [Description], [IsPetFriendly], [PricePerNight], [AvailableRooms]) VALUES (10, 2, N'suite', 4, 0, 1, 1, N'family', 0, N'100', 5.0000)
INSERT [dbo].[Rooms] ([RoomID], [HotelID], [RoomType], [NoOfBeds], [IsSmoking], [IsAC], [IsMiniBar], [Description], [IsPetFriendly], [PricePerNight], [AvailableRooms]) VALUES (11, 3, N'king', 5, 1, 1, 1, N'loft', 0, N'60', 2.0000)
INSERT [dbo].[Rooms] ([RoomID], [HotelID], [RoomType], [NoOfBeds], [IsSmoking], [IsAC], [IsMiniBar], [Description], [IsPetFriendly], [PricePerNight], [AvailableRooms]) VALUES (12, 4, N'king', 1, 1, 1, 1, N'perfect studio', 1, N'200', 3.0000)
INSERT [dbo].[Rooms] ([RoomID], [HotelID], [RoomType], [NoOfBeds], [IsSmoking], [IsAC], [IsMiniBar], [Description], [IsPetFriendly], [PricePerNight], [AvailableRooms]) VALUES (13, 5, N'twin', 2, 0, 0, 0, N'natural friendly', 1, N'100', 10.0000)
INSERT [dbo].[Rooms] ([RoomID], [HotelID], [RoomType], [NoOfBeds], [IsSmoking], [IsAC], [IsMiniBar], [Description], [IsPetFriendly], [PricePerNight], [AvailableRooms]) VALUES (14, 6, N'queen', 2, 1, 1, 1, N'pet ', 1, N'80', 4.0000)
INSERT [dbo].[Rooms] ([RoomID], [HotelID], [RoomType], [NoOfBeds], [IsSmoking], [IsAC], [IsMiniBar], [Description], [IsPetFriendly], [PricePerNight], [AvailableRooms]) VALUES (15, 7, N'yard house', 3, 1, 1, 1, N'tree house', 1, N'150', 5.0000)
INSERT [dbo].[Rooms] ([RoomID], [HotelID], [RoomType], [NoOfBeds], [IsSmoking], [IsAC], [IsMiniBar], [Description], [IsPetFriendly], [PricePerNight], [AvailableRooms]) VALUES (16, 8, N'single', 2, 1, 1, 1, N'large room', 1, N'100', 5.0000)
INSERT [dbo].[Rooms] ([RoomID], [HotelID], [RoomType], [NoOfBeds], [IsSmoking], [IsAC], [IsMiniBar], [Description], [IsPetFriendly], [PricePerNight], [AvailableRooms]) VALUES (17, 9, N'suite', 2, 0, 0, 1, N'baby room', 0, N'35', 10.0000)
INSERT [dbo].[Rooms] ([RoomID], [HotelID], [RoomType], [NoOfBeds], [IsSmoking], [IsAC], [IsMiniBar], [Description], [IsPetFriendly], [PricePerNight], [AvailableRooms]) VALUES (18, 10, N'yard house', 7, 1, 1, 1, N'mansion', 1, N'250', 2.0000)
INSERT [dbo].[Rooms] ([RoomID], [HotelID], [RoomType], [NoOfBeds], [IsSmoking], [IsAC], [IsMiniBar], [Description], [IsPetFriendly], [PricePerNight], [AvailableRooms]) VALUES (19, 11, N'twin', 4, 1, 0, 0, N'three floor', 0, N'350', 5.0000)

SET IDENTITY_INSERT [dbo].[Rooms] OFF
SET IDENTITY_INSERT [dbo].[TouristAttractions] ON 

INSERT [dbo].[TouristAttractions] ([PlaceID], [PlaceAddressID], [PreferedStartTime], [PreferedEndTime], [CityID], [Name]) VALUES (1, 21, CAST(N'2012-07-05T00:00:00.000' AS DateTime), CAST(N'2012-07-07T00:00:00.000' AS DateTime), 9, N'prudential')
INSERT [dbo].[TouristAttractions] ([PlaceID], [PlaceAddressID], [PreferedStartTime], [PreferedEndTime], [CityID], [Name]) VALUES (2, 22, CAST(N'2012-08-29T00:00:00.000' AS DateTime), CAST(N'2012-08-29T00:00:00.000' AS DateTime), 1, N'riverside')
INSERT [dbo].[TouristAttractions] ([PlaceID], [PlaceAddressID], [PreferedStartTime], [PreferedEndTime], [CityID], [Name]) VALUES (3, 23, CAST(N'2012-09-27T00:00:00.000' AS DateTime), CAST(N'2012-09-30T00:00:00.000' AS DateTime), 5, N'longwood')
INSERT [dbo].[TouristAttractions] ([PlaceID], [PlaceAddressID], [PreferedStartTime], [PreferedEndTime], [CityID], [Name]) VALUES (4, 24, CAST(N'2013-03-11T00:00:00.000' AS DateTime), CAST(N'2013-03-11T00:00:00.000' AS DateTime), 3, N'park')
INSERT [dbo].[TouristAttractions] ([PlaceID], [PlaceAddressID], [PreferedStartTime], [PreferedEndTime], [CityID], [Name]) VALUES (5, 25, CAST(N'2013-10-10T00:00:00.000' AS DateTime), CAST(N'2013-11-11T00:00:00.000' AS DateTime), 7, N'newton')
INSERT [dbo].[TouristAttractions] ([PlaceID], [PlaceAddressID], [PreferedStartTime], [PreferedEndTime], [CityID], [Name]) VALUES (6, 26, CAST(N'2013-12-22T00:00:00.000' AS DateTime), CAST(N'2013-12-24T00:00:00.000' AS DateTime), 8, N'church')
INSERT [dbo].[TouristAttractions] ([PlaceID], [PlaceAddressID], [PreferedStartTime], [PreferedEndTime], [CityID], [Name]) VALUES (7, 27, CAST(N'2014-09-28T00:00:00.000' AS DateTime), CAST(N'2014-09-30T00:00:00.000' AS DateTime), 3, N'hill')
INSERT [dbo].[TouristAttractions] ([PlaceID], [PlaceAddressID], [PreferedStartTime], [PreferedEndTime], [CityID], [Name]) VALUES (8, 28, CAST(N'2014-11-13T00:00:00.000' AS DateTime), CAST(N'2014-11-15T00:00:00.000' AS DateTime), 5, N'canyon')
INSERT [dbo].[TouristAttractions] ([PlaceID], [PlaceAddressID], [PreferedStartTime], [PreferedEndTime], [CityID], [Name]) VALUES (9, 21, CAST(N'2014-12-30T00:00:00.000' AS DateTime), CAST(N'2015-01-09T00:00:00.000' AS DateTime), 9, N'backbay')
INSERT [dbo].[TouristAttractions] ([PlaceID], [PlaceAddressID], [PreferedStartTime], [PreferedEndTime], [CityID], [Name]) VALUES (10, 22, CAST(N'2014-10-15T00:00:00.000' AS DateTime), CAST(N'2014-10-24T00:00:00.000' AS DateTime), 1, N'bay')
INSERT [dbo].[TouristAttractions] ([PlaceID], [PlaceAddressID], [PreferedStartTime], [PreferedEndTime], [CityID], [Name]) VALUES (11, 23, CAST(N'2015-03-12T00:00:00.000' AS DateTime), CAST(N'2015-03-17T00:00:00.000' AS DateTime), 5, N'sea port')
INSERT [dbo].[TouristAttractions] ([PlaceID], [PlaceAddressID], [PreferedStartTime], [PreferedEndTime], [CityID], [Name]) VALUES (12, 24, CAST(N'2015-04-16T00:00:00.000' AS DateTime), CAST(N'2015-04-27T00:00:00.000' AS DateTime), 3, N'seattle')

SET IDENTITY_INSERT [dbo].[TouristAttractions] OFF

INSERT [dbo].[RoomBookings] ([RoomID], [BookingID], [StartDate], [EndDate]) VALUES (11, 17, CAST(N'2013-11-11T00:00:00.000' AS DateTime), CAST(N'2013-11-13T00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBookings] ([RoomID], [BookingID], [StartDate], [EndDate]) VALUES (17, 18, CAST(N'2014-06-08T00:00:00.000' AS DateTime), CAST(N'2014-06-13T00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBookings] ([RoomID], [BookingID], [StartDate], [EndDate]) VALUES (11, 12, CAST(N'2014-06-02T00:00:00.000' AS DateTime), CAST(N'2014-06-13T00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBookings] ([RoomID], [BookingID], [StartDate], [EndDate]) VALUES (10, 13, CAST(N'2012-07-05T00:00:00.000' AS DateTime), CAST(N'2012-07-10T00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBookings] ([RoomID], [BookingID], [StartDate], [EndDate]) VALUES (10, 14, CAST(N'2013-05-04T00:00:00.000' AS DateTime), CAST(N'2013-05-17T00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBookings] ([RoomID], [BookingID], [StartDate], [EndDate]) VALUES (11, 15, CAST(N'2015-10-27T00:00:00.000' AS DateTime), CAST(N'2015-10-30T00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBookings] ([RoomID], [BookingID], [StartDate], [EndDate]) VALUES (19, 16, CAST(N'2011-02-18T00:00:00.000' AS DateTime), CAST(N'2011-02-20T00:00:00.000' AS DateTime))

GO