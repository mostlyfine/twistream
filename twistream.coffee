twitter = require 'twitter'
util = require 'util'

twit = new twitter({
  consumer_key: process.env.TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET,
})

keyword = process.env.KEYWORD || '#photo'

fs = require 'fs'
server = require('http').createServer (req, res) ->
  res.writeHead 200, {'Content-type': 'text/html'}
  path = req.url.replace(/^\//, '') || 'index.html'
  fs.createReadStream(path).on('error', (e) -> console.log path).pipe(res)
.listen(process.env.PORT || 3000)

tweets = []

io = require('socket.io').listen(server)
io.sockets.on 'connection', (socket) ->
  socket.emit 'track', keyword
  tweets.forEach (e, i) ->
    socket.emit 'msg', e

twit.stream 'statuses/filter', {track: keyword}, (stream) ->
  stream.on 'data', (tweet) ->
    console.log tweet if process.env.DEBUG
    console.log util.format("%s\t%s\t%s\t%s", tweet.id, tweet.created_at, tweet.user.screen_name, tweet.text)
    tweets.push(tweet)
    tweets.shift if tweets.length > 20
    io.sockets.emit 'msg', tweet
  stream.on 'end', (res) -> console.log 'disconnected'
  stream.on 'destroy', (res) -> console.log 'destroyed'
  stream.on 'error', (err) -> console.log err
