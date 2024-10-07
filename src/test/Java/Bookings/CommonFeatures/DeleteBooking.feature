Feature: Delete booking

Background: 
    * url baseUrl
    * configure headers = { 'cookie': '#(authToken)', 'accept': 'application/json', 'Content-Type': 'application/json' }

Scenario: Delete booking using the bookingId
    Given path '/booking/'+bookingId
    When method Delete
    Then status 201
    And match response == 'Created'