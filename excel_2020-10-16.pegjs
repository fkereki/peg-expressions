/*
  Reference for operators:
  https://support.microsoft.com/en-us/office/calculation-operators-and-precedence-in-excel-48be406d-4975-4d31-b2b8-7af9e0e2878a

*/

{
  options = {
    ...options,
    values: {
      today: "2020-09-22",
      future: "2020-10-11",
      rate: 1.25,
      dollar_to_euro: 1.1,
      dollar_in_uyp: 43,
      money: 100000,
    },
  };

  const DAY_IN_MS = 24 * 60 * 60 * 1000;

  const isDate = (str) =>
    typeof str === "string" && !!str.match(/\d\d\d\d-\d?\d-\d?\d/);

  const datePlusDays = (str, days) =>
    new Date(new Date(str).getTime() + days * DAY_IN_MS)
      .toISOString()
      .substr(0, 10);

  const dateMinusDate = (str1, str2) =>
    (new Date(str1).getTime() - new Date(str2).getTime()) / DAY_IN_MS;

  const addVal1Val2 = (val1, val2) => {
    if (isDate(val1) && Number.isInteger(val2)) {
      return datePlusDays(val1, Number(val2));
    } else if (isDate(val2) && Number.isInteger(val1)) {
      return datePlusDays(val2, Number(val1));
    } else {
      return Number(val1) + Number(val2);
    }
  };

  const subVal1Val2 = (val1, val2) => {
    if (isDate(val1) && isDate(val2)) {
      return dateMinusDate(val1, val2);
    } else if (isDate(val1) && Number.isInteger(val2)) {
      return datePlusDays(val1, -Number(val2));
    } else {
      return Number(val1) - Number(val2);
    }
  };
}

/*
  NOTE: the name of an end token (one that does not involve other tokens)
  ends with "_" if the token includes the following whitespace
*/

EXCEL "expression"
  = EQ_ val:EXPR EOF { return val; }

EXPR
  = val:EXP_C rest:(PCT_)? {
    const ret = rest? val / 100 : val;
    // console.log("EXPR", val, rest, ret);
    return ret;
  }

EXP_C
  = val1:EXP_AS rest:((GE_/GT_/NE_/LE_/LT_/EQ_) EXP_AS)? {
    const ret =
        rest && rest[0][0] === ">=" ? val1 >= rest[1]
      : rest && rest[0][0] === ">"  ? val1 >  rest[1]
      : rest && rest[0][0] === "<>" ? val1 != rest[1]
      : rest && rest[0][0] === "<=" ? val1 <= rest[1]
      : rest && rest[0][0] === "<"  ? val1 <  rest[1]
      : rest && rest[0][0] === "="  ? val1 == rest[1]
      : val1;
    // console.log("EXP_C", val1, rest, ret);
    return ret;
  }

EXP_AS
  = val1:EXP_PD rest:((PLUS_/MINUS_/CONCAT_) EXP_AS)? {
    const ret =
        rest && rest[0][0] === "+" ? addVal1Val2(val1, rest[1])
      : rest && rest[0][0] === "-" ? subVal1Val2(val1, rest[1])
      : rest && rest[0][0] === "&" ? String(val1) + String(rest[1])
      : val1;
    // console.log("EXP_AS", val1, rest, ret);
    return ret;
  }

EXP_PD
  = val1:EXP_X  rest:((MULT_/DIV_) EXP_PD)?  {
    const ret =
        rest && rest[0][0] === "*" ? val1 * rest[1]
      : rest && rest[0][0] === "/" ? val1 / rest[1]
      : val1;
    // console.log("EXP_PD", val1, ret);
    return ret;
  }

EXP_X
  = val1:VALUE rest:("^" EXP_X)? {
    const ret = rest? val1 ** rest[1] : val1;
    // console.log("EXP_X", val1, rest, ret);
    return ret;
  }

VALUE "value"
  = LPAREN_ val:EXPR RPAREN_ {
    return val;
  }

  /*
    String related functions
  */

  / "CONCAT"i _ LPAREN_ val1:EXPR rest:(COMMA_ EXPR)* RPAREN_ {
    return rest.reduce((acc, element) => acc + String(element[1]), String(val1));
  }

  / "STARTS"i _ LPAREN_ val1:EXPR COMMA_ val2:EXPR RPAREN_ {
    return String(val1).startsWith(String(val2));
  }

  / "INCLUDES"i _ LPAREN_ val1:EXPR COMMA_ val2:EXPR RPAREN_ {
    return String(val1).includes(String(val2));
  }

  /*
    Numeric functions
  */

  / MINUS_ val:VALUE  {
    return -val;
  }

  / "POWER"i _ LPAREN_ base:EXPR COMMA_ exp:EXPR RPAREN_ {
    return Number(base) ** Number(exp);
  }

  / "ROUND"i _ LPAREN_ num:EXPR COMMA_ prec:EXPR RPAREN_ {
    const fac=10**Number(prec); return Math.round(Number(num)*fac)/fac;
  }

  / "LN"i _ LPAREN_ val:EXPR RPAREN_ {
    return Math.log(Number(val));
  }

  / "LOG10"i _ LPAREN_ val:EXPR RPAREN_ {
    return Math.log10(Number(val));
  }

  / "LOG"i _ LPAREN_ val:EXPR COMMA_ base:EXPR RPAREN_ {
    return Math.log(Number(val)) / Math.log(base);
  }

  /*
    Logical functions
  */

  / "IF"i _ LPAREN_ val:EXPR COMMA_ tVal:EXPR COMMA_ fVal:EXPR RPAREN_ {
    return val ? tVal : fVal;
  }

  / "OR"i _ LPAREN_ val1:EXPR rest:(COMMA_ EXPR)* RPAREN_ {
    return rest.reduce((acc, element) => acc || !!element[3], !!val1);
  }

  / "AND"i _ LPAREN_ val1:EXPR rest:(COMMA_ EXPR)* RPAREN_ {
    return rest.reduce((acc, element) => acc && !!element[3], !!val1);
  }

  / "NOT"i _ LPAREN_ val:EXPR RPAREN_ {
    return (!val);
  }

  / "FALSE"i _ LPAREN_ RPAREN_ {
    return false;
  }

  / "TRUE"i _ LPAREN_ RPAREN_ {
    return true;
  }

  /*
    Numbers, strings, and variables
    NOTE: when no "return" is specified, the associated
    return value is returned by default
  */

  / NUM_
  / VAR_
  / STR_

NUM_
  = digits:DIGIT+ frac:("." DIGIT+)? _ {
    return frac ?
      Number(digits.join("")+frac.flat().join(""))
    : Number(digits.join(""));
  }
 
VAR_
  = char1:LETTER chars:(LETTER / DIGIT)* _  {
    const varName = [char1, ...chars].join("");
    return options.values[varName];
  }

STR_
  = DQUOTE chars:(!DQUOTE .)* DQUOTE _ {
    return chars.map(c => c[1]).join("");
  }
  / SQUOTE chars:(!SQUOTE .)* SQUOTE _ {
    return chars.map(c => c[1]).join("");
  }

/*
  End tokens
  If the name ends with _ it means
  that it includes whitespace
*/

COMMA_  = "," _
CONCAT_ = "&" _
DIGIT   = [0-9]
DIV_    = "/" _
DQUOTE  = "\""
EQ_     = "=" _
GE_     = ">=" _
GT_     = ">" _
LE_     = "<=" _
LETTER  = [A-Za-z_$]
LPAREN_ = "(" _
LT_     = "<" _
MINUS_  = "-" _
MULT_   = "*" _
NE_     = "<>" _
PCT_    = "%" _
PLUS_   = "+" _
POWER_  = "^" _
RPAREN_ = ")" _
SQUOTE  = "'"
VARALL  = LETTER / DIGIT

/*
  Whitespace and EOF
*/

_       = [ \t\n\r]*
EOF     = !.