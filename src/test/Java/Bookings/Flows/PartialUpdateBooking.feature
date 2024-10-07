@Regression
Feature: Update partial fields for an existing booking

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
    * def initialBookingDetails = fetchBookingDetails.response

Scenario: Verify that the user can successfully update the booking partially
    * def requestBody = 
    """
    {
        'firstname': 'Test'
    }
    """
    Given path '/booking/' + bookingId
    And request requestBody
    When method Patch
    Then status 200
    # Validate the response after the update, ensuring other fields remain unchanged
    * karate.log('Partial update successful for booking ID:', bookingId)
    And match response == '#object'
    And match response.firstname == 'Test'
    And match response.lastname == initialBookingDetails.lastname
    And match response.totalprice == initialBookingDetails.totalprice
    And match response.depositpaid == initialBookingDetails.depositpaid
    And match response.bookingdates == initialBookingDetails.bookingdates
    And match response.additionalneeds == initialBookingDetails.additionalneeds
    
Scenario: Verify the partial booking update functionality without passing the auth token
    * def requestBody = {}
    # Remove the auth token to simulate an unauthorized request
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json' }

    Given path '/booking/' + bookingId
    And request requestBody
    When method Patch
    Then status 403
    And match response == 'Forbidden'
    * karate.log('Update failed due to missing auth token for booking ID:', bookingId)

Scenario: Verify partial update flow if the booking ID doesn't exist
    * def requestBody = 
    """
    {
        'lastname': 'Test'
    }
    """   
    Given path '/booking/' + 9999
    And request requestBody
    When method Patch
    Then status 405
    And match response == 'Method Not Allowed'
    * karate.log('Update failed for non-existing booking ID')

Scenario: Verify the update flow without sending the request body
    * def requestBody = {}

    Given path '/booking/' + bookingId
    And request requestBody
    When method Patch
    Then status 200
    # Validate no changes were made and the response matches the initial booking details
    And match response == '#object'
    And match response.firstname == initialBookingDetails.firstname
    And match response.lastname == initialBookingDetails.lastname
    And match response.totalprice == initialBookingDetails.totalprice
    And match response.depositpaid == initialBookingDetails.depositpaid
    And match response.bookingdates == initialBookingDetails.bookingdates
    And match response.additionalneeds == initialBookingDetails.additionalneeds

Scenario: Verify the update flow by sending non-existing fields
    * def updatedBookingDates = {'checkin': "2024-06-09", 'checkout': "2024-06-15",}
    * def requestBody = 
    """
    {
        "bookingdates" : '#(updatedBookingDates)',
        "dateofbirth" : "2000-05-10"
    }
    """
    Given path '/booking/' + bookingId
    And request requestBody
    When method Patch
    Then status 200
    # Validate the response for existing fields and ensure non-existing fields are ignored    
    And match response == '#object'
    And match response.firstname == initialBookingDetails.firstname
    And match response.lastname == initialBookingDetails.lastname
    And match response.totalprice == initialBookingDetails.totalprice
    And match response.depositpaid == initialBookingDetails.depositpaid
    And match response.bookingdates == updatedBookingDates
    And match response.additionalneeds == initialBookingDetails.additionalneeds
    And match response.dateofbirth == '#notpresent'
    * karate.log('Booking updated successfully while ignoring non-existing fields for booking ID:', bookingId)

Scenario: Verify partial booking update functionality by sending an invalid token
    * def requestBody = {}
    # Use an invalid token to simulate unauthorized access
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json','cookie': 'invalidToken' }

    Given path '/booking/' + bookingId
    And request requestBody
    When method Patch
    Then status 403
    And match response == 'Forbidden'
    * karate.log('Update failed due to invalid token for booking ID:', bookingId)