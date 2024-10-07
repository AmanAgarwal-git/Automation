
@Regression
Feature: Booking Creation API Tests

Background: 
    * url baseUrl
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json' }
    # Fetch the booking schema
    * json bookingSchema = read('classpath:resources/CreateBookingSchema.json')
    # Call the feature to create a new booking and store the booking ID
    * def bookingsData = read('classpath:utils/bookings.csv')
    * def randomIndex = Math.floor(Math.random() * bookingsData.length)
    * def selectedBooking = bookingsData[randomIndex]
    * def bookingDates = { 'checkin': '#(selectedBooking.checkIn)', 'checkout': '#(selectedBooking.checkOut)' }
    * def bookingFields = {'firstname': '#(selectedBooking.firstname)','lastname': '#(selectedBooking.lastname)','bookingdates': '#(bookingDates)','depositpaid':true, 'totalprice':100,'additionalneeds':'Lunch'}
    * def createBooking = karate.merge(bookingSchema,bookingFields)

Scenario Outline: Verify successful booking creation with different valid data
    * def bookingDates = { checkin: '<checkinDate>', checkout: '<checkoutDate>' }
    * set bookingSchema.firstname = '<firstName>'
    * set bookingSchema.lastname = '<lastName>'
    * set bookingSchema.totalprice = <totalPrice>
    * set bookingSchema.depositpaid = <depositPaid>
    * set bookingSchema.bookingdates = bookingDates
    * set bookingSchema.additionalneeds = '<additionalNeeds>'
    * def requestBody = bookingSchema

    # Log the request payload for debugging
    * karate.log('Request Body for booking creation:', requestBody)
    Given path '/booking'
    And request requestBody
    When method Post
    Then status 200
    # Validate the booking details in the response
    And match response == '#object'
    And match response.bookingid == '#number'
    And match response.booking.firstname == '<firstName>'
    And match response.booking.lastname == '<lastName>'
    And match response.booking.totalprice == <totalPrice>
    And match response.booking.bookingdates.checkin == '<checkinDate>'
    And match response.booking.bookingdates.checkout == '<checkoutDate>'
    And match response.booking.additionalneeds == '<additionalNeeds>'

Examples:
    | firstName | lastName | totalPrice | depositPaid | checkinDate | checkoutDate | additionalNeeds |
    | John      | Doe      | 150        | true        | 2024-09-10  | 2024-09-15   | Breakfast        |
    | Alice     | Smith    | 200        | false       | 2024-11-01  | 2024-11-05   | Lunch            |
    | Bob       | Lee      | 120        | true        | 2024-10-01  | 2024-10-05   | Dinner           |

Scenario: Verify response when required fields are missing
    * def requestBody = createBooking
    # Remove the first name to test missing field
    * remove requestBody.firstname
    # Log the modified request body
    * karate.log('Request Body with missing firstname:', requestBody) 

    Given path '/booking'
    And request requestBody
    When method Post
    Then status 500
    
Scenario: Verify response when invalid data types are provided
    * def requestBody = createBooking
    # Set total price to an invalid type (string)
    * set requestBody.totalprice = "100"
    * karate.log('Request Body with invalid totalprice:', requestBody)

    Given path '/booking'
    And request requestBody
    When method Post
    Then status 200
    And match response == '#object'
    And match response.bookingid == '#number'
    * set createBooking.totalprice = 100
    And match response.booking == createBooking

Scenario: Verify booking creation with missing optional fields
    * def requestBody = createBooking
    # Remove additional needs to test optional field handling
    * remove requestBody.additionalneeds
    * karate.log('Request Body without additional needs:', requestBody)

    Given path '/booking'
    And request requestBody
    When method Post
    Then status 200
    And match response == '#object'
    And match response.bookingid == '#number'
    And match response.booking'.additionalneeds == '#notpresent'
    And match response.booking == createBooking

Scenario: Verify booking creation with invalid date format
    * def bookingDatesUpdated = { checkin: '10-01-2024', checkout: '10-05-2024' }
    * def requestBody = createBooking
    # Set invalid booking dates
    * set requestBody.bookingdates = bookingDatesUpdated   // MM-DD-YYYY
    * karate.log('Request Body with invalid date format:', requestBody)
    Given path '/booking'
    And request requestBody
    When method Post
    Then status 200
    And match response == '#object'
    And match response.bookingid == '#number'
    * set createBooking.bookingdates = {"checkin":"2024-10-01","checkout":"2024-10-05"}
    And match response.booking == createBooking

Scenario: Verify response time for the new booking creation
    * def requestBody = createBooking
    * karate.log('Request Body for response time check:', requestBody)

    Given path '/booking'
    And request requestBody
    When method Post
    Then status 200
    # Verify response time is less than 3000 ms
    And assert responseTime < 3000