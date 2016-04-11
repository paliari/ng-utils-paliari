class Split extends Filter
  constructor: ->
    return (input, splitChar, splitIndex) ->
      splited = "#{input}".split(splitChar)
      switch splitIndex
        when 'first' then return _.first(splited)
        when 'last' then return _.last(splited)
        else splited[splitIndex]
