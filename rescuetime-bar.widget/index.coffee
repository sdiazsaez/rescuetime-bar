command: """
  python rescuetime-bar.widget/lib/fetchData.py
"""

#2min
refreshFrequency: 120000

render: (output) -> """
<div class="rescuetime-container"></div>
"""

style: """
@import url(rescuetime-bar.widget/lib/style.css)
"""

update: (output, domEl) ->
  calcWidth = (value) ->
    timeSpentParsed += value
    Math.round(value/timeSpentTotal * 100)

  checkWidth = (text, width) ->
    canvas = document.createElement('canvas')
    context = canvas.getContext('2d')
    context.font = '13px sans-serif'
    metrics = context.measureText(text)
    canvas = null
    if metrics.width < width/100 * container.offsetWidth then text else ''

  productivityDescription = (productivity) -> productivityItems[productivity]

  container = document.getElementsByClassName('rescuetime-container')[0]
    
  if output == "error\n"
    container.innerHTML = @template 'error', 100, '#fff', checkWidth('Rescuetime data couldn\'t be fetch, check your API Key in the config file and make sure you have at least 10 minutes of collected data',100)
  else
        
    productivityItems = {
        '2': {label: 'Very productive', color: '#0055C4'},
        '1': {label: 'Productive', color: '#3D80E0'},
        '0': {label: 'Neutral', color: '#B1C1BF'},
        '-1': {label: 'Distracting', color: '#DC685A'},
        '-2': {label: 'Very distracting', color: '#D61800'},
    }

    data = JSON.parse(output)
    data.rows.sort(@dataSort('-3'))
    data.rows.reverse()
    
    timeSpentTotal = 0
    data.rows.forEach (item) ->
      timeSpentTotal += item[1]

    timeSpentParsed = 0

    container.innerHTML = ''

    data.rows.forEach (item) ->
        width = calcWidth(item[1])
        description = productivityDescription(item[3])
        label = width + '% - '+@secondsToTime(item[1]) + ' - ' + description.label
        container.innerHTML += @template 'lightText', width, description.color, checkWidth(label, width)
    , this

template: (_class, width, colour, text) -> "<div class='item #{_class}' style='width:#{width}%; background-color:#{colour}'><p>#{text}</p></div>"

dataSort: (property) ->
    sortOrder = 1;
    if property[0] == "-"
        sortOrder = -1;
        property = property.substr(1);
    
    return (a, b) -> 
        result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
        return result * sortOrder;
    
secondsToTime: (sec_num) -> 
    hours   = Math.floor(sec_num / 3600)
    minutes = Math.floor((sec_num - (hours * 3600)) / 60)
    seconds = sec_num - (hours * 3600) - (minutes * 60)

    if hours < 10 
        hours = "0"+hours
        
    if minutes < 10 
        minutes = "0"+minutes
        
    if seconds < 10 
        seconds = "0"+seconds
        
    return hours+':'+minutes+':'+seconds

