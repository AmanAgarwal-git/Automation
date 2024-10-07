@Regression
Feature: Booking Details Retrieval API Tests

Background: 
    * url baseUrl
    # Call the feature to create a new booking and store the booking ID
    * def bookingsData = read('classpath:utils/bookings.csv')
    * def randomIndex = Math.floor(Math.random() * bookingsData.length)
    # Fetch the first record (index 0) or any other index
    * def selectedBooking = bookingsData[randomIndex]
    * def createNewBooking = call read('classpath:Bookings/CommonFeatures/AddNewBooking.feature'){'userFirstName': '#(selectedBooking.firstname)','userLastName': '#(selectedBooking.lastname)','checkIn': '#(selectedBooking.checkIn)','checkOut': '#(selectedBooking.checkOut)'}
    * def bookingId = createNewBooking.bookingId

    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json' }
    * def bookingDetails =  read('classpath:resources/BookingDetailsSchema.json')

Scenario: Verify successful retrieval of booking details by ID
    # Fetch booking details using the booking ID
    Given path '/booking/' + bookingId
    When method Get
    Then status 200
    And match response == '#object'
    And match response == bookingDetails
    # Log the retrieved booking details for verification
    * karate.log('Successfully retrieved booking details for ID:', bookingId, 'Response:', response)

Scenario: Verify error response for invalid booking ID
    # Fetch booking details using an invalid booking ID
    * def invalidBookingId = 99999
    Given path '/booking/' + invalidBookingId
    When method Get
    Then status 404
    And match response == 'Not Found'
   # Log the error response for validation
   * karate.log('Received error response for invalid booking ID:', 99999, 'Response:', response)

Scenario: Verify the user specific fields inside the booking details response
    # Fetch booking details and validate specific fields
    Given path '/booking/' + bookingId
    When method Get
    Then status 200
    And match response == '#object'
    And match response.firstname == selectedBooking.firstname
    And match response.lastname == selectedBooking.lastname
    And match response.bookingdates.checkin == selectedBooking.checkIn
    And match response.bookingdates.checkout == selectedBooking.checkOut
    # Log the validated fields for confirmation
    * karate.log('Validated fields for booking ID:', bookingId, 'Firstname:', response.firstname, 'Lastname:', response.lastname)

Scenario: Verify response time for booking details retrieval
    # Assert the response time is within acceptable limits
    Given path '/booking/' + bookingId
    When method Get
    Then status 200
    And assert responseTime < 3000
    # Log the response time for monitoring
    * karate.log('Response time for retrieving booking ID', bookingId, 'is:', responseTime, 'ms')

Scenario: Delete booking
    # Generate a token for authentication required for deletion
    * def createToken = callonce read('classpath:Bookings/CommonFeatures/TokenGeneration.feature') 
    * def authToken = "token = " + createToken.response.token
    # Call the delete feature to remove the booking
    * karate.call('classpath:Bookings/CommonFeatures/DeleteBooking.feature',{ 'bookingId': bookingId, 'authToken': authToken}); 

    # Log the action of deletion
    * karate.log('Booking ID', bookingId, 'has been successfully deleted using token:', authToken)