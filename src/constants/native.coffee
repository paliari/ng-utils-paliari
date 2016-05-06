class Native extends Constant
  constructor: ->
    return window.cordova || window.NATIVE
