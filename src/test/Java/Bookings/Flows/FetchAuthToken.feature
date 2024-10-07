
@Regression
Feature: Authentication Token Generation

Background: 
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json' }

    # Define the token request structure
    * def createTokenRequest =
    """
    {
        "username" : "#string",
        "password" : "#string"
    }
    """

Scenario Outline: Verify authentication for <scenarioName>
    * set createTokenRequest.username = <userName>
    * set createTokenRequest.password = <password>
    # Log the request payload for debugging
    * karate.log('Token request payload:', createTokenRequest)  
    Given path '/auth'
    And request createTokenRequest
    When method Post
    Then status 200
    And match response.token == <token>
    And match response.reason == <reason>

    Examples:
        | scenarioName                          | userName      | password         | token         | reason           |
        | 'Valid credentials'                   | 'admin'       | 'password123'    | '#present'    | '#notpresent'    |
        | 'Invalid username'                    |'invalidadmin' | 'password123'    | '#notpresent' | 'Bad credentials'|
        | 'Missing username'                    | null          | 'password123'    | '#notpresent' | 'Bad credentials'|
        | 'Missing password'                    |'admin'        | null             | '#notpresent' | 'Bad credentials'|
        | 'Empty request body'                  | null          | null             | '#notpresent' | 'Bad credentials'|
    
Scenario:  Verify response time for authentication 
    * set createTokenRequest.username = userName
    * set createTokenRequest.password = password
    # Log the request payload for debugging
    * karate.log('Token request payload for response time check:', createTokenRequest)
    Given path '/auth'
    And request createTokenRequest
    When method Post
    Then status 200
    And assert responseTime < 3000