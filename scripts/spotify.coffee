bitlyAccessToken = process.env.BITLY_ACCESS_TOKEN

module.exports = (robot) ->
  robot.hear spotify.link, (msg) ->
    msg.http(spotify.uri msg.match[0]).get() (err, res, body) ->
      if res.statusCode is 200
        data = JSON.parse(body)
        [mess, spoturi] = spotify[data.info.type](data)
        if (bitlyAccessToken?)
          msg.http("https://api-ssl.bitly.com").path("/v3/shorten?access_token=#{bitlyAccessToken}&longUrl=http%3A%2F%2Fspotbot.daveallie.com%2F%3Furi%3D#{spoturi}").header('Accept', 'application/json').get() (err, res, body) ->
            if res.statusCode is 200
              data_temp = JSON.parse(body)
              msg.send mess+" [#{data_temp.data.url}]"
        else
          msg.send mess+" [http://spotbot.daveallie.com/?uri=#{spoturi}]"

spotify =
  link: /// (
    ?: (http|https)://(open|play).spotify.com/(track|album|artist)/
     | spotify:(track|album|artist):
    ) \S+ ///

  uri: (link) -> "http://ws.spotify.com/lookup/1/.json?uri=#{link}"

  track: (data) ->
    track = "#{data.track.artists[0].name} - #{data.track.name}"
    album = "(#{data.track.album.name}) (#{data.track.album.released})"
    [ "Track: #{track} #{album}", data.track.href ]

  album: (data) ->
    [ "Album: #{data.album.artist} - #{data.album.name} (#{data.album.released})", data.album.href ]

  artist: (data) ->
    [ "Artist: #{data.artist.name}", data.artist.href ]
