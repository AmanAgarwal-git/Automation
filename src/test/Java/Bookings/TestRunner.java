package Bookings;

import com.intuit.karate.KarateOptions;
import com.intuit.karate.junit5.Karate;

@KarateOptions(tags = {"@Regression,E2E"} )
public class TestRunner {

    @Karate.Test
    Karate Booking_Features() {
        new Karate();
        return Karate.run()
        .feature("Flows/APIHealthCheck.feature")
        .feature("Flows/FetchAuthToken.feature")
        .feature("Flows/GetBookingIds.feature")
        .feature("Flows/GetBookingDetails.feature")
        .feature("Flows/CreateBooking.feature")
        .feature("Flows/UpdateBookings.feature")
        .feature("Flows/PartialUpdateBooking.feature")
        .feature("Flows/DeleteExistingBooking.feature")
        .feature("Flows/EndToEndBookingTest.feature")
        .relativeTo(getClass());
    }
}