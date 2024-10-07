@Regression
Feature: Update the existing bookings details

Background: 
    * url baseUrl
     # Generate authentication token and configure headers
    * def createToken = callonce read('classpath:Bookings/CommonFeatures/TokenGeneration.feature') 
    * def authToken = "token = " + createToken.response.token
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json','cookie': '#(authToken)' }
    * def bookingSchema =  read('classpath:resources/BookingDetailsSchema.json')
    
    # Call the feature to create a new booking and store the booking ID
    * def bookingsData = read('classpath:utils/bookings.csv')
    * def randomIndex = Math.floor(Math.random() * bookingsData.length)
    * def selectedBooking = bookingsData[randomIndex]
    * karate.log('Selected booking data:', selectedBooking)

    * def createNewBooking = call read('classpath:Bookings/CommonFeatures/AddNewBooking.feature'){'userFirstName': '#(selectedBooking.firstname)','userLastName': '#(selectedBooking.lastname)','checkIn': '#(selectedBooking.checkIn)','checkOut': '#(selectedBooking.checkOut)'}
    * def bookingId = createNewBooking.bookingId
    * karate.log('Booking ID created:', bookingId)

    * def fetchBookingDetails = call read('classpath:Bookings/CommonFeatures/BookingDetails.feature'){'bookingId': '#(bookingId)'}
    * def bookingDetails = fetchBookingDetails.response

Scenario: Verify that the user is able to successfully update the Booking
    * def updatedFirstName = 'TestUser'
    * set bookingDetails.firstname = updatedFirstName
    * karate.log('Updated booking details:', bookingDetails)

    Given path '/booking/' + bookingId
    And request bookingDetails
    When method Put
    Then status 200
    # Validate the update booking details in the response
    And match response == '#object'
    And match response == bookingSchema
    And match response.firstname == updatedFirstName
    * karate.log('Booking updated successfully with ID:', bookingId)

Scenario: Verify the booking update functionality without passing the auth token
    * def updatedFirstName = 'TestUser'
    * set bookingDetails.firstname = updatedFirstName
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json' }

    # Remove auth token to simulate missing token scenario
    Given path '/booking/' + bookingId
    And request bookingDetails
    When method Put
    Then status 403
    And match response == 'Forbidden'
    * karate.log('Update failed due to missing auth token, status:', response)

Scenario: Verify booking update with non-existing booking ID
    * def updatedFirstName = 'TestUser'
    * set bookingDetails.firstname = updatedFirstName

    Given path '/booking/' + 9999
    And request bookingDetails
    When method Put
    Then status 405
    And match response == 'Method Not Allowed'
    * karate.log('Update failed for non-existing booking ID, status:', response)

Scenario: Verify the update flow without passing the required fields
    * remove bookingDetails.firstname
    * remove bookingDetails.lastname
    * karate.log('Booking details after removing required fields:', bookingDetails)

    Given path '/booking/' + bookingId
    And request bookingDetails
    When method Put
    Then status 400
    And match response == 'Bad Request'
    * karate.log('Update failed due to missing required fields, status:', response)

Scenario: Verify the update flow by skipping the optional fields 
    * def updatedFirstName = 'TestUser'
    * set bookingDetails.firstname = updatedFirstName
    * remove bookingDetails.additionalneeds
    * karate.log('Booking details after removing optional fields:', bookingDetails)

    Given path '/booking/' + bookingId
    And request bookingDetails
    When method Put
    Then status 200
    # Validate the update booking details in the response
    And match response == '#object'
    And match response == bookingSchema
    And match response.firstname == updatedFirstName
    * karate.log('Booking updated successfully without optional fields, response:', response)

Scenario: Verify the booking update functionality with invalid token
    * def updatedFirstName = 'TestUser'
    * set bookingDetails.firstname = updatedFirstName
     
    # Use an invalid token to simulate an unauthorized request
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json','cookie': 'invalidToken' }

    Given path '/booking/' + bookingId
    And request bookingDetails
    When method Put
    Then status 403
    And match response == 'Forbidden'
    * karate.log('Update failed due to invalid token, status:', response)