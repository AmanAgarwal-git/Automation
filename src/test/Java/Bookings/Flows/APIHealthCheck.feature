@Regression
Feature: Ping HealthCheck API Tests

Background: 
    * url baseUrl
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json' }

Scenario: Verify Successful Response if the API healthcheck is created
    Given path '/ping'
    When method GET
    Then status 201
    * karate.log('Ping HealthCheck Response: ', response)
    And match response == 'Created'

Scenario: Verify response Headers from the /ping Endpoint
    Given path '/ping'
    When method GET
    Then status 201
    * karate.log('Response Headers: ', responseHeaders)
    And match responseHeaders['Content-Type'][0] == 'text/plain; charset=utf-8'
    And match responseHeaders['X-Powered-By'][0] == 'Express'
    And match responseHeaders['Etag'][0] == 'W/"7-rM9AyJuqT6iOan/xHh+AW+7K/T8"'
    And match responseHeaders['Server'][0] == 'Cowboy'

Scenario: Verify the response time for the healthcheck API
    Given path '/ping'
    When method GET
    Then status 201
    * karate.log('Response Time: ', responseTime)
    And assert responseTime < 3000