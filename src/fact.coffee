# Description:
#   Retrieves facts based on https://www.mashape.com/divad12/numbers-1#!documentation
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_MASHAPE_CLIENT_ID
#
# Commands:
#   fact (<day> <month> | today | random) - Show a historic fact
#
# Author:
#   aaccurso

hostname = 'https://numbersapi.p.mashape.com'

module.exports = (robot) ->
  robot.hear /fact(s)? (.*)/i, (msg) ->
    args = if msg.match[2] then msg.match[2].split(' ') else []
    fst = args[0]
    snd = args[1]
    if fst == 'today'
      today = new Date()
      day = today.getDate()
      month = today.getMonth() + 1
    else if fst == 'random' || !(fst and snd)
      day = Math.floor(Math.random() * 31)
      month = Math.floor(Math.random() * 12)
    else
      day = fst
      month = snd
    path = "/#{month}/#{day}/date"
    query =
      json: true
    query.fragment = true if fst == 'today' # This is because the api assumes true if fragment property is present regardless of its value

    msg.http(hostname + path)
    .query(query)
    .header('X-Mashape-Key', "#{process.env.HUBOT_MASHAPE_CLIENT_ID}")
    .get() (err, res, body) ->
      data = JSON.parse(body)
      if data.found
        fact = if fst == 'today' then "Today on #{data.year} #{data.text}" else data.text
        msg.send fact
      else msg.send "Fact not found for #{day}/#{month}. Try again!"
