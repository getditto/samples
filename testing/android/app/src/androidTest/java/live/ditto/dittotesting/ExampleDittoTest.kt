package live.ditto.dittotesting

import live.ditto.dittotests.DittoTestBase
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
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
        val liveQuery = coll2.findAll().observe { docs, event ->
            assertEquals(docs.count(), 1)
        }
        coll1.upsert(mapOf(
            "make" to "toyota",
            "mileage" to 160000
        ))
    }
}
