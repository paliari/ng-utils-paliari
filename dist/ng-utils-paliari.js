(function() {
  var CacheMemory, I18n, KvStorage, Mask, Native, NgMaskEndereco, NgUtilsPaliari, TranslationLoader, UUID;

  NgUtilsPaliari = (function() {
    function NgUtilsPaliari() {
      return ['ng-mask-filters'];
    }

    return NgUtilsPaliari;

  })();

  angular.module('ng-utils-paliari', new NgUtilsPaliari());

  Native = (function() {
    function Native() {
      return window.cordova || window.NATIVE;
    }

    return Native;

  })();

  angular.module('ng-utils-paliari').constant('NATIVE', Native());

  Mask = (function() {
    function Mask(NgStringMask, FORMATS) {
      var mask;
      mask = {
        cpfCnpj: function(val) {
          if (!val) {
            return '';
          }
          val = this.clearNumeric(val);
          if (val.length === 14) {
            return this.cnpj(val);
          }
          if (val.length === 11) {
            return this.cpf(val);
          }
          return val;
        },
        cpf: function(val) {
          return NgStringMask(FORMATS.cpf).apply(val);
        },
        cnpj: function(val) {
          return NgStringMask(FORMATS.cnpj).apply(val);
        },
        codval: function(val) {
          val = this.clearAlphaNumeric(val);
          return val.replace(/^(\w{3})(\w{3})(\w{3})/, '$1-$2-$3');
        },
        cep: function(val) {
          return NgStringMask(FORMATS.cep).apply(val);
        },
        fone: function(val) {
          val = this.clearNumeric(val);
          if (val.substr(0, 4) === '0800') {
            return val.replace(/^(\d{4})(\d{2,4})(\d{4})/, '$1 $2-$3');
          }
          return NgStringMask(FORMATS.fone).apply(val);
        },
        clearAlphaNumeric: function(val) {
          if (!val) {
            return '';
          }
          return val.replace(/[\W]/g, '');
        },
        clearNumeric: function(val) {
          if (!val) {
            return '';
          }
          return val.replace(/[\D]/g, '');
        },
        endereco: function(e) {
          var str;
          if (!e) {
            return '';
          }
          str = '';
          if (e.logradouro) {
            str = e.logradouro.nome;
          }
          if (e.numero) {
            str += ', ' + e.numero;
          }
          if (e.complemento) {
            str += ' ' + e.complemento;
          }
          if (e.bairro) {
            str += ' ' + e.bairro.nome;
          }
          if (e.cep) {
            str += ' CEP: ' + this.cep(e.cep);
          }
          if (e.cidade) {
            str += " " + e.cidade.nome + "-" + e.cidade.uf;
          }
          return str.toLowerCase();
        }
      };
      return mask;
    }

    return Mask;

  })();

  angular.module('ng-utils-paliari').factory('Mask', ['NgStringMask', 'FORMATS', Mask]);

  TranslationLoader = (function() {
    function TranslationLoader(i18nService) {
      return function(options) {
        return i18nService.get(options.key);
      };
    }

    return TranslationLoader;

  })();

  angular.module('ng-utils-paliari').factory('TranslationLoader', ['i18nService', TranslationLoader]);

  UUID = (function() {
    function UUID() {
      return function() {
        var d;
        d = Date.now();
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
          var r;
          r = (d + Math.random() * 16) % 16 | 0;
          d = Math.floor(d / 16);
          return (c === 'x' ? r : r & 0x3 | 0x8).toString(16);
        });
      };
    }

    return UUID;

  })();

  angular.module('ng-utils-paliari').factory('UUID', [UUID]);

  NgMaskEndereco = (function() {
    function NgMaskEndereco(Mask) {
      return function(endereco) {
        return Mask.endereco(endereco);
      };
    }

    return NgMaskEndereco;

  })();

  angular.module('ng-utils-paliari').filter('ngMaskEndereco', ['Mask', NgMaskEndereco]);

  CacheMemory = (function() {
    function CacheMemory() {
      this.lifetime = 3600000;
      this.reset();
    }

    CacheMemory.prototype.reset = function() {
      return this.items = {};
    };

    CacheMemory.prototype.setItem = function(key, value, lifetime) {
      if (lifetime == null) {
        lifetime = this.lifetime;
      }
      return this.items[key] = {
        value: value,
        time: Date.now() + lifetime
      };
    };

    CacheMemory.prototype.getItem = function(key) {
      if (this.checkTime(key)) {
        return this.items[key]['value'];
      }
      return this.clearItem(key);
    };

    CacheMemory.prototype.clearItem = function(key) {
      try {
        delete this.items[key];
      } catch (undefined) {}
      return void 0;
    };

    CacheMemory.prototype.checkTime = function(key) {
      if (this.items[key]) {
        return this.items[key]['time'] > Date.now();
      }
    };

    return CacheMemory;

  })();

  angular.module('ng-utils-paliari').service('cacheMemoryService', [CacheMemory]);

  I18n = (function() {
    function I18n($q, Restangular) {
      this.$q = $q;
      this.Restangular = Restangular;
      this.cache = {};
    }

    I18n.prototype.deepReplace = function(data) {
      var k, v;
      for (k in data) {
        v = data[k];
        data[k] = _.isString(v) ? v.replace(/\%\{(\w*?)\}/g, '{{$1}}') : this.deepReplace(v);
      }
      return data;
    };

    I18n.prototype.get = function(language) {
      var def;
      if (language == null) {
        language = 'pt-BR';
      }
      def = this.$q.defer();
      if (this.cache[language]) {
        def.resolve(this.cache[language]);
      } else {
        this.Restangular.one('translations', language).get().then((function(_this) {
          return function(data) {
            _this.cache[language] = _this.deepReplace(data.plain());
            return def.resolve(_this.cache[language]);
          };
        })(this), def.reject);
      }
      return def.promise;
    };

    I18n.prototype.hum = function(key, language) {
      return this.get(language).then(function(data) {
        return _.deepProperty(data, key);
      });
    };

    I18n.prototype.humEnum = function(key, language) {
      return this.hum("enums." + key, language);
    };

    I18n.prototype.humModel = function(key, language) {
      return this.hum("activerecord.models." + key, language);
    };

    I18n.prototype.humAttribute = function(key, language) {
      return this.hum("activerecord.attributes." + key, language);
    };

    return I18n;

  })();

  angular.module('ng-utils-paliari').service('i18nService', ['$q', 'Restangular', I18n]);

  KvStorage = (function() {
    function KvStorage() {
      if (window.cordova || window.NATIVE) {
        return window.localStorage;
      }
      if (window.localStorage) {
        return window.localStorage;
      }
      if (window.sessionStorage) {
        return window.sessionStorage;
      }
      return {
        clear: function() {}
      };
    }

    return KvStorage;

  })();

  angular.module('ng-utils-paliari').service('kvStorageService', [KvStorage]);

}).call(this);
