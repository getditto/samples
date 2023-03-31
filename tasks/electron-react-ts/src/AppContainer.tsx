import { Ditto, Logger } from '@dittolive/ditto'
import { DittoProvider } from '@dittolive/react-ditto'
import React from 'react'
import App from './App'

const APP_ID = 'live.ditto.tasks'
const PATH = 'ditto-tasks'

const AppContainer = () => {
  const createDittoInstance = () => {
    Logger.minimumLogLevel = 'Debug'
    return new Ditto({ type: 'onlinePlayground', appID: APP_ID, token: TOKEN }, PATH)
  }

  return (
    <DittoProvider setup={createDittoInstance}>
      {({ loading, error }) => {
        if (loading) {
          return <div>Loading Ditto…</div>
        }

        if (error) {
          return (
            <div>
              There was an error loading Ditto. Error: {error.toString()}
            </div>
          )
        }

        return <App />
      }}
    </DittoProvider>
  )
}

export default AppContainer
