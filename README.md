# Booking API Test Automation - Karate Framework

This project contains test automation scripts for testing the **Booking API** using the Karate testing framework. 
The tests cover various booking functionalities such as creating, updating, retrieving and deleting bookings through the API.

## Table of Contents

- [Project Overview](#project-overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running Tests](#running-tests)
- [Feature Files](#feature-files)
- [Configuration](#configuration)
- [Reports](#reports)

## Project Overview

The project is designed to automate the testing of booking-related API endpoints using the Karate framework. 
It validates the following features of the **Booking API**:
- Creating a new booking
- Fetch the booking list
- Retrieving booking details
- Updating existing bookings
- Partially update the booking
- Deleting a booking

This ensures the API works as expected and conforms to the desired specifications.

## Project Structure

src
├── test
│   ├── java
│   │     └── Bookings
│   │     │        └── CommonFeatures
│   │     │        └── Flows
│   │     │        └── TestRunner.java
│   │     └── karate.config.js
│   │     └──logback-test.xml
│   ├── resources
│   │   └── BookingDetailsSchema.json
│   │   └── CreateBookingSchema.json
│   └── utils
│       └── bookings.csv
├── booking.feature
└── README.md

## Prerequisites

Before running the tests, make sure you have the following installed:
	Java JDK
	Maven

## Installation

1. Clone this repository to your local machine:
	git clone [https://github.com/AmanAgarwal-git/Automation.git]
	cd Automation

2. Install dependencies by running:
	mvn clean install
	
## Running Tests
	mvn test -Dkarate.options="--tags @Regression"
	
## Feature-Files
	APIHealthCheck.feature
	FetchAuthToken.feature
	CreateBooking.feature
	GetBookingIds.feature
	GetBookingDetails.feature
	UpdateBooking.feature
	PartialUpdateBooking.feature
	DeleteExistingBooking.feature
	EndtoEndBookingTest.feature
	
## Configuration
	function fn() {

  var config = 
  {
    "baseUrl": "https://restful-booker.herokuapp.com",
    "userName": "admin",
    "password" : "password123"
  };
 
  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 5000);
  return config;
}

## Karate-Reports

After running the tests, a detailed report will be generated in the target/surefire-reports/ folder. 
You can view the test results in HTML format by opening the karate-summary.html file located there.
		
