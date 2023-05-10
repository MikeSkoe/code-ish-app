module type PARSABLE = {
   type t;
   let show : t => string
   let parse : string => option<t>
}

module type SHOWER = {
   type t;
   // First string is the word, the second is translation
   let wrapNoun : list<(bool, string, string)> => t;
   let wrapVerb : list<(bool, string, string)> => t;
   let wrapAd : list<(bool, string, string)> => t;
   let wrapConj : (string, string) => t;
   let wrapMark : string => t;
   let wrapPunctuation : string => t;
}

type term = {
   str: string,
   noun: string,
   verb: string,
   ad: string,
   description: string,
}

type conjTerm = {
   str: string,
   definition: string,
   description: string,
}

module type CONJ_DICTIONARY = {
   include PARSABLE with type t := conjTerm
   let nounMark : string
   let verbMark : string
   let adMark : string
   let mem : string => bool
   let translate : string => promise<option<conjTerm>>
}

module type TERMIN_DICTIONARY = {
   include PARSABLE with type t := term
   let translate : string => promise<option<term>>
}
