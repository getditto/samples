package live.ditto.dittotesting

import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.ext.junit.runners.AndroidJUnit4
import live.ditto.Ditto
import live.ditto.DittoDependencies
import live.ditto.DittoIdentity
import live.ditto.dittotests.DittoTestBase

import org.junit.Test
import org.junit.runner.RunWith

import org.junit.Assert.*

class ExampleDittoTest: DittoTestBase() {
    @Test
    fun twoDittos() {
        val ditto1 = getDitto(dependencies)
        val ditto2 = getDitto(dependencies)

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
