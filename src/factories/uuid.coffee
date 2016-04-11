class UUID extends Factory
  constructor: ->
    return ->
      d = Date.now()
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
        r = (d + Math.random() * 16) % 16 | 0
        d = Math.floor(d / 16)
        (if c is 'x' then r else (r & 0x3 | 0x8)).toString 16
