/* nlp_compromise v10.6.0 MIT*/
(function(f) {
    if (typeof exports === "object" && typeof module !== "undefined") {
        module.exports = f()
    } else if (typeof define === "function" && define.amd) {
        define([], f)
    } else {
        var g;
        if (typeof window !== "undefined") {
            g = window
        } else if (typeof global !== "undefined") {
            g = global
        } else if (typeof self !== "undefined") {
            g = self
        } else {
            g = this
        }
        g.nlp = f()
    }
})(function() {
    var define, module, exports;
    return (function e(t, n, r) {
        function s(o, u) {
            if (!n[o]) {
                if (!t[o]) {
                    var a = typeof require == "function" && require;
                    if (!u && a) return a(o, !0);
                    if (i) return i(o, !0);
                    var f = new Error("Cannot find module '" + o + "'");
                    throw f.code = "MODULE_NOT_FOUND",
                    f
                }
                var l = n[o] = {
                    exports: {}
                };
                t[o][0].call(l.exports,
                function(e) {
                    var n = t[o][1][e];
                    return s(n ? n: e)
                },
                l, l.exports, e, t, n, r)
            }
            return n[o].exports
        }
        var i = typeof require == "function" && require;
        for (var o = 0; o < r.length; o++) s(r[o]);
        return s
    })({
        4 : [function(_dereq_, module, exports) { (function(global) {
                'use strict';

                var models = {
                    // Text: _dereq_('./text/text.js'),
                    sentence_parser: _dereq_('./sentence_parser'),
                };

                function NLP() {

                    this.sentenceParser = function(s) {
                        return new models.sentence_parser(s);
                    }
                }

                var nlp = new NLP();

                //and then all-the-exports...
                if (typeof self !== 'undefined') {
                    self.nlp = nlp; // Web Worker
                } else if (typeof window !== 'undefined') {
                    window.nlp = nlp; // Browser
                } else if (typeof global !== 'undefined') {
                    global.nlp = nlp; // NodeJS
                }
                //don't forget amd!
                if (typeof define === 'function' && define.amd) {
                    define(nlp);
                }
                //then for some reason, do this too!
                if (typeof module !== 'undefined') {
                    module.exports = nlp;
                }

            }).call(this, typeof global !== "undefined" ? global: typeof self !== "undefined" ? self: typeof window !== "undefined" ? window: {})
        },
        {
            "./sentence_parser": 209
        }],
        9 : [function(_dereq_, module, exports) {
            //these are common word shortenings used in the lexicon and sentence segmentation methods
            //there are all nouns,or at the least, belong beside one.
            'use strict';

            //common abbreviations
            var compact = {
                Noun: ['arc', 'al', 'exp', 'fy', 'pd', 'pl', 'plz', 'tce', 'bl', 'ma', 'ba', 'lit', 'ex', 'eg', 'ie', 'ca', 'cca', 'vs', 'etc', 'esp', 'ft',
                //these are too ambiguous
                'bc', 'ad', 'md', 'corp', 'col'],
                Organization: ['dept', 'univ', 'assn', 'bros', 'inc', 'ltd', 'co',
                //proper nouns with exclamation marks
                'yahoo', 'joomla', 'jeopardy'],

                Place: ['rd', 'st', 'dist', 'mt', 'ave', 'blvd', 'cl', 'ct', 'cres', 'hwy',
                //states
                'ariz', 'cal', 'calif', 'colo', 'conn', 'fla', 'fl', 'ga', 'ida', 'ia', 'kan', 'kans', 'minn', 'neb', 'nebr', 'okla', 'penna', 'penn', 'pa', 'dak', 'tenn', 'tex', 'ut', 'vt', 'va', 'wis', 'wisc', 'wy', 'wyo', 'usafa', 'alta', 'ont', 'que', 'sask'],

                Month: ['jan', 'feb', 'mar', 'apr', 'jun', 'jul', 'aug', 'sep', 'sept', 'oct', 'nov', 'dec'],
                Date: ['circa'],

                //Honorifics
                Honorific: ['adj', 'adm', 'adv', 'asst', 'atty', 'bldg', 'brig', 'capt', 'cmdr', 'comdr', 'cpl', 'det', 'dr', 'esq', 'gen', 'gov', 'hon', 'jr', 'llb', 'lt', 'maj', 'messrs', 'mister', 'mlle', 'mme', 'mr', 'mrs', 'ms', 'mstr', 'op', 'ord', 'phd', 'prof', 'pvt', 'rep', 'reps', 'res', 'rev', 'sen', 'sens', 'sfc', 'sgt', 'sir', 'sr', 'supt', 'surg'
                //miss
                //misses
                ]
            };

            //unpack the compact terms into the misc lexicon..
            var abbreviations = {};
            var keys = Object.keys(compact);
            for (var i = 0; i < keys.length; i++) {
                var arr = compact[keys[i]];
                for (var i2 = 0; i2 < arr.length; i2++) {
                    abbreviations[arr[i2]] = keys[i];
                }
            }
            module.exports = abbreviations;

        },
        {}],
        209 : [function(_dereq_, module, exports) {
            //(Rule-based sentence boundary segmentation) - chop given text into its proper sentences.
            // Ignore periods/questions/exclamations used in acronyms/abbreviations/numbers, etc.
            // @spencermountain 2017 MIT
            'use strict';

            var abbreviations = Object.keys(_dereq_('../lexicon/uncompressed/abbreviations'));
            //regs-
            var abbrev_reg = new RegExp('\\b(' + abbreviations.join('|') + ')[.!?] ?$', 'i');
            var acronym_reg = new RegExp('[ |.][A-Z].?( *)?$', 'i');
            var elipses_reg = new RegExp('\\.\\.+( +)?$');

            //start with a regex:
            var naiive_split = function naiive_split(text) {
                var all = [];
                //first, split by newline
                var lines = text.split(/(\n+)/);
                for (var i = 0; i < lines.length; i++) {
                    //split by period, question-mark, and exclamation-mark
                    var arr = lines[i].split(/(\S.+?[.!?])(?=\s+|$)/g);
                    for (var o = 0; o < arr.length; o++) {
                        all.push(arr[o]);
                    }
                }
                return all;
            };

            var sentence_parser = function sentence_parser(text) {
                text = text || '';
                text = '' + text;
                var sentences = [];
                //first do a greedy-split..
                var chunks = [];
                //ensure it 'smells like' a sentence
                if (!text || typeof text !== 'string' || /\S/.test(text) === false) {
                    return sentences;
                }
                //start somewhere:
                var splits = naiive_split(text);
                //filter-out the grap ones
                for (var i = 0; i < splits.length; i++) {
                    var s = splits[i];
                    if (s === undefined || s === '') {
                        continue;
                    }
                    //this is meaningful whitespace
                    if (/\S/.test(s) === false) {
                        //add it to the last one
                        if (chunks[chunks.length - 1]) {
                            chunks[chunks.length - 1] += s;
                            continue;
                        } else if (splits[i + 1]) {
                            //add it to the next one
                            splits[i + 1] = s + splits[i + 1];
                            continue;
                        }
                    }
                    //else, only whitespace, no terms, no sentence
                    chunks.push(s);
                }

                //detection of non-sentence chunks:
                //loop through these chunks, and join the non-sentence chunks back together..
                for (var _i = 0; _i < chunks.length; _i++) {
                    var c = chunks[_i];
                    //should this chunk be combined with the next one?
                    if (chunks[_i + 1] !== undefined && (abbrev_reg.test(c) || acronym_reg.test(c) || elipses_reg.test(c))) {
                        chunks[_i + 1] = c + (chunks[_i + 1] || '');
                    } else if (c && c.length > 0) {
                        //this chunk is a proper sentence..
                        sentences.push(c);
                        chunks[_i] = '';
                    }
                }
                //if we never got a sentence, return the given text
                if (sentences.length === 0) {
                    return [text];
                }
                return sentences;
            };

            module.exports = sentence_parser;
            // console.log(sentence_parser('john f. kennedy'));
        },
        {
            "../lexicon/uncompressed/abbreviations": 9
        }]
    },
    {},
    [4])(4)
});
