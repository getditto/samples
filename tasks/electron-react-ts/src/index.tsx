import React from 'react'
import ReactDOMClient from 'react-dom/client'
import './index.css'
import AppContainer from './AppContainer'

const container = document.getElementById('root')
if (!container) {
  throw new Error('root element not found')
}

const root = ReactDOMClient.createRoot(container)

// Rewrap in `<React.StrictMode>` when this get fixed:
// https://github.com/getditto/react-ditto/issues/22
root.render(<AppContainer />)
