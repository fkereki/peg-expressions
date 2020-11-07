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

  function myRound(val1, val2) {
    const fac=10**Number(val2);
    return Math.round(Number(val1)*fac)/fac;
  }

  function myLog(val1, val2) {
    return Math.log(Number(val1)) / Math.log(val2);
  }
}

EXCEL
  = _ "=" _ val1:COMP _ { return val1; }

COMP
  = _ val1:EXPR _ ">"  _ val2:COMP _ { return val1 > val2; }
  / _ val1:EXPR _ ">=" _ val2:COMP _ { return val1 >= val2; }
  / _ val1:EXPR _ "<"  _ val2:COMP _ { return val1 < val2; }
  / _ val1:EXPR _ "<=" _ val2:COMP _ { return val1 <= val2; }
  / _ val1:EXPR _ "="  _ val2:COMP _ { return val1 == val2; }
  / _ val1:EXPR _ "<>" _ val2:COMP _ { return val1 != val2; }
  / _ val1:EXPR _ { return val1; }

EXPR
  = _ val1:TERM _ "+"  _ val2:EXPR _ { return val1 + val2; }
  / _ val1:TERM _ "-"  _ val2:EXPR _ { return val1 - val2; }
  / _ val1:TERM _ { return val1; }

TERM
  = _ val1:FACTOR _ "*" _ val2:TERM _ { return val1 * val2; }
  / _ val1:FACTOR _ "/" _ val2:TERM _ { return val1 / val2; }
  / _ val1:FACTOR _ { return val1; }

FACTOR
  = _ val1:VALUE _ "^" _ val2:FACTOR _ { return val1 ** val2; }
  / _ val1:VALUE _ { return val1; }

VALUE
  = _ "-" _ val1:VALUE _ { return -val1; }
  / _ "(" _ val1:COMP _ ")" _ { return val1; }

  / _ "IF"i  _ "(" _ cVal:COMP _ "," _ tVal:COMP _ "," _ fVal:COMP _ ")" _ { return !!cVal ? tVal : fVal; }
  / _ "OR"i  _ "(" _ val1:COMP _ "," _ val2:COMP _ ")" _ { return !!val1 || !!val2; }
  / _ "AND"i _ "(" _ val1:COMP _ "," _ val2:COMP _ ")" _ { return !!val1 && !!val2; }
  / _ "NOT"i _ "(" _ val1:COMP _ ")" _ { return (!val1); }  
  / _ "FALSE"i _ "(" _ ")" _ { return false; }
  / _ "TRUE"i _ "(" _ ")" _ { return true; }

  / _ "POWER"i _ "(" _ val1:COMP _ "," _ val2:COMP _ ")" _ { return Number(val1) ** Number(val2); }
  / _ "ROUND"i _ "(" _ val1:COMP _ "," _ val2:COMP _ ")" _ { return myRound(val1, val2); }
  / _ "LOG10"i _ "(" _ val1:COMP _ ")" _ { return Math.log10(Number(val1)); }
  / _ "LOG"i _ "(" _ val1:COMP _ "," _ val2:COMP _ ")" _ { return myLog(val1, val2); }
  / _ "LN"i _ "(" _ val1:COMP _ ")" _ { return Math.log(Number(val1)); }

  / _ val1:NUMBER _ { return val1; }
  / _ val1:VARIABLE _ { return val1; }

NUMBER
  = _ digits:([0-9]+ "." [0-9]+) _ { return Number(digits.flat().join("")); }
  / _ digits:[0-9]+ _ { return Number(digits.join("")); }

VARIABLE
  = _ chars:([a-z0-9_]+) _ { return options.values[chars.join("")]; }

_ = [ \t\n\r]*
