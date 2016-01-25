window.onload = ()->
  xhttp = new XMLHttpRequest()
  params = "lorem=ipsum&name=binny"

  xhttp.onreadystatechange = ()->
    return if xhttp.readyState != 4 || xhttp.status != 200
    draw JSON.parse xhttp.responseText


  xhttp.open 'POST', 'data', true
  xhttp.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
  xhttp.send params

  margin = top: 20, right: 20, bottom: 70, left: 40
  width = 960 - (margin.left) - (margin.right)
  height = 500 - (margin.top) - (margin.bottom)

  formatDate = d3.time.format('%d-%b-%y')
  parseDate = d3.time.format('%Y-%m-%dT%H:%M:%S').parse

  x = d3.time.scale().range([ 0, width ])
  y = d3.scale.linear().range([ height, 0 ])
  xAxis = d3.svg.axis().scale(x).orient('bottom')
  yAxis = d3.svg.axis().scale(y).orient('left')
  line = d3.svg.line()
    .x((d) -> x d.date )
    .y((d) -> y d.close )

  svg = d3.select('body').append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
    .append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

  draw = (data)->
    data.forEach (d)->
      d.date = parseDate d.time.split('.')[0]
      d.close = d.temp

    x.domain d3.extent(data, (d) -> d.date )
    y.domain d3.extent(data, (d) -> d.close )

    svg.append('g')
      .attr('class', 'x axis')
      .attr('transform', 'translate(0,' + height + ')')
      .call xAxis
    svg.append('g')
    .attr('class', 'y axis')
    .call(yAxis)
    .append('text')
      .attr('transform', 'rotate(-90)')
      .attr('y', 6)
      .attr('dy', '.71em')
      .style('text-anchor', 'end')
      .text 'Price ($)'
    svg.append('path').datum(data).attr('class', 'line').attr 'd', line


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
