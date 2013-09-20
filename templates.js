(function(){window.Tmpl = window.Tmpl || {};
function attrs(obj){
  var buf = []
    , terse = obj.terse;
  delete obj.terse;
  var keys = Object.keys(obj)
    , len = keys.length;
  if (len) {
    buf.push('');
    for (var i = 0; i < len; ++i) {
      var key = keys[i]
        , val = obj[key];
      if ('boolean' == typeof val || null == val) {
        if (val) {
          terse
            ? buf.push(key)
            : buf.push(key + '="' + key + '"');
        }
      } else if ('class' == key && Array.isArray(val)) {
        buf.push(key + '="' + escape(val.join(' ')) + '"');
      } else {
        buf.push(key + '="' + escape(val) + '"');
      }
    }
  }
  return buf.join(' ');
}
function escape(html){
  return String(html)
    .replace(/&(?!\w+;)/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}
var jade = {
  attrs: attrs,
  escape: escape
};
Tmpl.repo_item = function anonymous(locals) {
var attrs = jade.attrs, escape = jade.escape;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<span');
buf.push(attrs({ "class": ('badge') }));
buf.push('>');
var __val__ = language
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</span><h3>');
var __val__ = name
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</h3><p');
buf.push(attrs({ "class": ('muted') }));
buf.push('>');
var __val__ = description
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</p>');
}
return buf.join("");
};
})();