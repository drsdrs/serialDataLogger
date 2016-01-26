tempData = null

window.onload = ()->
  xhttp = new XMLHttpRequest()
  params = "lorem=ipsum&name=binny"

  xhttp.onreadystatechange = ()->
    return if xhttp.readyState != 4 || xhttp.status != 200
    data = JSON.parse xhttp.responseText
    dataArray = [[],[]]
    data.forEach (v,i)->
      dataArray[v.pos].push
        temp: v.temp
        humid: v.humid
        date: parseDate v.time.split('.')[0]
    tempData = dataArray
    draw dataArray[1]


  xhttp.open 'POST', 'data', true
  xhttp.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
  xhttp.send params

  margin = top: 20, right: 20, bottom: 70, left: 40
  width = window.innerWidth - (margin.left) - (margin.right)
  height = (window.innerHeight/2) - (margin.top) - (margin.bottom)

  sensorNrEl = document.getElementById 'sensorNr'
  sensorNrEl.addEventListener 'click', (e)->
    console.log tempData
    draw tempData[e.target.value]

  formatDate = d3.time.format('%d-%b-%y')
  parseDate = d3.time.format('%Y-%m-%dT%H:%M:%S').parse

  x = d3.time.scale().range([ 0, width ])
  yT = d3.scale.linear().range([ height, 0 ])
  yH = d3.scale.linear().range([ height*2, height ])
  xAxis = d3.svg.axis().scale(x).orient('bottom')
  yTAxis = d3.svg.axis().scale(yT).orient('left')
  yHAxis = d3.svg.axis().scale(yH).orient('left')

  line = d3.svg.line()
    .x((d)-> x d.date )
    .y((d)-> yT d.temp )

  lineHumid = d3.svg.line()
    .x((d)-> x d.date )
    .y((d)-> yH d.humid )

  svg = d3.select('body').append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height*2 + margin.top + margin.bottom)

  tempG = svg.append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
  humidG = svg.append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top*2 + ')')


  draw = (data)->
    x.domain d3.extent(data, (d) -> d.date )
    yT.domain d3.extent(data, (d) -> d.temp )
    yH.domain d3.extent(data, (d) -> d.humid )

    tempG.append('g')
      .attr('class', 'x axis')
      .attr('transform', 'translate(0,' + height + ')')
      .call xAxis
    tempG.append('g')
      .attr('class', 'y axis')
      .call(yTAxis)
      .append('text')
        .attr('transform', 'rotate(-90)')
        .attr('y', 6)
        .attr('dy', '.71em')
        .style('text-anchor', 'end')
        .text 'Price ($)'
    tempG.append('path').datum(data)
      .attr('class', 'lineA')
      .attr('d', line)

    humidG.append('g')
      .attr('class', 'y axis')
      .call(yHAxis)
      .append('text')
        .attr('transform', 'rotate(-90)')
        .attr('y', height)
        .attr('dy', '.71em')
        .style('text-anchor', 'end')
    humidG.append('path').datum(data)
      .attr('class', 'lineB')
      .attr 'd', lineHumid
    # margin = top: 20, right: 20, bottom: 70, left: 40
    # width = 600 - (margin.left) - (margin.right)
    # height = 300 - (margin.top) - (margin.bottom)
    # # Parse the date / time
    # # 2016-01-25T10:24:58.000Z
    # parseDate = d3.time.format('%Y-%m-%dT%H:%M:%S').parse
    # x = d3.scale.ordinal().rangeRoundBands([ 0, width ], .05)
    # y = d3.scale.linear().range([ height, 0 ])
    # xAxis = d3.svg.axis().scale(x).orient('bottom')
    #   .tickFormat(d3.time.format('%Y-%m'))
    # yAxis = d3.svg.axis().scale(y).orient('left').ticks(10)
    # svg = d3.select('body').append('svg')
    #   .attr('width', width + margin.left + margin.right)
    #   .attr('height', height + margin.top + margin.bottom)
    #   .append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
    #
    # draw = (data)->
    #   data.forEach (d)->
    #     d.time = parseDate d.time.split('.')[0]
    #
    #   x.domain data.map (d)-> d.time
    #   y.domain [ 0, d3.max(data, (d)-> d.temp ) ]
    #   svg.append('g').attr('class', 'x axis')
    #     .attr('transform', 'translate(0,' + height + ')')
    #     .call(xAxis).selectAll('text')
    #       .style('text-anchor', 'end')
    #       .attr('dx', '-.8em').attr('dy', '-.55em')
    #       .attr 'transform', 'rotate(-90)'
    #   svg.append('g').attr('class', 'y axis').call(yAxis).append('text')
    #     .attr('transform', 'rotate(-90)')
    #     .attr('y', 6).attr('dy', '.71em')
    #     .style('text-anchor', 'end')
    #     .text 'Value ($)'
    #   svg.selectAll('bar').data(data).enter()
    #     .append('line').style('fill', 'steelblue')
    #     #.attr('x', (d)-> x d.time)
    #     .attr('y', x.rangeBand()).attr('y', (d)-> y d.temp)
    #     .attr 'x', (d) -> height - y(d.temp)
