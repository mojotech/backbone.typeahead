(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    slice = [].slice;

  Backbone.TypeaheadCollection = (function(superClass) {
    extend(TypeaheadCollection, superClass);

    function TypeaheadCollection() {
      return TypeaheadCollection.__super__.constructor.apply(this, arguments);
    }

    TypeaheadCollection.prototype.tokenizeQuery = function(s) {
      return this._tokenize(s);
    };

    TypeaheadCollection.prototype.tokenizeAttribute = function(s) {
      return this._tokenize(s);
    };

    TypeaheadCollection.prototype._tokenize = function(s) {
      if (s == null) {
        s = '';
      }
      s = s.trim();
      if (s.length === 0) {
        return null;
      }
      return s.toLowerCase().split(/[\s\-_]+/);
    };


    /*
      Recursive method for walking an object as defined by an
      array. Returns the value of the last key in the array
      sequence.
      @private
      @method _deepObjectMap
      @param {Object} Object to walk
      @param {Array} Keys to walk the object with
      @return {Value} Last value from the object by array walk
    
      @example
        _deepObjectMap
          key:
            key2:
              key3: "val"
          , ['key', 'key2', 'key3']
         * Returns "val"
     */

    TypeaheadCollection.prototype._deepObjectMap = function(obj, attrs) {
      if (!(attrs.length > 0 && _.isObject(obj))) {
        return obj;
      }
      if (attrs.length === 1) {
        return obj[attrs[0]];
      }
      return this._deepObjectMap(obj[attrs[0]], attrs.slice(1, attrs.length));
    };


    /*
      Split each typeaheadAttribute into an array of nested methods
      and return an array map the returned values from deepObjectMap.
      @private
      @method _getAttributeValues
      @param {Backbone.Model} Model to fetch and map values from
      @return {Array} Values from model retrieved by _deepObjectMap
     */

    TypeaheadCollection.prototype._getAttributeValues = function(model) {
      return _.map(this.typeaheadAttributes, (function(_this) {
        return function(att) {
          var attArray;
          attArray = att.split('.');
          return _this._deepObjectMap(model.get(attArray[0]), attArray.slice(1));
        };
      })(this));
    };

    TypeaheadCollection.prototype._extractValues = function(model) {
      if (this.typeaheadAttributes != null) {
        return this._getAttributeValues(model);
      } else {
        return _.values(model.attributes);
      }
    };

    TypeaheadCollection.prototype._tokenizeModel = function(model) {
      return _.uniq(this.tokenizeAttribute(_.flatten(this._extractValues(model)).join(' ')));
    };

    TypeaheadCollection.prototype._addToIndex = function(models) {
      var adjacency, character, i, id, len, model, results, t, tokens;
      if (!_.isArray(models)) {
        models = [models];
      }
      results = [];
      for (i = 0, len = models.length; i < len; i++) {
        model = models[i];
        tokens = this._tokenizeModel(model);
        id = model.id != null ? model.id : model.cid;
        this._tokens[id] = tokens;
        results.push((function() {
          var base, j, len1, results1;
          results1 = [];
          for (j = 0, len1 = tokens.length; j < len1; j++) {
            t = tokens[j];
            character = t.charAt(0);
            adjacency = (base = this._adjacency)[character] || (base[character] = [id]);
            if (!~_.indexOf(adjacency, id)) {
              results1.push(adjacency.push(id));
            } else {
              results1.push(void 0);
            }
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    TypeaheadCollection.prototype._removeFromIndex = function(models) {
      var i, id, ids, k, len, ref, results, v;
      if (!_.isArray(models)) {
        models = [models];
      }
      ids = _.map(models, function(m) {
        if (m.id != null) {
          return m.id;
        } else {
          return m.cid;
        }
      });
      for (i = 0, len = ids.length; i < len; i++) {
        id = ids[i];
        delete this._tokens[id];
      }
      ref = this._adjacency;
      results = [];
      for (k in ref) {
        v = ref[k];
        results.push(this._adjacency[k] = _.without.apply(_, [v].concat(slice.call(ids))));
      }
      return results;
    };

    TypeaheadCollection.prototype._rebuildIndex = function() {
      this._adjacency = {};
      this._tokens = {};
      return this._addToIndex(this.models);
    };

    TypeaheadCollection.prototype.typeaheadIndexer = function(facets) {
      if (!((facets != null) && _.keys(facets).length > 0)) {
        return null;
      }
      return _.map(this.where(facets), function(m) {
        if (m.id != null) {
          return m.id;
        } else {
          return m.cid;
        }
      });
    };

    TypeaheadCollection.prototype.typeahead = function(query, facets) {
      var checkIfShortestList, facetList, firstChars, i, id, isCandidate, isMatch, item, len, lists, queryTokens, shortestList, suggestions;
      if (this._adjacency == null) {
        throw new Error('Index is not built');
      }
      queryTokens = this.tokenizeQuery(query);
      lists = [];
      shortestList = null;
      firstChars = _(queryTokens).chain().map(function(t) {
        return t.charAt(0);
      }).uniq().value();
      checkIfShortestList = (function(_this) {
        return function(list) {
          if (list.length <= ((shortestList != null ? shortestList.length : void 0) || _this.length)) {
            return shortestList = list;
          }
        };
      })(this);
      _.every(firstChars, (function(_this) {
        return function(firstChar) {
          var list;
          list = _this._adjacency[firstChar];
          if (list == null) {
            return false;
          }
          lists.push(list);
          checkIfShortestList(list);
          return true;
        };
      })(this));
      if (lists.length < firstChars.length) {
        return [];
      }
      facetList = this.typeaheadIndexer(facets);
      if (facetList != null) {
        lists.push(facetList);
        checkIfShortestList(facetList);
      }
      if (shortestList == null) {
        return this.models;
      }
      if (shortestList.length === 0) {
        return [];
      }
      suggestions = [];
      for (i = 0, len = shortestList.length; i < len; i++) {
        id = shortestList[i];
        isCandidate = _.every(lists, function(list) {
          return ~_.indexOf(list, id);
        });
        isMatch = isCandidate && _.every(queryTokens, (function(_this) {
          return function(qt) {
            return _.some(_this._tokens[id], function(t) {
              return t.indexOf(qt) === 0;
            });
          };
        })(this));
        if (isMatch) {
          item = this.get(id);
          if (this.typeaheadPreserveOrder) {
            suggestions[this.indexOf(item)] = item;
          } else {
            suggestions.push(item);
          }
        }
      }
      if (this.typeaheadPreserveOrder) {
        return _.compact(suggestions);
      } else {
        return suggestions;
      }
    };

    TypeaheadCollection.prototype._reset = function() {
      this._tokens = {};
      this._adjacency = {};
      return TypeaheadCollection.__super__._reset.apply(this, arguments);
    };

    TypeaheadCollection.prototype.set = function() {
      var models;
      models = TypeaheadCollection.__super__.set.apply(this, arguments);
      if (!_.isArray(models)) {
        models = [models];
      }
      this._rebuildIndex(models);
      return models;
    };

    TypeaheadCollection.prototype.remove = function() {
      var models;
      models = TypeaheadCollection.__super__.remove.apply(this, arguments);
      if (!_.isArray(models)) {
        models = [models];
      }
      this._removeFromIndex(models);
      return models;
    };

    TypeaheadCollection.prototype._onModelEvent = function(event, model, collection, options) {
      var add, changeEventList;
      if (model != null) {
        add = false;
        if (event === ("change:" + model.idAttribute)) {
          add = true;
          this._removeFromIndex({
            id: model.previous(model.idAttribute)
          });
        } else if (event.indexOf('change:') === 0) {
          changeEventList = _.map(this.typeaheadAttributes, function(att) {
            return 'change:' + att;
          });
          if ((this.typeaheadAttributes == null) || _.contains(changeEventList, event)) {
            add = true;
            this._removeFromIndex(model);
          }
        }
        if (add) {
          this._addToIndex(model);
        }
      }
      return TypeaheadCollection.__super__._onModelEvent.apply(this, arguments);
    };

    return TypeaheadCollection;

  })(Backbone.Collection);

}).call(this);

//# sourceMappingURL=backbone.typeahead.js.map
