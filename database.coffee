streamsql = require('streamsql')

db = streamsql.connect
  driver: 'mysql'
  user: process.env['DB_USER']
  password: process.env['DB_PASS']
  database: 'temperatures'

temperatureTable = db.table 'temps', fields: [ 'id', 'time', 'pos', 'temp', 'humid' ]

#temperatureTable.get({}, (err, rows)-> console.log err, rows)

module.exports =
  getAll: (filter, cb)->
    temperatureTable.get filter, (error, tempData) ->
      if error
        throw error
        cb false
      cb tempData

  put: (pos, temp, humid)->
    temperatureTable.put
      pos: pos
      temp: temp
      humid: humid
