twitter = require 'twitter'

twit = new twitter({
  consumer_key: process.env.TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET,
})

fs = require 'fs'
server = require('http').createServer (req, res) ->
  res.writeHead 200, {'Content-type': 'text/html'}
  path = req.url.replace(/^\//, '') || 'index.html'
  fs.createReadStream(path).on('error', (e) -> console.log path).pipe(res)
.listen(process.env.PORT || 3000)

keywords = []
io = require('socket.io').listen(server)
io.sockets.on 'connection', (socket) ->
  console.log("conn");

  socket.on 'join', (keyword) ->
    console.log(keyword)
    keywords.push(keyword)
    track = keywords.filter (x, i, self) -> self.indexOf(x) == i
    .join(',')
    console.log(track)
    twit.stream 'statuses/filter', {track: track}, (stream) ->
      stream.on 'data', (tweet) ->
        for hashtag in tweet.entities.hashtags
          console.log hashtag.text
          io.sockets.emit '#'+hashtag.text, tweet
      stream.on 'end', (res) -> console.log 'disconnected'
      stream.on 'destroy', (res) -> console.log 'destroyed'
      stream.on 'error', (err) -> console.log err
