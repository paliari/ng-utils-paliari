class I18n extends Service
  constructor: (@$q, @Restangular) ->
    @cache = {}

  deepReplace: (data) ->
    for k, v of data
      data[k] = if _.isString v then v.replace /\%\{(\w*?)\}/g, '{{$1}}' else @deepReplace v
    data

  get: (language = 'pt-BR') ->
    def = @$q.defer()
    if @cache[language]
      def.resolve @cache[language]
    else
      @Restangular.one('translations', language).get().then (data) =>
        @cache[language] = @deepReplace(data.plain())
        def.resolve @cache[language]
      , def.reject
    def.promise

  hum: (key, language) ->
    @get(language).then (data) ->
      _.deepProperty data, key

  humEnum: (key, language) ->
    @hum "enums.#{key}", language

  humModel: (key, language) ->
    @hum "activerecord.models.#{key}", language

  humAttribute: (key, language) ->
    @hum "activerecord.attributes.#{key}", language
