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
  = _ "=" _ val1:EXPR _ { return val1; }

EXPR = EXP_C

EXP_C
  = _ val1:EXP_AS _ ">"  _ val2:EXP_AS _ { return val1 > val2; }
  / _ val1:EXP_AS _ ">=" _ val2:EXP_AS _ { return val1 >= val2; }
  / _ val1:EXP_AS _ "<"  _ val2:EXP_AS _ { return val1 < val2; }
  / _ val1:EXP_AS _ "<=" _ val2:EXP_AS _ { return val1 <= val2; }
  / _ val1:EXP_AS _ "="  _ val2:EXP_AS _ { return val1 == val2; }
  / _ val1:EXP_AS _ "<>" _ val2:EXP_AS _ { return val1 != val2; }
  / _ val1:EXP_AS _ { return val1; }

EXP_AS
  = _ val1:EXP_PD _ "+"  _ val2:EXP_AS _ { return val1 + val2; }
  / _ val1:EXP_PD _ "-"  _ val2:EXP_AS _ { return val1 - val2; }
  / _ val1:EXP_PD _ { return val1; }

EXP_PD
  = _ val1:EXP_X _ "*" _ val2:EXP_PD _ { return val1 * val2; }
  / _ val1:EXP_X _ "/" _ val2:EXP_PD _ { return val1 / val2; }
  / _ val1:EXP_X _ { return val1; }

EXP_X
  = _ val1:VALUE _ "^" _ val2:EXP_X _ { return val1 ** val2; }
  / _ val1:VALUE _ { return val1; }

VALUE
  = _ "-" _ val1:VALUE _ { return -val1; }
  / _ "(" _ val1:EXPR _ ")" _ { return val1; }

  / _ "IF"i  _ "(" _ cVal:EXPR _ "," _ tVal:EXPR _ "," _ fVal:EXPR _ ")" _ { return !!cVal ? tVal : fVal; }
  / _ "OR"i  _ "(" _ val1:EXPR _ "," _ val2:EXPR _ ")" _ { return !!val1 || !!val2; }
  / _ "AND"i _ "(" _ val1:EXPR _ "," _ val2:EXPR _ ")" _ { return !!val1 && !!val2; }
  / _ "NOT"i _ "(" _ val1:EXPR _ ")" _ { return (!val1); }  
  / _ "FALSE"i _ "(" _ ")" _ { return false; }
  / _ "TRUE"i _ "(" _ ")" _ { return true; }

  / _ "POWER"i _ "(" _ val1:EXPR _ "," _ val2:EXPR _ ")" _ { return val1 ** val2; }
  / _ "ROUND"i _ "(" _ val1:EXPR _ "," _ val2:EXPR _ ")" _ { return myRound(val1, val2); }
  / _ "LOG10"i _ "(" _ val1:EXPR _ ")" _ { return Math.log10(val1); }
  / _ "LOG"i _ "(" _ val1:EXPR _ "," _ val2:EXPR _ ")" _ { return myLog(val1, val2); }
  / _ "LN"i _ "(" _ val1:EXPR _ ")" _ { return Math.log(val1); }

  / _ val1:NUMBER _ { return val1; }
  / _ val1:VARIABLE _ { return val1; }

NUMBER
  = _ digits:([0-9]+ "." [0-9]+) _ { return Number(digits.flat().join("")); }
  / _ digits:[0-9]+ _ { return Number(digits.join("")); }

VARIABLE
  = _ char1:[a-zA-Z_] chars:[a-zA-Z_0-9]* _ {
    const varName = char1 + chars.join("");
    return options.values[varName];
  }

_ = [ \t\n\r]*
