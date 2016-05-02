class CacheMemory extends Service
  constructor: ->
    @lifetime = 3600000 # one hour
    @reset()

  reset: ->
    @items = {}

  setItem: (key, value, lifetime = @lifetime) ->
    @items[key] = {value: value, time: Date.now() + lifetime}

  getItem: (key) ->
    return @items[key]['value'] if @checkTime(key)
    @clearItem(key)

  clearItem: (key) ->
    try delete @items[key]
    return undefined

  checkTime: (key) ->
    @items[key]['time'] > Date.now() if @items[key]
