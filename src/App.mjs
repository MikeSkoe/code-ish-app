

import * as Lang from "./Lang.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as React from "react";
import * as $$String from "rescript/lib/es6/string.js";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Dictionary from "./library/dictionary.mjs";
import * as Js_promise from "rescript/lib/es6/js_promise.js";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as DictionaryContext from "./components/DictionaryContext.mjs";

import './app.css'
;

function App$Links(props) {
  return React.createElement("div", {
              className: "samples"
            }, React.createElement("p", undefined, React.createElement("a", {
                      href: "https://github.com/MikeSkoe/code-ish-app/blob/main/public/dictionary.csv"
                    }, "Dictionary")), React.createElement("p", undefined, React.createElement("a", {
                      href: "https://github.com/MikeSkoe/code-ish-app/blob/main/public/particles.csv"
                    }, "Particles")), React.createElement("p", undefined, React.createElement("a", {
                      href: "https://github.com/MikeSkoe/code-ish-app/blob/main/public/examples.csv"
                    }, "Examples")));
}

function App$Parser(props) {
  return React.createElement("div", {
              className: "parsed"
            }, Belt_List.toArray(Belt_List.reduce(Belt_List.map($$String.split_on_char(/* '\n' */10, props.text), (function (string) {
                            return React.createElement(React.Fragment, undefined, Belt_List.toArray(Belt_List.reduce(Curry._1(Lang.Lang.Lexs.show, Curry._1(Lang.Lang.Lexs.parse, string)), /* [] */0, (function (acc, curr) {
                                                  if (acc === /* [] */0) {
                                                    return {
                                                            hd: curr,
                                                            tl: /* [] */0
                                                          };
                                                  } else {
                                                    return Belt_List.concatMany([
                                                                acc,
                                                                {
                                                                  hd: " ",
                                                                  tl: {
                                                                    hd: curr,
                                                                    tl: /* [] */0
                                                                  }
                                                                }
                                                              ]);
                                                  }
                                                }))));
                          })), /* [] */0, (function (acc, curr) {
                        if (acc === /* [] */0) {
                          return {
                                  hd: curr,
                                  tl: /* [] */0
                                };
                        } else {
                          return Belt_List.concatMany([
                                      acc,
                                      {
                                        hd: React.createElement("br", undefined),
                                        tl: {
                                          hd: curr,
                                          tl: /* [] */0
                                        }
                                      }
                                    ]);
                        }
                      }))));
}

function App$Hint(props) {
  return React.createElement("div", {
              className: "box hint"
            }, Belt_Option.getWithDefault(Belt_Option.map(props.hint, (function (param) {
                        return React.createElement(React.Fragment, undefined, React.createElement("h3", undefined, param.str), "noun: " + param.noun + "", React.createElement("br", undefined), React.createElement("span", {
                                        className: "verb"
                                      }, "verb: " + param.verb + ""), React.createElement("br", undefined), React.createElement("span", {
                                        className: "ad"
                                      }, "ad: " + param.ad + ""), React.createElement("br", undefined), "description: " + param.description + "");
                      })), React.createElement(React.Fragment, undefined)), React.createElement(App$Links, {}));
}

function App$InputPage(props) {
  var match = React.useState(function () {
        return "my";
      });
  var setQuery = match[1];
  var query = match[0];
  var divRef = React.useRef(null);
  var match$1 = React.useState(function () {
        
      });
  var setHint = match$1[1];
  var match$2 = React.useState(function () {
        return true;
      });
  var setIsEditMode = match$2[1];
  var isEditMode = match$2[0];
  var match$3 = React.useState(function () {
        return "";
      });
  var setInput = match$3[1];
  var onChange = function ($$event) {
    var target = $$event.target;
    var innerText = target.innerText;
    var innerHtml = target.innerHTML;
    Curry._1(setInput, (function (param) {
            return innerText;
          }));
    if (innerHtml.includes("<p")) {
      console.log(innerText);
      console.log(innerHtml);
      target.innerText = innerText;
      return ;
    }
    
  };
  React.useEffect((function () {
          Js_promise.then_((function (all) {
                  return Promise.resolve(Curry._1(setHint, (function (param) {
                                    return Belt_List.getBy(all, (function (term) {
                                                  return term.str === query;
                                                }));
                                  })));
                }), Dictionary.Term.all);
        }), [query]);
  return React.createElement(DictionaryContext.OnWordClickProvider.make, {
              value: (function (str) {
                  Curry._1(setQuery, (function (param) {
                          return str;
                        }));
                }),
              children: null
            }, React.createElement("div", {
                  className: "box area"
                }, React.createElement(App$Parser, {
                      text: match$3[0]
                    }), React.createElement("div", {
                      ref: Caml_option.some(divRef),
                      className: isEditMode ? "editable" : "nonEditable",
                      contentEditable: true,
                      spellCheck: false,
                      inputMode: "text",
                      onInput: onChange
                    })), React.createElement("input", {
                  className: "switch",
                  type: "checkbox",
                  onClick: (function (param) {
                      Curry._1(setIsEditMode, (function (is) {
                              return !is;
                            }));
                    })
                }), isEditMode ? null : React.createElement(App$Hint, {
                    hint: match$1[0]
                  }));
}

function App(props) {
  return React.createElement(DictionaryContext.make, {
              children: null
            }, React.createElement("h1", undefined, React.createElement("b", undefined, "taal")), React.createElement(App$InputPage, {}));
}

var make = App;

export {
  make ,
}
/*  Not a pure module */
