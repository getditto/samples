import { useMutations, usePendingCursorOperation } from '@dittolive/react-ditto'
import React, { useEffect, useState } from 'react'
import './App.css'

const COLLECTION = 'tasks'

const App = () => {
  const [text, setText] = useState('')
  const { ditto, documents: tasks } = usePendingCursorOperation({
    collection: COLLECTION,
  })
  const { upsert, removeByID, updateByID } = useMutations({
    collection: COLLECTION,
  })

  useEffect(() => {
    if (!ditto) {
      return
    }

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

  const updateText = (e: React.ChangeEvent<HTMLInputElement>) =>
    setText(e.currentTarget.value)

  const addTask = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    upsert({ value: { body: text, isCompleted: false } })
    setText('')
  }

  const toggleIsCompleted =
    (taskId: string) => (e: React.ChangeEvent<HTMLInputElement>) =>
      updateByID({
        _id: taskId,
        updateClosure: (mutableDoc) => {
          if (mutableDoc) {
            mutableDoc.at("isCompleted").set(!mutableDoc.value.isCompleted)
          }
        },
      })

  const removeTask = (taskId: string) => () => removeByID({ _id: taskId })

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
          <li key={task.id.value}>
            <input
              type="checkbox"
              checked={task.value.isCompleted}
              onChange={toggleIsCompleted(task.id.value)}
            />
            <span className={task.value.isCompleted ? 'completed' : ''}>
              {task.value.body} <code>(ID: {task.id.value})</code>
            </span>
            <button type="button" onClick={removeTask(task.id.value)}>
              Remove
            </button>
          </li>
        ))}
      </ul>
    </div>
  )
}

export default App
