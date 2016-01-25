express = require('express')
bodyParser = require('body-parser')
app = express()
app.use(bodyParser.urlencoded({ extended: false }))

spawn = require('child_process').spawn
coffee = require('coffee-script')
db = require './database'

app.use(express.static('public'))

app.post '/data', (req, res) ->
  console.log req.body
  db.getAll {}, (data)->
    if data==false then res.end('')
    res.end JSON.stringify data

app.listen 3000, ->
  console.log 'Example app listening on port 3000!'
  return

coffeeWatch = spawn 'coffee', ['--watch', '--compile', 'public/main.coffee']
coffeeWatch.stdout.on 'data', (data)-> console.log 'COFFEE: '+data

arduinoSerial = spawn('cat', ['/dev/ttyUSB0'])


serialStr = ''

tempString2Obj = (str)-> # TESTDATA = H37-37T20-20I19.02-19.02
  #tempIndex: str.split('I')[1].split('-')
  temperature: str.split('T')[1].split('I')[0].split('-')
  humidity: str.split('H')[1].split('T')[0].split('-')


arduinoSerial.stdout.on 'data', (data)->
  #console.log data
  if (data[0] == 0x0A || data[0] == 0x0D)
    return if serialStr.length<1
    sensorData = tempString2Obj serialStr
    for temp, i in sensorData.temperature
      db.put i, temp, sensorData.humidity[0]
    serialStr = ''
  else serialStr += data


arduinoSerial.on 'close', (code)->
  console.log("child process exited with code ${code}")

exitHandler = (options, err)->
  db.putLast()
  if err then console.log err.stack
  if options.exit
    process.exit()

process.stdin.resume()
process.on 'exit', exitHandler.bind(null, cleanup: true)
process.on 'SIGINT', exitHandler.bind(null, exit: true)
process.on 'uncaughtException', exitHandler.bind(null, exit: true)
