Feature: Get booking details

Background: 
    * url baseUrl
    * configure headers = { 'cookie': '#(authToken)', 'accept': 'application/json', 'Content-Type': 'application/json' }
    * def bookingSchema =  read('classpath:resources/BookingDetailsSchema.json')

Scenario: Delete booking using the bookingId
    # Fetch booking details using the booking ID
    Given path '/booking/' + bookingId
    When method Get
    Then status 200
    And match response == '#object'
    And match response == bookingSchema