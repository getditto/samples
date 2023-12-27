package live.ditto.dittotesting

import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Test
import java.io.File
import java.util.concurrent.CountDownLatch

class ExampleDittoTest: DittoTestBase() {
    @Test
    fun twoDittos() = runBlocking {
        val ditto1 = getDitto(dependenciesWithCustomDirectory(File(getWorkDir(), "ditto1")))
        val ditto2 = getDitto(dependenciesWithCustomDirectory(File(getWorkDir(), "ditto2")))

        ditto1.startSync()
        ditto2.startSync()


        val collection = "cars"

        // Inserting a car into 'ditto1' store
        val car = mapOf("make" to "toyota", "mileage" to 160000)
        ditto1.store.execute(
            "INSERT INTO $collection DOCUMENTS (:car)",
            mapOf("car" to car)
        )

        val selectQuery = "SELECT * FROM $collection"

        // Registering a subscription from 'ditto2'
        ditto2.sync.registerSubscription(selectQuery)


        val count = CountDownLatch(1)
        var make = ""

        // Registering a result observer on 'ditto2' store
        ditto2.store.registerObserver(selectQuery) { result ->
            if (result.items.isNotEmpty()) {
                make = result.items.first().value["make"].toString()
                count.countDown()

                ditto1.stopSync()
                ditto2.stopSync()
            }
        }

        count.await()
        assertEquals(make, "toyota")
    }
}
