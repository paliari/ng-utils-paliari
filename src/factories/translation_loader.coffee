class TranslationLoader extends Factory
  constructor: (i18nService) ->
    return (options) ->
      i18nService.get options.key
