include AbstractDict

open Belt

let combMark = '-'
let combMarkString = "-"

module Make = (
   Marks: MARKS,
   Show: SHOWER,
): (
   LANGUAGE with
      type presentation = Show.t and
      type dictionary = MyDict.t<list<string>>
) => {
   type presentation = Show.t;
   type dictionary = MyDict.t<list<string>>;
   type rec t =
      | Start(t)
      | Noun(string, t)
      | Verb(string, t)
      | Ad(string, t)
      | Con(string, t)
      | End;

   let empty = Start(End);
   let rec translate : (string, dictionary) => option<list<string>>
      = (str, dict) => {
         if str == "" {
             None
         } else {
             MyDict.find_opt(str, dict)
             -> Option.orElse(
                switch String.split_on_char('-', str) {
                   | list{} => None
                   | list{_} => None
                   | list{word, ...next} =>
                      translate(word, dict)
                      -> Option.orElse(translate(next -> Utils.concatWords, dict))
                }
             )
         }
      }

   // TODO: change to (string, dictionary) => t
   let parse: (dictionary, string) => t
      = (marks, str) => {
         let isMark : string => bool
            = str =>
               list{Marks.noun, Marks.verb, Marks.ad}
               -> List.some(mark => mark == String.lowercase_ascii(str));

         let toMark : string => mark
            = str => switch String.lowercase_ascii(str) {
               | mark when mark == Marks.noun => AbstractDict.Noun
               | mark when mark == Marks.verb => AbstractDict.Verb
               | _ => AbstractDict.Ad
               
            }

         let isCon : string => bool
            = str =>
                str
                -> String.lowercase_ascii
                -> translate(marks)
                -> Option.isSome;

         let rec iter: (mark, list<string>) => t
            = (mark, strs) => {
               switch (mark, strs) {
                  | (_, list{}) => End
                  | (_, list{con, word, ...next}) when isCon(con) =>
                     Con(con, iter(AbstractDict.Noun, list{word, ...next}))

                  | (something, list{markA, markB, ...next}) when isMark(markA) && isMark(markB) =>
                     iter(something, list{markB, ...next})

                  | (AbstractDict.Noun, list{mark}) when isMark(mark) =>
                     Noun(mark, End)

                  | (AbstractDict.Verb, list{mark}) when isMark(mark) =>
                     Verb(mark, End)

                  | (AbstractDict.Ad, list{mark}) when isMark(mark) =>
                     Ad(mark, End)

                  | (_, list{mark, ...next}) when isMark(mark) =>
                     iter(toMark(mark), next)

                  | (AbstractDict.Noun, list{word, ...next}) =>
                     Noun(word, iter(AbstractDict.Verb, next))

                  | (AbstractDict.Verb, list{word, ...next}) =>
                     Verb(word, iter(AbstractDict.Noun, next))

                  | (AbstractDict.Ad, list{word, ...next}) =>
                     Ad(word, iter(AbstractDict.Ad, next))
               }
            }

         Start(
            iter(
               AbstractDict.Noun,
               String.split_on_char(' ', str)
               -> List.keep(str => str != "")
               -> List.map(String.trim),
            )
         )
      }

   let show: t => list<Show.t>
      = lex => {
         let rec iter: t => list<Show.t>
            = lex => switch lex {
               | End => list{}

               | Noun(root, Ad(root', next))
                  => list{
                     Show.noun(root),
                     Show.mark(Marks.ad),
                     ...iter(Ad(root', next))
                  }
               | Verb(root, Ad(root', next))
                  => list{Show.verb(root), Show.mark(Marks.ad), ...iter(Ad(root', next))}

               | Noun(root, Noun(root', next))
                  => list{Show.noun(root), Show.mark(Marks.noun), ...iter(Noun(root', next))}

               | Verb(root, Verb(root', next))
                  => list{Show.verb(root), Show.mark(Marks.verb), ...iter(Verb(root', next))}

               | Noun(root, next)
                  => list{Show.noun(root), ...iter(next)}
               | Verb(root, next)
                  => list{Show.verb(root), ...iter(next)}

               | Start(Ad(root, next))
                  => list{Show.mark(Marks.ad), ...iter(Ad(root, next))}
               | Start(Verb(root, next))
                  => list{Show.mark(Marks.verb), ...iter(Verb(root, next))}

               | Ad(root, Noun(root', next))
                  => list{Show.ad(root), Show.mark(Marks.noun), ...iter(Noun(root', next))}
               | Ad(root, Verb(root', next))
                  => list{Show.ad(root), Show.mark(Marks.verb), ...iter(Verb(root', next))}
               | Ad(root, next)
                  => list{Show.ad(root), ...iter(next)}

               | Con(con, Ad(root, next))
                  => list{Show.con(con), Show.mark(Marks.ad), ...iter(Ad(root, next))}
               | Con(con, Verb(root, next))
                  => list{Show.con(con), Show.mark(Marks.verb), ...iter(Verb(root, next))}
               | Con(con, next)
                  => list{Show.con(con), ...iter(next)}
               | Start(next) => iter(next)
            }

         iter(lex);
      }

      let rec map : (t, string => string) => t
         = (t, fn) => switch t {
            | Start(next) => Start(next -> map(fn))
            | Noun(str, t) => Noun(fn(str), t -> map(fn))
            | Verb(str, t) => Verb(fn(str), t -> map(fn))
            | Ad(str, t) => Ad(fn(str), t -> map(fn))
            | Con(str, t) => Con(fn(str), t -> map(fn))
            | End => End
         }
}
