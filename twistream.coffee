app    = require('express')()
server = require('http').Server(app)
io     = require('socket.io').listen(server)

twitter = require 'twitter'
client = new twitter(
  consumer_key: process.env.TWITTER_CONSUMER_KEY
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET
  access_token_key: process.env.TWITTER_ACCESS_TOKEN_KEY
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
)

io.sockets.on('connection', (socket) ->
  console.log('connected')

  socket.on('msg', (data) ->
    io.sockets.emit('msg', data)
  )
  socket.on('disconnect', -> console.log('disconnected'))
)

app.get('/', (req, res) ->
  res.sendFile(__dirname + '/index.html')
)

keyword = '#cat'
option = track: keyword

client.stream('statuses/filter', option, (stream) ->
  stream.on('data', (tweet) ->
    io.sockets.emit('msg', tweet)
  )
  stream.on('end', (res) -> console.log(res))
  stream.on('destroy', (res) -> console.log(res))
  stream.on('error', (error) -> console.log(error))
)

port = process.env.PORT || 3000
server.listen(port, -> console.log("listiening on *:#{port}"))
