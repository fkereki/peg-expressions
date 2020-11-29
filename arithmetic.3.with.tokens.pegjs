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
  = _ EQ _ val1:EXPR _ { return val1; }

EXPR = EXP_C

EXP_C
  = _ val1:EXP_AS _ GT _ val2:EXP_AS _ { return val1 > val2; }
  / _ val1:EXP_AS _ GE _ val2:EXP_AS _ { return val1 >= val2; }
  / _ val1:EXP_AS _ LT _ val2:EXP_AS _ { return val1 < val2; }
  / _ val1:EXP_AS _ LE _ val2:EXP_AS _ { return val1 <= val2; }
  / _ val1:EXP_AS _ EQ _ val2:EXP_AS _ { return val1 == val2; }
  / _ val1:EXP_AS _ NE _ val2:EXP_AS _ { return val1 != val2; }
  / _ val1:EXP_AS _ { return val1; }

EXP_AS
  = _ val1:EXP_PD _ PLUS  _ val2:EXP_AS _ { return val1 + val2; }
  / _ val1:EXP_PD _ MINUS _ val2:EXP_AS _ { return val1 - val2; }
  / _ val1:EXP_PD _ { return val1; }

EXP_PD
  = _ val1:EXP_X _ MULT _ val2:EXP_PD _ { return val1 * val2; }
  / _ val1:EXP_X _ DIV  _ val2:EXP_PD _ { return val1 / val2; }
  / _ val1:EXP_X _ { return val1; }

EXP_X
  = _ val1:VALUE _ CARET _ val2:EXP_X _ { return val1 ** val2; }
  / _ val1:VALUE _ { return val1; }

VALUE
  = _ MINUS _ val1:VALUE _ { return -val1; }
  / _ LPAREN _ val1:EXPR _ RPAREN _ { return val1; }

  / _ IF  _ LPAREN _ cVal:EXPR _ COMMA _ tVal:EXPR _ COMMA _ fVal:EXPR _ RPAREN _ { return !!cVal ? tVal : fVal; }
  / _ OR _ LPAREN _ val1:EXPR _ COMMA _ val2:EXPR _ RPAREN _ { return !!val1 || !!val2; }
  / _ AND _ LPAREN _ val1:EXPR _ COMMA _ val2:EXPR _ RPAREN _ { return !!val1 && !!val2; }
  / _ NOT _ LPAREN _ val1:EXPR _ RPAREN _ { return (!val1); }  
  / _ FALSE _ LPAREN _ RPAREN _ { return false; }
  / _ TRUE _ LPAREN _ RPAREN _ { return true; }

  / _ POWER _ LPAREN _ val1:EXPR _ COMMA _ val2:EXPR _ RPAREN _ { return val1 ** val2; }
  / _ ROUND _ LPAREN _ val1:EXPR _ COMMA _ val2:EXPR _ RPAREN _ { return myRound(val1, val2); }
  / _ LOG10 _ LPAREN _ val1:EXPR _ RPAREN _ { return Math.log10(val1); }
  / _ LOG _ LPAREN _ val1:EXPR _ COMMA _ val2:EXPR _ RPAREN _ { return myLog(val1, val2); }
  / _ LN _ LPAREN _ val1:EXPR _ RPAREN _ { return Math.log(val1); }

  / _ val1:NUMBER _ { return val1; }
  / _ val1:VARIABLE _ { return val1; }

NUMBER
  = _ digits:(DIGIT+ DOT DIGIT+) _ { return Number(digits.flat().join("")); }
  / _ digits:DIGIT+ _ { return Number(digits.join("")); }

VARIABLE
  = _ char1:LETTER chars:(LETTER / DIGIT)* _ {
    const varName = char1 + chars.join("");
    return options.values[varName];
  }

/*
  End tokens
*/

CARET  = "^"
COMMA  = ","
DIGIT  = [0-9]
DIV    = "/"
DOT    = "."
EQ     = "="
GE     = ">="
GT     = ">"
LE     = "<="
LETTER = [a-zA-Z_]
LPAREN = "("
LT     = "<"
MINUS  = "-"
MULT   = "*"
NE     = "<>"
PLUS   = "+"
RPAREN = ")"

/*
  Math Functions
*/
LN       = "LN"i
LOG      = "LOG"i
LOG10    = "LOG10"i
POWER    = "POWER"i
ROUND    = "ROUND"i

/*
  Logical Functions
*/
AND      = "AND"i
FALSE    = "FALSE"i
IF       = "IF"i
NOT      = "NOT"i
OR       = "OR"i
TRUE     = "TRUE"i

/*
  Whitespace and EOF
*/

_       = [ \t\n\r]*
EOF     = !.