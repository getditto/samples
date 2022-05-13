package live.ditto.dittotesting

import org.junit.Assert.assertEquals
import org.junit.Test
import java.io.File

class ExampleDittoTest: DittoTestBase() {
    @Test
    fun twoDittos() {
        val ditto1 = getDitto(dependenciesWithCustomDirectory(File(getWorkDir(), "ditto1")))
        val ditto2 = getDitto(dependenciesWithCustomDirectory(File(getWorkDir(), "ditto2")))

        ditto1.tryStartSync()
        ditto2.tryStartSync()

        val coll1 = ditto1.store.collection("cars")
        val coll2 = ditto2.store.collection("cars")
        val docId = coll1.upsert(mapOf(
            "make" to "toyota",
            "mileage" to 160000
        ))
        val liveQuery = coll2.findByID(docId).observe { doc, event ->
            if (!event.isInitial) {
                assertEquals(doc!!["make"], "toyota")
                ditto1.stopSync()
                ditto2.stopSync()
            }
        }
    }
}
