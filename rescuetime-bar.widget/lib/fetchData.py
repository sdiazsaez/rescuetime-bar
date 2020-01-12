import urllib
import urllib2
import json
import sys

filePath = sys.path[0]+'/config.json'

with open(filePath, 'r') as file:
    config = json.load(file)

rtApi = 'https://www.rescuetime.com/anapi/data?format=json&restrict_kind=productivity'

endcode = urllib.urlencode(config['params'])
url = rtApi + '&' + endcode

try:
    response = urllib2.build_opener().open(url)
    data = response.read().decode("utf-8")
except:
	data = 'error'

print(data)
