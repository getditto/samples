import { DocumentIDValue } from '@dittolive/ditto'
import { useMutations, usePendingCursorOperation } from '@dittolive/react-ditto'
import React, { useEffect, useState } from 'react'
import './App.css'

const COLLECTION = 'tasks'

type Task = { _id?: DocumentIDValue; body: string; isCompleted: boolean }

const App = () => {
  const [text, setText] = useState('')
  const { ditto, documents: tasks } = usePendingCursorOperation<Task>({
    collection: COLLECTION,
  })
  const { insert, removeByID, updateByID } = useMutations<Task>({
    collection: COLLECTION,
  })

  useEffect(() => {
    ditto?.startSync()
  }, [ditto])

  const updateText = (e: React.ChangeEvent<HTMLInputElement>) =>
    setText(e.currentTarget.value)

  const addTask = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    insert({ value: { body: text, isCompleted: false } })
    setText('')
  }

  const toggleIsCompleted =
    (taskId: string) => (e: React.ChangeEvent<HTMLInputElement>) =>
      updateByID({
        _id: taskId,
        updateClosure: (mutableDoc) => {
          if (mutableDoc) {
            mutableDoc.isCompleted = !mutableDoc.isCompleted
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
