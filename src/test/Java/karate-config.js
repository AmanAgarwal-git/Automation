function fn() {

  var config = 
  {
    "baseUrl": "https://restful-booker.herokuapp.com",
    "userName": "admin",
    "password" : "password123"
  };
 
  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 5000);
  return config;
}