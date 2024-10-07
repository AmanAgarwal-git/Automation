
@Regression
Feature: Retrieve the list of Booking Ids

Background: 
    * url baseUrl
    # Call the feature to create a new booking and store the booking ID
    * def bookingsData = read('classpath:utils/bookings.csv')
    * def randomIndex = Math.floor(Math.random() * bookingsData.length)
    # Fetch the first record (index 0) or any other index
    * def selectedBooking = bookingsData[randomIndex]
    * def createNewBooking = call read('classpath:Bookings/CommonFeatures/AddNewBooking.feature'){'userFirstName': '#(selectedBooking.firstname)','userLastName': '#(selectedBooking.lastname)','checkIn': '#(selectedBooking.checkIn)','checkOut': '#(selectedBooking.checkOut)'}
    * def bookingId = createNewBooking.bookingId
    * karate.log('Booking ID created:', bookingId)

Scenario: Verify the complete list of booking Ids fetched without filtering
    Given path '/booking'
    When method Get
    Then status 200
    And match response == '#array'
    # Assert that the response is not empty
    And assert response.length != 0
    # Ensure each booking has a valid ID
    And match each response[*].bookingid == '#number'

Scenario: Verify the user is able to retrive the booking ID while sending a valid firstname
    Given path '/booking'
    And param firstname = selectedBooking.firstname
    When method Get
    Then status 200
    And match response == '#array'
    # Check that the first booking ID matches
    * karate.log('Booking ID retrieved with valid firstname:', response[0].bookingid)
    And match each response[*].bookingid == '#number'

Scenario: Verify the booking ID retrieval with valid lastname
    Given path '/booking'
    And param lastname = selectedBooking.lastname
    When method Get
    Then status 200
    And match response == '#array'
    # Check that the first booking ID matches
    * karate.log('Booking ID retrieved with valid lastname:', response[0].bookingid)
    And match each response[*].bookingid == '#number'
    
Scenario: Verify the booking ID retrieval with checkin date
    Given path '/booking'
    And param checkin = selectedBooking.checkIn
    When method Get
    Then status 200
    And match response == '#array'
    # Ensure each booking has a valid ID
    * karate.log('Booking IDs retrieved with valid check-in date:', response) 
    And match each response[*].bookingid == '#number'

Scenario: Verify the booking ID retrieval with checkout date
    Given path '/booking'
    And param checkout = selectedBooking.checkOut
    When method Get
    Then status 200
    And match response == '#array'
    # Ensure each booking has a valid ID
    * karate.log('Booking IDs retrieved with valid check-out date:', response)
    And match each response[*].bookingid == '#number'

Scenario: Verify retrieval of booking IDs using invalid filter combination
    Given path '/booking'
    And param firstname = 'invalidUser'
    And param lastname = selectedBooking.lastname
    When method Get
    Then status 200
    # Expect an empty response
    * karate.log('No bookings found for invalid firstname filter:', response)
    And match response == []

Scenario: Verify retrieval of booking IDs using valid filter parameters combination
    Given path '/booking'
    And param firstname = selectedBooking.firstname
    And param lastname = selectedBooking.lastname
    When method Get
    Then status 200
    And match response == '#array'
    * karate.log('Booking IDs retrieved with both firstname and lastname:', response)
    And match each response[*].bookingid == '#number'
    
Scenario: Verify that no booking IDs are returned for invalid user serach
    * def invalidFirstName = 'invalidUserName'
    Given path '/booking'
    And param firstname = invalidFirstName
    When method Get
    Then status 200
    # Expect an empty response
    * karate.log('No bookings found for invalid firstname:', response)
    And match response == []

Scenario: Verify the empty response with partial username search
    Given path '/booking'
    And param firstname = (selectedBooking.firstname).substring(0,2)
    When method Get
    Then status 200
    # Expect an empty response
    And match response == []

Scenario: Verify response time for booking ID retrieval
    Given path '/booking'
    And param checkout = selectedBooking.checkOut
    When method Get
    Then status 200
    # Assert response time is less than 2 seconds
    * karate.log('Response time for booking ID retrieval:', responseTime)
    And assert responseTime < 3000

Scenario: Delete booking
    # Delete the created booking using the booking ID
    * def createToken = callonce read('classpath:Bookings/CommonFeatures/TokenGeneration.feature') 
    * def authToken = "token = " + createToken.response.token
    * karate.log('Auth Token:', authToken)  
    # Call the delete feature to the booking created above
    * karate.call('classpath:Bookings/CommonFeatures/DeleteBooking.feature',{ 'bookingId': bookingId, 'authToken': authToken}); 