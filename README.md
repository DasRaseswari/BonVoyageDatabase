# Bon Voyage Database Management System

## Specifications

* **Platform:** MS SQL Server 2016
* **OS:** Windows 10

![erd](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/img/ERD_Final.png "Entity Relationship Diagram")

## Summary

* Bon Voyage is a relational database with 17 entities, 2 multi-table views, 2 computed columns and a data encryption trigger

* Bon voyage is a powerful reservation database designed for tour & activity of all sizes, built to bring ease and efficiency to every aspect of your tour 

## Overview

A hotel's reservation system is the heart of the hotel itself. Think about it: if you can't get rooms booked, what's the function of a hotel? For many hotels, a reservations system does more than just book rooms. It also organizes reservations, saves details about guest preferences, and can even keep contact with some special event and restaurant to yield maximum returns. Many reservation solutions can also help you craft hotel deal packages for busy seasons or certain holidays, while still enabling you to come out on the end with a remarkable price.

**Doing this by hand would take a ton of time.**

Again, hotel reservations database or booking software can consolidate all of these booking across a multitude of platforms so that they are organized and available right in front of you in one user-friendly interface. No overbooking or mistakes made on your end. You can even know about guest preference before they come as well. Not to mention, it can also let prospective guests book online at all hours, meaning front desk employees can spend more time assisting checkins and focus on keeping the current guests happy. Now imagine if this could be done for multiple hotels whereby they act as franchises and you get a lot more options to choose from.

_Bon Voyage_ does all this and more. We let you connect with private event organizers and you can get access to a multitude of events across your city of choice. Each restaurant, room, event organizer is rated by you and this helps all prospective guests to know the pros and cons of each service. We even provide a list of some of the local tourist attractions that may interest you during your visit to the city.

## Mission Statement:

A project to create a database to view and manage bookings by various customers. It searches through all the hotels or properties and events in the locality that are registered in the system and returns the deals as per the customer requirements and date availability.

## Objective:

To make traveling an even more of a delightful experience, we will also store the details or profiles of the customers and once a booking is made the customer will get an option to view/match with other travelers staying in the same area or hotel during the same duration of stay. We will have the details of various hotels, restaurants, pubs in and around the city. We will also have details, like things to do around the city and store the information of event organizers to help customers to explore the city. 

We created the following tables:
- Hotels
- Rooms
- Bookings
- Room Bookings
- Customers
- Tourist Attractions
- Reviews
- Orders
- Restaurants
- Payment Methods
- Cities
- Event Organizers
- Address
- Booking Type

_Included with xls document (in the root), here are explainations about important tables. The project contains entertainment items as well such as restaurants and tourist attractions, hosts called Event Organizers would manage special events._

## Key Business Rules:

1. __Bookings__ are converted to __Order__ and so, _Order_ contains _BookingID_ as FK only **_AFTER_** the customer has paid for the booking.
2. __Order__ can also have some orders like ticket to some event etc. In this case, it will have the _reference (OrganizerId or HotelID)_ which tells us who provided the service.
3. Any person who uses our services has to be a registered customer ie no guests.
4. __Address__ has columns namely _CustomerID, HotelID or RestaurantID_ corresponding to whose address it is.

## Design Decisions:

| Entity Name | Why Entity is Included | How Entity is Related to Other Entities |
| ----------- | :--------------------: | :-------------------------------------: |
| Cities 	  | Since there would many different hotels with various locations in our system, we will set up a city table to represent the geographic information. | The primary key(PK) _CityID_ relates to *Hotels*, *Address*, *Restaurants* and *TouristAttractions* entities to tell us which city it belongs to. |
| Hotels | Each Hotel will be assigned a unique ID, and some detailed information such as Name and Contact Number and other basic descriptions. | Hotels’ PK _HotelID_ is a foreign key(FK) of *Rooms* which tells us which hotel the room belongs to. |
| Rooms | This entity will have all the information about the room such as ac/non-ac, room type, no. of beds, pricing, etc. | PK _RoomID_ is used as a FK in *RoomBookings*, *Bookings*, and *Reviews* to tell us if a room is booked or available, reviews and ratings about the room. |
| Customers | This stores the details of all the customers who uses the services. | PK _CustomerID_ is used as a FK in *Bookings* and *Reviews*. From *Bookings* we can extract the information of the customer who has made a booking. Customer can submit a review in the *Reviews* table to help other travelers. |
| Bookings | Bookings gives the information about the booking such as who has made the booking, when the booking was made, what was booked, no. of visitors, etc. | The PK _BookingID_ is a FK in *Orders* to tell us if a booking was completed and if the payment is made. |
| TouristAttractions |  This will have the details about places to visit, best time to visit and other relevant information |  |
| Restaurants | This will have details about the restaurant such as address, phone no., city located in etc. | PK _RestaurantID_ is used as FK in *Reviews* to allow users to review or rate a restaurant. |
| Reviews | Ratings and reviews always help fellow travelers. Reviews will contain details such as ratings and comments about all the hotels, restaurants and organizers. |  |
| EventOrganizers | It will have all the details of the organizers, events, prices etc. to make the travel easy and enjoyable. | PK _OrganizerID_ is a FK in *Bookings* and *Reviews*. Customers can book an event with an organizer and rate and review them as well, according to their experiences. |
| Address | It is used to store all the addresses of customers, hotels, restaurants, and organizers. | PK _AddressID_ is used as FK in *Customers*, *Restaurants*, *Orders*, *Organizers*, *TouristAttractions* and *Hotels* which stores all the contact information. |
| PaymentMethods | It tells us the type of the payment when a booking is made by a customer. | PK _PaymentMethodID_ is a FK in *Orders* to track a payment if the need be. |
| Orders | Orders will have all the details when a booking is confirmed and a payment is made. |  |
| BookingType | This tells us what is the type of booking such as a restaurant booking, hotel booking or an event booking. | _BookingTypeID_ is a FK in *Bookings* which stores all the information about a booking. |
| RoomBookings | This a look-up table that keeps track of the room bookings between a date interval. |  |

## Features

### Trigger, Data Encryption and Computed Columns

![cust1](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/img/cust1.jpg "Customer Table")

![cust2](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/img/cust2.jpg "Customer Table - Code snippets")

![cust3](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/img/cust3.jpg "Customer Table - Sample Data")

### Multi-table Views

![mtv1](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/img/mtv1.jpg "vw_EventOrganizerDetails")

![mtv2](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/img/mtv2.jpg "vw_HotelMaxBooking")

![mtv3](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/img/mtv3.jpg "Multi-table View Code snippets")

![mtv4](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/img/mtv4.jpg "Views on SQL Server")

![mtv5](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/img/mtv5.jpg "vw_EventOrganizerDetails")

![mtv6](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/img/mtv6.jpg "vw_HotelMaxBookings")

## Reports

All reports done in PowerBI:

![reports1](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/Reports/BonVoyage_Average_Rating_of_Restaurants.png "BonVoyage - Average Rating of Restaurants Report")

![reports2](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/Reports/BonVoyage_Average_Ratings_of_Organizers.png "BonVoyage - Average Ratings of Organizers Report")

![reports3](https://github.com/PrateekAdhikaree/BonVoyage/blob/master/Reports/BonVoyage_Places_of_Tourist_Attraction.png "BonVoyage - Places of Tourist Attractions Report")

_.pbix file can be found in <root>/Reports/_