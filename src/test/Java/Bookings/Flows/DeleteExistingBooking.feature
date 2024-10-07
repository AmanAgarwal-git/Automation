
@Regression
Feature: Delete Booking API calls

Background: 
    * url baseUrl
    # Generate an authentication token and configure headers
    * def createToken = callonce read('classpath:Bookings/CommonFeatures/TokenGeneration.feature') 
    * def authToken = "token = " + createToken.response.token
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json','cookie': '#(authToken)' }

    # Read the booking data from the CSV file
    # Call the feature to create a new booking and store the booking ID
    * def bookingsData = read('classpath:utils/bookings.csv')
    * def randomIndex = Math.floor(Math.random() * bookingsData.length)

    # Fetch the first record (index 0) or any other index
    * def selectedBooking = bookingsData[randomIndex]
    * karate.log('Selected booking:', selectedBooking)
    * def createNewBooking = call read('classpath:Bookings/CommonFeatures/AddNewBooking.feature'){'userFirstName': '#(selectedBooking.firstname)','userLastName': '#(selectedBooking.lastname)','checkIn': '#(selectedBooking.checkIn)','checkOut': '#(selectedBooking.checkOut)'}
    * def bookingId = createNewBooking.bookingId
    * karate.log('New booking created with ID:', bookingId)

Scenario: Verify the user can successfully delete an existing booking
    Given path '/booking/' + bookingId
    When method Delete
    Then status 201
    # Validate the update booking details in the response
    And match response == 'Created'
    * karate.log('Booking successfully deleted, ID:', bookingId)

Scenario: Verify the error response when attempting to delete without auth token
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json' }
    Given path '/booking/' + bookingId
    When method Delete
    Then status 403
    And match response == 'Forbidden'
    * karate.log('Deletion failed due to missing auth token, status:', response)

Scenario: Verify the delete functionality when booking ID does not exist
    Given path '/booking/' + 9999
    When method Delete
    Then status 405
    And match response == 'Method Not Allowed'
    * karate.log('Deletion failed due to missing booking ID, status:', response)

Scenario: Verify the delete functionality when no booking ID is provided
    Given path '/booking/'
    When method Delete
    Then status 404
    And match response == 'Not Found'
    * karate.log('Deletion failed due to missing booking ID, status:', response)

Scenario: Verify multiple delete calls for the same booking
    Given path '/booking/' + bookingId
    When method Delete
    Then status 201
    # Validate the update booking details in the response
    And match response == 'Created'
    * karate.log('First delete call successful, booking ID:', bookingId)

    Given path '/booking/' + bookingId
    When method Delete
    Then status 405
    And match response == 'Method Not Allowed'
    * karate.log('Second delete call failed as booking was already deleted, status:', response)

Scenario: Verify the delete functionality with an invalid token
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json','cookie': 'invalidToken' }
    Given path '/booking/' + bookingId
    When method Delete
    Then status 403
    And match response == 'Forbidden'
    * karate.log('Deletion failed due to invalid token, status:', response)