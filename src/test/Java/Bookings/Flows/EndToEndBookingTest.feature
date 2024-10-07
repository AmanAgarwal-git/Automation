
@E2E
Feature: E2E Booking API Flow

Background: 
    * url baseUrl
    * def createToken = callonce read('classpath:Bookings/CommonFeatures/TokenGeneration.feature') 
    * def authToken = "token = " + createToken.response.token
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json','cookie': '#(authToken)' }
    * def bookingSchema =  read('classpath:resources/BookingDetailsSchema.json')
    
Scenario: E2E flow of creating, retrieving, updating, and deleting a booking
    # Call the feature to create a new booking and store the booking ID
    * json bookingSchema = read('classpath:resources/CreateBookingSchema.json')
    * def bookingsData = read('classpath:utils/bookings.csv')
    * def randomIndex = Math.floor(Math.random() * bookingsData.length)
    * def selectedBooking = bookingsData[randomIndex]
    * def bookingDates = { 'checkin': '#(selectedBooking.checkIn)', 'checkout': '#(selectedBooking.checkOut)' }
    * def bookingFields = {'firstname': '#(selectedBooking.firstname)','lastname': '#(selectedBooking.lastname)','bookingdates': '#(bookingDates)','depositpaid':true, 'totalprice':100,'additionalneeds':'Lunch'}
    * def createBooking = karate.merge(bookingSchema,bookingFields)
    
    # Step 1: Perfom API health check
    Given path '/ping'
    When method GET
    Then status 201
    * karate.log('Ping HealthCheck Response: ', response)
    And match response == 'Created'

    # Step 2: Create a new booking
    Given path '/booking'
    And request createBooking
    When method Post
    Then status 200
    And match response == '#object'
    And match response.bookingid == '#number'
    And match response.booking == createBooking
    * def bookingId = response.bookingid
    * karate.log('Booking created with ID:', bookingId)

    # Step 3: Retrieve the created booking
    Given path '/booking/' + bookingId
    When method Get
    Then status 200
    And match response == createBooking

    # Step 4: Update the booking (partial update using PATCH)
    Given path '/booking/' + bookingId
    * def updateBody = 
    """
    {
        "firstname": "UpdatedName",
        "lastname": "UpdatedLastName"
    }
    """
    And request updateBody
    When method Patch
    Then status 200
    And match response.firstname == 'UpdatedName'
    And match response.lastname == 'UpdatedLastName'

    # Step 5 Retrieve the updated booking
    Given path '/booking/' + bookingId
    When method Get
    Then status 200
    And match response.firstname == 'UpdatedName'
    And match response.lastname == 'UpdatedLastName'
    And match response.totalprice == 100
    And match response.depositpaid == true
    And match response.bookingdates == bookingDates
    And match response.additionalneeds == 'Lunch'

    # Step 6: Delete the booking
    Given path '/booking/' + bookingId
    When method Delete
    Then status 201
    And match response == 'Created'

    # Step 7: Verify the booking no longer exists
    Given path '/booking/' + bookingId
    When method Get
    Then status 404
    And match response == 'Not Found'