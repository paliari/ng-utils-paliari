class Mask extends Factory
  constructor: (NgStringMask, FORMATS) ->
    mask =
      cpfCnpj: (val) ->
        return '' unless val
        val = @clearNumeric(val)
        if val.length is 14
          return @cnpj(val)
        if val.length is 11
          return @cpf(val)
        val

      cpf: (val) ->
        NgStringMask(FORMATS.cpf).apply val

      cnpj: (val) ->
        NgStringMask(FORMATS.cnpj).apply val

      codval: (val) ->
        val = @clearAlphaNumeric(val)
        val.replace(/^(\w{3})(\w{3})(\w{3})/, '$1-$2-$3')

      cep: (val) ->
        NgStringMask(FORMATS.cep).apply val

      fone: (val) ->
        val = @clearNumeric(val)
        if val.substr(0, 4) is '0800'
          return val.replace(/^(\d{4})(\d{2,4})(\d{4})/, '$1 $2-$3')
        NgStringMask(FORMATS.fone).apply val

      clearAlphaNumeric: (val) ->
        return '' unless val
        val.replace(/[\W]/g, '')

      clearNumeric: (val) ->
        return '' unless val
        val.replace(/[\D]/g, '')

      endereco: (e) ->
        return '' unless e
        str = ''
        str = e.logradouro.nome if e.logradouro
        str += ', ' + e.numero if e.numero
        str += ' ' + e.complemento if e.complemento
        str += ' ' + e.bairro.nome if e.bairro
        str += ' CEP: ' + @cep(e.cep) if e.cep
        str += " #{e.cidade.nome}-#{e.cidade.uf}" if e.cidade
        str.toLowerCase()
    return mask
