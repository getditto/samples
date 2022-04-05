import { useMutations, usePendingCursorOperation } from '@dittolive/react-ditto'
import React, { useEffect, useState } from 'react'
import './App.css'

const COLLECTION = 'tasks'
const OFFLINE_LICENSE_TOKEN = '<REPLACE_ME>'

const App = () => {
  const [text, setText] = useState('')
  const { ditto, documents: tasks } = usePendingCursorOperation({
    collection: COLLECTION,
  })
  const { insert, removeByID, updateByID } = useMutations({
    collection: COLLECTION,
  })

  useEffect(() => {
    if (!ditto) {
      return
    }

    ditto.setOfflineOnlyLicenseToken(OFFLINE_LICENSE_TOKEN)
    ditto.updateTransportConfig((t) => {
      t.setAllPeerToPeerEnabled(true)
      // Or selectively enable only some P2P tranports:
      // t.peerToPeer.awdl.isEnabled = true
      // t.peerToPeer.bluetoothLE.isEnabled = true
      // t.peerToPeer.lan.isEnabled = true
    })
    ditto.startSync()

    return () => ditto.stopSync()
  }, [ditto])

  const updateText = (e) => setText(e.currentTarget.value)

  const addTask = (e) => {
    e.preventDefault()
    insert({ value: { body: text, isCompleted: false } })
    setText('')
  }

  const toggleIsCompleted = (taskId) => (e) =>
    updateByID({
      _id: taskId,
      updateClosure: (mutableDoc) => {
        if (mutableDoc) {
          mutableDoc.isCompleted = !mutableDoc.isCompleted
        }
      },
    })

  const removeTask = (taskId) => () => removeByID({ _id: taskId })

  return (
    <div className="App">
      <div className="count">
        {tasks.length} task{tasks.length !== 1 ? 's' : ''}
      </div>
      <form className="new" onSubmit={addTask}>
        <input
          placeholder="New task"
          value={text}
          onChange={updateText}
          required
        />
        <button type="submit">Add</button>
      </form>
      <ul>
        {tasks.map((task) => (
          <li key={task._id}>
            <input
              type="checkbox"
              checked={task.isCompleted}
              onChange={toggleIsCompleted(task._id)}
            />
            <span className={task.isCompleted ? 'completed' : ''}>
              {task.body} <code>(ID: {task._id})</code>
            </span>
            <button type="button" onClick={removeTask(task._id)}>
              Remove
            </button>
          </li>
        ))}
      </ul>
    </div>
  )
}

export default App
