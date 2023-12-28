import './App.css';
import { useEffect, useState } from 'react'
import Ditto from './ditto'

let ditto 

function App() {
  let [status, setStatus] = useState({isAuthenticated: false})

  useEffect(() => {
    ditto = Ditto()
    let observer = ditto.auth.observeStatus(status => {
      setStatus(status)
    })
    return () => {
      observer.stop()
    }
  }, [])
  
  function login () {
    ditto.auth.loginWithToken("jellybeans", "provider")
  }

  function logout () {
    ditto.auth.logout()
  }

  return (
    <div className="App">
      {!status.isAuthenticated && <button onClick={login}>Login</button>}
      {status.isAuthenticated && <div>
        <h2>
          Hello {status.userID}
        </h2>
        <button onClick={logout}>Logout</button> 
      </div>
      }
    </div>
  );
}

export default App;
