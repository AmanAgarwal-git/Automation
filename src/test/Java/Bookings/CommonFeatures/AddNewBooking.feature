Feature: Booking creation

Background: 
    * url baseUrl
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json' }

    * def bookingRequest =
    """
    {
        "firstname" : "#(userFirstName)",
        "lastname" : "#(userLastName)",
        "totalprice" : 111,
        "depositpaid" : true,
        "bookingdates" : {
            "checkin" : "#(checkIn)",
            "checkout" : "#(checkOut)"
        },
        "additionalneeds" : "Breakfast"
    }
    """

Scenario: Create new booking using the user details
    Given path '/booking'
    And request bookingRequest
    When method Post
    Then status 200
    * def bookingId = response.bookingid