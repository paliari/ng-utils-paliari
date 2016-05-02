class NgMaskEndereco extends Filter
  constructor: (Mask) ->
    return (endereco) ->
      Mask.endereco endereco
