{
  options = {
    ...options,
    values: {
      rate: 1.25,
      dollar_to_euro: 1.1,
      dollar_in_uyp: 43,
      money: 100000,
    },
  };

  function myRound(val1, val2) {
    const fac=10**val2;
    return Math.round(val1*fac)/fac;
  }

  function myLog(val1, val2) {
    return Math.log(val1) / Math.log(val2);
  }
}

EXCEL
  = _ EQ_ val:EXPR EOF { return val; }

EXPR = EXP_C

EXP_C
  = val1:EXP_AS GT_ val2:EXP_AS { return val1 > val2; }
  / val1:EXP_AS GE_ val2:EXP_AS { return val1 >= val2; }
  / val1:EXP_AS LT_ val2:EXP_AS { return val1 < val2; }
  / val1:EXP_AS LE_ val2:EXP_AS { return val1 <= val2; }
  / val1:EXP_AS EQ_ val2:EXP_AS { return val1 == val2; }
  / val1:EXP_AS NE_ val2:EXP_AS { return val1 != val2; }
  / val1:EXP_AS { return val1; }

EXP_AS
  = val1:EXP_PD rest:((PLUS_/MINUS_) EXP_PD)* {
    return rest.reduce(
        (acc, element) =>
            element[0][0] === "+" ? acc + element[1] : acc - element[1],
        val1
    );
  }

EXP_PD
  = val1:EXP_X  rest:((MULT_/DIV_) EXP_X)*  {
    return rest.reduce(
        (acc, element) =>
            element[0][0] === "*" ? acc * element[1] : acc / element[1],
        val1
    );
  }

EXP_X
  = val1:VALUE CARET_ val2:EXP_X { return val1 ** val2; }
  / val1:VALUE { return val1; }

VALUE
  = MINUS_ val1:VALUE { return -val1; }
  / LPAREN_ val1:EXPR RPAREN_ { return val1; }

  / IF_ LPAREN_ cVal:EXPR COMMA_ tVal:EXPR COMMA_ fVal:EXPR RPAREN_ { return !!cVal ? tVal : fVal; }
  / OR_ LPAREN_ val1:EXPR COMMA_ val2:EXPR RPAREN_ { return !!val1 || !!val2; }
  / AND_ LPAREN_ val1:EXPR COMMA_ val2:EXPR RPAREN_ { return !!val1 && !!val2; }
  / NOT_ LPAREN_ val1:EXPR RPAREN_ { return (!val1); }  
  / FALSE_ LPAREN_ RPAREN_ { return false; }
  / TRUE_ LPAREN_ RPAREN_ { return true; }

  / POWER_ LPAREN_ val1:EXPR COMMA_ val2:EXPR RPAREN_ { return val1 ** val2; }
  / ROUND_ LPAREN_ val1:EXPR COMMA_ val2:EXPR RPAREN_ { return myRound(val1, val2); }
  / LOG10_ LPAREN_ val1:EXPR RPAREN_ { return Math.log10(val1); }
  / LOG_ LPAREN_ val1:EXPR COMMA_ val2:EXPR RPAREN_ { return myLog(val1, val2); }
  / LN_ LPAREN_ val1:EXPR RPAREN_ { return Math.log(val1); }

  / val1:NUMBER { return val1; }
  / val1:VARIABLE { return val1; }

NUMBER
  = digits:(DIGIT+ DOT DIGIT+) _ { return Number(digits.flat().join("")); }
  / digits:DIGIT+ _ { return Number(digits.join("")); }

VARIABLE
  = char1:LETTER chars:(LETTER / DIGIT)* _  {
    const varName = char1 + chars.join("");
    return options.values[varName];
  }

/*
  End tokens
  If the name ends with _ it means
  that it includes whitespace
*/

CARET_  = "^" _
COMMA_  = "," _
DIGIT   = [0-9]
DIV_    = "/" _
DOT     = "."
EQ_     = "=" _
GE_     = ">=" _
GT_     = ">" _
LE_     = "<=" _
LETTER  = [a-zA-Z_]
LPAREN_ = "(" _
LT_     = "<" _
MINUS_  = "-" _
MULT_   = "*" _
NE_     = "<>" _
PLUS_   = "+" _
RPAREN_ = ")" _

/*
  Math Functions
*/
LN_       = "LN"i _
LOG_      = "LOG"i _
LOG10_    = "LOG10"i _
POWER_    = "POWER"i _
ROUND_    = "ROUND"i _

/*
  Logical Functions
*/
AND_      = "AND"i _
FALSE_    = "FALSE"i _
IF_       = "IF"i _
NOT_      = "NOT"i _
OR_       = "OR"i _
TRUE_     = "TRUE"i _

/*
  Whitespace and EOF
*/

_       = [ \t\n\r]*
EOF     = !.