class Mask extends Factory
  constructor: ->
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
        val = @clearNumeric(val)
        val.replace(/^(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4')

      cnpj: (val) ->
        val = @clearNumeric(val)
        val.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5')

      codval: (val) ->
        val = @clearAlphaNumeric(val)
        val.replace(/^(\w{3})(\w{3})(\w{3})/, '$1-$2-$3')

      cep: (val) ->
        val = @clearNumeric(val)
        val.replace(/^(\d{2})(\d{3})(\d{3})/, '$1.$2-$3')

      fone: (val) ->
        val = @clearNumeric(val)
        if val.substr(0, 4) is '0800'
          return val.replace(/^(\d{4})(\d{2,4})(\d{4})/, '$1 $2-$3')
        val.replace(/^([0]{0,1})(\d{2}){0,1}(\d{4,5})(\d{4})/, '($1$2) $3-$4')

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
