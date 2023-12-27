package live.ditto.dittotesting

import org.junit.Assert.assertEquals
import org.junit.Test
import java.io.File
import java.util.concurrent.CountDownLatch

class ExampleDittoTest: DittoTestBase() {
    @Test
    fun twoDittos() {
        val ditto1 = getDitto(dependenciesWithCustomDirectory(File(getWorkDir(), "ditto1")))
        val ditto2 = getDitto(dependenciesWithCustomDirectory(File(getWorkDir(), "ditto2")))

        ditto1.startSync()
        ditto2.startSync()

        val coll1 = ditto1.store.collection("cars")
        val coll2 = ditto2.store.collection("cars")
        val docId = coll1.upsert(mapOf(
            "make" to "toyota",
            "mileage" to 160000
        ))
        coll2.findById(docId).subscribe()

        val count = CountDownLatch(1)
        var make = ""

        coll2.findById(docId).observeLocal { doc, event ->
            if (!event.isInitial) {
                doc?.let {
                    make = doc["make"].value.toString()
                    count.countDown()

                    ditto1.stopSync()
                    ditto2.stopSync()
                }
            }
        }

        count.await()
        assertEquals(make, "toyota")
    }
}
