(function() {
  this.Steak = {};

  Steak.String = {
    isSteakObject: true,
    createNew: function(value) {
      return value.toString();
    },
    jsonFrom: function(value) {
      return value;
    }
  };

  Steak.Object = {
    isSteakObject: true,
    createNew: function(value) {
      return value;
    },
    jsonFrom: function(value) {
      return value;
    }
  };

  Steak.Boolean = {
    isSteakObject: true,
    createNew: function(value) {
      return !!value;
    },
    jsonFrom: function(value) {
      return value;
    }
  };

  Steak.Integer = {
    isSteakObject: true,
    createNew: function(value) {
      return parseInt(value);
    },
    jsonFrom: function(value) {
      return value;
    }
  };

  Steak.Float = {
    isSteakObject: true,
    createNew: function(value) {
      return parseFloat(value);
    },
    jsonFrom: function(value) {
      return value;
    }
  };

  Steak.Date = {
    isSteakObject: true,
    createNew: function(value) {
      return new Date(value);
    },
    jsonFrom: function(value) {
      return value.toString();
    }
  };

  Steak.ArrayOf = function(objectClass) {
    return {
      isSteakObject: true,
      createNew: function(values) {
        var arr, obj, value, _i, _len;
        arr = [];
        for (_i = 0, _len = values.length; _i < _len; _i++) {
          value = values[_i];
          obj = objectClass.createNew(value);
          arr.push(obj);
        }
        return arr;
      },
      jsonFrom: function(values) {
        var arr, obj, value, _i, _len;
        arr = [];
        for (_i = 0, _len = values.length; _i < _len; _i++) {
          value = values[_i];
          obj = objectClass.jsonFrom(value);
          arr.push(obj);
        }
        return arr;
      }
    };
  };

  Steak.Model = Ember.Object.extend({
    writeAttributes: function(opts) {
      var attr, attributes, camelCaseKey, classObject, dataToWrite, key, newValue, value;
      if (opts == null) {
        opts = {};
      }
      attributes = this.get("attributes");
      this.set("_originalData", opts);
      dataToWrite = {};
      for (key in opts) {
        value = opts[key];
        camelCaseKey = key.camelize();
        attr = attributes[camelCaseKey];
        if (attr) {
          if (attr.isSteakObject) {
            classObject = attr;
          } else {
            classObject = attr["class"];
          }
          if (value !== null) {
            newValue = classObject.createNew(value);
            if (attr.saveParent) {
              newValue.set('parent', this);
            }
            dataToWrite[camelCaseKey] = newValue;
          }
        }
      }
      return this.setProperties(dataToWrite);
    },
    toJson: function() {
      var actualValue, attributes, classObject, data, jsonValue, key, snakeCaseKey, value;
      attributes = this.get("attributes");
      data = {};
      for (key in attributes) {
        value = attributes[key];
        snakeCaseKey = key.underscore();
        if (value.isSteakObject) {
          classObject = value;
        } else {
          classObject = value["class"];
        }
        actualValue = this.get(key);
        if (actualValue) {
          jsonValue = classObject.jsonFrom(this.get(key));
          data[snakeCaseKey] = jsonValue;
        } else {
          data[snakeCaseKey] = "";
        }
      }
      return data;
    },
    rollback: function() {
      var originalData;
      originalData = this.get("_originalData");
      return this.writeAttributes(originalData);
    },
    update: function(attributes) {
      return this.constructor.repository.update(this, attributes);
    },
    save: function(attributes) {
      return this.constructor.repository.save(this, attributes);
    }
  });

  Steak.Model.reopenClass({
    isSteakObject: true,
    createNew: function(opts) {
      var newObject;
      if (opts == null) {
        opts = {};
      }
      newObject = this.create();
      newObject.writeAttributes(opts);
      return newObject;
    },
    jsonFrom: function(object) {
      return object.toJson();
    },
    findAll: function(attributes) {
      var repo, steakModel;
      steakModel = this;
      repo = steakModel.repository;
      if(repo.findAllQuery === undefined){
        throw("Repository does not implement .findAllQuery()")
      }
      if(repo.typeKeyCollection === undefined){
        throw("Repository does not implement .typeKeyCollection()")
      }
      return repo.findAllQuery(attributes).then(function(data) {
        var array, obj, object, _i, _len, _ref;
        array = [];
        _ref = data[repo.typeKeyCollection];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          object = _ref[_i];
          obj = steakModel.createNew(object);
          array.push(obj);
        }
        array.isFulfilled = true;
        return array;
      });
    },
    find: function(attributes, opts) {
      var repo, steakModel;
      if (opts == null) {
        opts = {};
      }
      steakModel = this;
      repo = steakModel.repository;

      if(repo.findQuery === undefined){
        throw("Repository does not implement .findQuery()")
      }
      if(repo.typeKeySingle === undefined){
        throw("Repository does not implement .typeKeySingle()")
      }
      return repo.findQuery(attributes, opts).then(function(data) {
        return steakModel.createNew(data[repo.typeKeySingle]);
      });
    },
    registerRepository: function(repository) {
      return this.repository = repository;
    }
  });

}).call(this);