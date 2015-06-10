# Description:
#   Metadata lookup for spotify links
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   <spotify link> - returns info about the link (track, artist, etc.)
#
# Author:
#   jacobk

module.exports = (robot) ->
  robot.hear spotify.link, (msg) ->
    msg.http(spotify.uri msg.match[0]).get() (err, res, body) ->
      if res.statusCode is 200
        data = JSON.parse(body)
        [mess, spoturi] = spotify[data.info.type](data)

        msg.http("https://api-ssl.bitly.com").path("/v3/shorten?login=o_2165he6oo0&apiKey=R_497f3ea93ab14114a220dacf3fd71478&longUrl=http%3A%2F%2Fspot.daveallie.com%2F%3Furi%3D#{spoturi}").header('Accept', 'application/json').get() (err, res, body) ->
          if res.statusCode is 200
            data_temp = JSON.parse(body)
            msg.send mess+" [#{data_temp.data.url}]"

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