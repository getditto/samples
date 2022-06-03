package live.ditto.myapplication

import android.os.Bundle
import com.google.android.material.snackbar.Snackbar
import androidx.appcompat.app.AppCompatActivity
import androidx.navigation.findNavController
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.navigateUp
import androidx.navigation.ui.setupActionBarWithNavController
import android.view.Menu
import android.view.MenuItem
import live.ditto.myapplication.databinding.ActivityMainBinding

import live.ditto.*
import live.ditto.transports.*
import live.ditto.android.DefaultAndroidDittoDependencies

class MainActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var viewAdapter: RecyclerView.Adapter<*>
    private lateinit var viewManager: RecyclerView.LayoutManager

    private var ditto: Ditto? = null
    private var collection: DittoCollection? = null
    private var liveQuery: DittoObserver? = null

    private lateinit var appBarConfiguration: AppBarConfiguration
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        setSupportActionBar(toolbar)

        // Setup the layout
        viewManager = LinearLayoutManager(this)
        val peersAdapter = PeersAdapter()
        viewAdapter = peersAdapter

        recyclerView = findViewById<RecyclerView>(R.id.recyclerView).apply {
            setHasFixedSize(true)
            layoutManager = viewManager
            adapter = viewAdapter
        }

        recyclerView.addItemDecoration(DividerItemDecoration(this, DividerItemDecoration.VERTICAL))

        // Create an instance of Ditto
        val androidDependencies = DefaultAndroidDittoDependencies(applicationContext)
        val ditto = Ditto(androidDependencies, DittoIdentity.OfflinePlayground(androidDependencies, "f2b5f038-6d00-433a-9176-6e84011da136"))
        ditto.setOfflineOnlyLicenseToken("o2d1c2VyX2lkbnJhZUBkaXR0by5saXZlZmV4cGlyeXgYMjAyMi0wNi0xMlQwNjo1OTo1OS45OTlaaXNpZ25hdHVyZXhYWXFKTUJFR3k0OFlqMHhpTDRsbDcvNEljRjJwVFJIRVRNdWJVTHIvcVdPRVN6VFVEWlRlUzN4eEEvMUh5S1hEWXlQdGJ2RWtMdGpiVXB4clJuU1JORmc9PQ==")
        this.ditto = ditto

        // This starts Ditto's background synchronization
        ditto.tryStartSync()

        // Configure the RecyclerView for swipe to delete
        val itemTouchHelper = ItemTouchHelper(swipeHandler)
        itemTouchHelper.attachToRecyclerView(recyclerView)

        // This function will create a "live-query" that will update
        // our RecyclerView
        setupTaskList()

        // This will check if the app has permissions
        // to fully enable Bluetooth
        checkPermissions()
    }

    fun setupTaskList() {
        // We use observe to create a live query with a subscription to sync this query with other devices
        this.liveQuery = ditto.observePeersV2 { peers ->
            adapter.set(peers)
        }
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        // Inflate the menu; this adds items to the action bar if it is present.
        menuInflater.inflate(R.menu.menu_main, menu)
        return true
    }

    fun checkPermissions() {
        val missing = DittoSyncPermissions(this).missingPermissions()
        if (missing.isNotEmpty()) {
            this.requestPermissions(missing, 0)
        }
    }
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        return when (item.itemId) {
            R.id.action_settings -> true
            else -> super.onOptionsItemSelected(item)
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        val navController = findNavController(R.id.nav_host_fragment_content_main)
        return navController.navigateUp(appBarConfiguration)
                || super.onSupportNavigateUp()
    }
}

class PeersAdapter: RecyclerView.Adapter<PeersAdapter.PeerViewHolder>() {
    private val peers = mutableListOf<DittoPeer>()

    class TaskViewHolder(v: View): RecyclerView.ViewHolder(v)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): TaskViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.peers_view, parent, false)
        return TaskViewHolder(view)
    }

    override fun onBindViewHolder(holder: PeerViewHolder, position: Int) {
        val peer = peers[position]
        holder.itemView.peerViewText.text = peer.id
    }

    override fun getItemCount() = this.peers.size

    fun peers(): List<DittoDocument> {
        return this.peers.toList()
    }

    fun set(peers: List<DittoPeer>): Int {
        this.peers.clear()
        this.peers.addAll(peers)
        return this.peers.size
    }

    fun setInitial(peers: List<DittoPeer>): Int {
        this.peers.addAll(peers)
        this.notifyDataSetChanged()
        return this.peers.size
    }
}