let express = require('express')
let { nanoid } = require('nanoid')
let cors = require('cors')
let body = require('body-parser')
let app = express()

app.use(cors())
app.use(body.json())
let users = {}

function checkToken (token) {
  let userId = users[token]
  if (!userId) {
    users[token] = nanoid()
  }
  return { 
    userId: users[token]
  } 
}

app.post('/', async (req, res) => {
  const token = req.body.token;
  console.log('got token', req.body.token)
  try {
    const { userId } = await checkToken(token)
    res.json({
      "authenticate": true,
      "expirationSeconds": 28800,
      "userID": userId,
      "permissions": {
        "read": {
          "everything": true,
          "queriesByCollection": {}
        },
        "write": {
          "everything": true,
          "queriesByCollection": {}
        }
      }
    })
  } catch (err) {
    console.error(err)
    res.json({
      "authenticate": err,
      "userInfo": err.message
    }) 
  }
})

module.exports = app