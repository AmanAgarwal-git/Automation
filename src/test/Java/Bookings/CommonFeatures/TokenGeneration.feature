Feature: Authentication token generation

Background: 
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json' }
    * def createTokenRequest =
    """
    {
        "username" : "#(userName)",
        "password" : "#(password)"
    }
    """

Scenario: Authentication token generation
    Given path '/auth'
    And request createTokenRequest
    When method Post
    Then status 200