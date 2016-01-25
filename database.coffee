streamsql = require('streamsql')

db = streamsql.connect
  driver: 'mysql'
  user: process.env['DB_USER']
  password: process.env['DB_PASS']
  database: 'temperatures'

temperatureTable = db.table 'temps', fields: [ 'id', 'time', 'pos', 'temp', 'humid' ]

#temperatureTable.get({}, (err, rows)-> console.log err, rows)
previousValues = []

compareTempRow = (t0, t1)->
  t0.humid!=t1.humid || t0.temp!=t1.temp



Date::toMysqlFormat = ->
  twoDigits = (d) ->
    if 0 <= d and d < 10 then '0' + d.toString()
    else if -10 < d and d < 0 then '-0' + (-1 * d).toString()
    else d.toString()
  @getUTCFullYear() + '-' + twoDigits(1 + @getUTCMonth()) + '-' + twoDigits(@getUTCDate()) + ' ' + twoDigits(@getUTCHours()) + ':' + twoDigits(@getUTCMinutes()) + ':' + twoDigits(@getUTCSeconds())


module.exports =
  getAll: (filter, cb)->
    temperatureTable.get filter, (error, tempData) ->
      if error
        throw error
        cb false
      cb tempData

  putLast: ()->
    previousValues.forEach (v)->
      temperatureTable.put v

  put: (pos, temp, humid)->
    tempRow =
      pos: pos
      temp: temp
      humid: humid
      time: new Date().toMysqlFormat()
    if previousValues[pos]?
      if compareTempRow tempRow, previousValues[pos]
        temperatureTable.put tempRow
    else temperatureTable.put tempRow
    previousValues[pos] = tempRow
