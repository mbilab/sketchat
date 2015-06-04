exec = require \child_process .exec

ports = {}
exec 'netstat -lnptu', (err, data, stderr) ->
  data = data / '\n'; data.pop!
  for i from 2 til data.length
    arr = data[i].split /\s+/
    port = arr.3.split \:
    port = port[port.length - 1]
    ports[port] = 1
  console.log ports
