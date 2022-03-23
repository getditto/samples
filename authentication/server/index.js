let server = require('./server.js')
let port = process.env.PORT || 3000
server.listen(port, () => {
    console.log('listening on http://localhost:'+ port)
})