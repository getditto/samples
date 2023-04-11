package com.dittolive.todo

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.*
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.DialogFragment
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.ItemTouchHelper
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import live.ditto.*
import live.ditto.android.DefaultAndroidDittoDependencies
import live.ditto.transports.DittoSyncPermissions
import live.dittolive.todo.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity(), NewTaskDialogFragment.NewTaskDialogListener {

    private lateinit var binding: ActivityMainBinding

    private lateinit var recyclerView: RecyclerView
    private lateinit var viewAdapter: RecyclerView.Adapter<*>
    private lateinit var viewManager: RecyclerView.LayoutManager

    private var ditto: Ditto? = null
    private var collection: DittoCollection? = null
    private var liveQuery: DittoLiveQuery? = null
    private var subscription: DittoSubscription? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        val view = binding.root
        setContentView(view)
        setSupportActionBar(binding.toolbar)

        // Setup the layout
        viewManager = LinearLayoutManager(this)
        val tasksAdapter = TasksAdapter()
        viewAdapter = tasksAdapter

        recyclerView = binding.recyclerView.apply {
            setHasFixedSize(true)
            layoutManager = viewManager
            adapter = viewAdapter
        }

        recyclerView.addItemDecoration(DividerItemDecoration(this, DividerItemDecoration.VERTICAL))

        // Create an instance of DittoSyncKit
        val androidDependencies = DefaultAndroidDittoDependencies(applicationContext)
        val ditto = Ditto(androidDependencies, DittoIdentity.OnlinePlayground(
            androidDependencies,
            "f2b5f038-6d00-433a-9176-6e84011da136",
            "545717fe-6ffc-4e9f-ab47-7b500430a6ce",
            enableDittoCloudSync = true)
        )

        this.ditto = ditto

        // This starts DittoSyncKit's background synchronization
        ditto.startSync()

        // Add swipe to delete
        val swipeHandler = object : SwipeToDeleteCallback(this) {
            override fun onSwiped(viewHolder: RecyclerView.ViewHolder, direction: Int) {
                val adapter = recyclerView.adapter as TasksAdapter
                // Retrieve the task at the row swiped
                val task = adapter.tasks()[viewHolder.adapterPosition]
                // Delete the task from DittoSyncKit
                ditto.store.collection("tasks").findById(task.id).remove()
            }
        }

        // Configure the RecyclerView for swipe to delete
        val itemTouchHelper = ItemTouchHelper(swipeHandler)
        itemTouchHelper.attachToRecyclerView(recyclerView)

        // Respond to new task button click
        binding.addTaskButton.setOnClickListener {
            showNewTaskUI()
        }

        // Listen for clicks to mark tasks [in]complete
        tasksAdapter.onItemClick = { task ->
            ditto.store.collection("tasks").findById(task.id).update { newTask ->
                newTask!!["isCompleted"].set(!newTask["isCompleted"].booleanValue)
            }
        }

        // This function will create a "live-query" that will update
        // our RecyclerView
        setupTaskList()

        // This will check if the app has location permissions
        // to fully enable Bluetooth
        checkLocationPermission()

        checkDittoPermission()
    }

    override fun onDialogSave(dialog: DialogFragment, task:String) {
        // Add the task to Ditto
        this.collection!!.upsert(mapOf("body" to task, "isCompleted" to false))
    }

    override fun onDialogCancel(dialog: DialogFragment) { }

    private fun showNewTaskUI() {
        val newFragment = NewTaskDialogFragment.newInstance()
        newFragment.show(supportFragmentManager,"newTask")
    }

    private fun setupTaskList() {
        // We will create a long-running live query to keep UI up-to-date
        this.collection = this.ditto!!.store.collection("tasks")
        
        // We use observe to create a live query with a subscription to sync this query with other devices
        this.subscription = collection!!.find("isDeleted == false").subscribe()

        // We listen to changes to all data locally
        this.liveQuery = collection!!.findAll().observeLocal { docs, event ->
            val adapter = (this.viewAdapter as TasksAdapter)
            when (event) {
                is DittoLiveQueryEvent.Update -> {
                    runOnUiThread {
                        adapter.set(docs)
                        adapter.inserts(event.insertions)
                        adapter.deletes(event.deletions)
                        adapter.updates(event.updates)
                        adapter.moves(event.moves)
                    }
                }
                is DittoLiveQueryEvent.Initial -> {
                    runOnUiThread {
                        adapter.setInitial(docs)
                    }
                }
            }
        }

        ditto!!.store.collection("tasks").find("isDeleted == true").evict()
    }

    private fun checkDittoPermission() {
        val missing = DittoSyncPermissions(this).missingPermissions()
        if (missing.isNotEmpty()) {
            this.requestPermissions(missing, 0)
        }
    }

    private fun checkLocationPermission() {
        // On Android, parts of Bluetooth LE and WiFi Direct require location permission
        // Ditto will operate without it but data sync may be impossible in certain scenarios
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
            != PackageManager.PERMISSION_GRANTED) {
            // For this app we will prompt the user for this permission every time if it is missing
            // We ignore the result - Ditto will automatically notice when the permission is granted
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), 0)
        }
    }
}

// Swipe to delete based on https://medium.com/@kitek/recyclerview-swipe-to-delete-easier-than-you-thought-cff67ff5e5f6
abstract class SwipeToDeleteCallback(context: Context) : ItemTouchHelper.SimpleCallback(0, ItemTouchHelper.LEFT) {

    private val deleteIcon = ContextCompat.getDrawable(context, android.R.drawable.ic_menu_delete)
    private val intrinsicWidth = deleteIcon!!.intrinsicWidth
    private val intrinsicHeight = deleteIcon!!.intrinsicHeight
    private val background = ColorDrawable()
    private val backgroundColor = Color.parseColor("#f44336")
    private val clearPaint = Paint().apply { xfermode = PorterDuffXfermode(PorterDuff.Mode.CLEAR) }


    override fun onMove(recyclerView: RecyclerView, viewHolder: RecyclerView.ViewHolder, target: RecyclerView.ViewHolder): Boolean {
        return false
    }

    override fun onChildDraw(
        c: Canvas, recyclerView: RecyclerView, viewHolder: RecyclerView.ViewHolder,
        dX: Float, dY: Float, actionState: Int, isCurrentlyActive: Boolean
    ) {

        val itemView = viewHolder.itemView
        val itemHeight = itemView.bottom - itemView.top
        val isCanceled = dX == 0f && !isCurrentlyActive

        if (isCanceled) {
            clearCanvas(c, itemView.right + dX, itemView.top.toFloat(), itemView.right.toFloat(), itemView.bottom.toFloat())
            super.onChildDraw(c, recyclerView, viewHolder, dX, dY, actionState, isCurrentlyActive)
            return
        }

        // Draw the red delete background
        background.color = backgroundColor
        background.setBounds(itemView.right + dX.toInt(), itemView.top, itemView.right, itemView.bottom)
        background.draw(c)

        // Calculate position of delete icon
        val deleteIconTop = itemView.top + (itemHeight - intrinsicHeight) / 2
        val deleteIconMargin = (itemHeight - intrinsicHeight) / 2
        val deleteIconLeft = itemView.right - deleteIconMargin - intrinsicWidth
        val deleteIconRight = itemView.right - deleteIconMargin
        val deleteIconBottom = deleteIconTop + intrinsicHeight

        // Draw the delete icon
        deleteIcon!!.setBounds(deleteIconLeft, deleteIconTop, deleteIconRight, deleteIconBottom)
        deleteIcon.setTint(Color.parseColor("#ffffff"))
        deleteIcon.draw(c)

        super.onChildDraw(c, recyclerView, viewHolder, dX, dY, actionState, isCurrentlyActive)
    }

    private fun clearCanvas(c: Canvas?, left: Float, top: Float, right: Float, bottom: Float) {
        c?.drawRect(left, top, right, bottom, clearPaint)
    }
}
