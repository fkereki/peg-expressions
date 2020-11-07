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



EXCEL
  = _EQ val:SUM _ { return val; }

SUM
  = val1:PRODUCT _CONCAT val2:SUM { return String(val1) + String(val2); }
  / val1:PRODUCT _PLUS val2:SUM { return addVal1Val2(val1, val2); }
  / val1:PRODUCT _MINUS val2:SUM { return subVal1Val2(val1, val2); }
  / val1:PRODUCT _EQ val2:SUM { return val1 == val2; }
  / val1:PRODUCT _NE val2:SUM { return val1 != val2; }
  / val1:PRODUCT _GT val2:SUM { return val1 > val2; }
  / val1:PRODUCT _GE val2:SUM { return val1 >= val2; }
  / val1:PRODUCT _LT val2:SUM { return val1 < val2; }
  / val1:PRODUCT _LE val2:SUM { return val1 <= val2; }
  / PRODUCT

PRODUCT
  = val1:POWER _MULT val2:PRODUCT { return Number(val1) * Number(val2); }
  / val1:POWER _DIV val2:PRODUCT { return Number(val1) / Number(val2); }
  / POWER

POWER
  = base:VALUE _POWER val:POWER { return Number(base) ** Number(val); }
  / VALUE

VALUE
  = _MINUS val:VALUE { return -val; }
  / _LPAREN val:SUM _RPAREN _PERCENT { return val/100; }
  / _LPAREN val:SUM _RPAREN { return val; }
  / "CONCAT" _LPAREN val1:SUM _COMMA val2:SUM _RPAREN { return String(val1) + String(val2); }
  / "STARTS" _LPAREN val1:SUM _COMMA val2:SUM _RPAREN { return String(val1).startsWith(String(val2))}
  / "INCLUDES" _LPAREN val1:SUM _COMMA val2:SUM _RPAREN { return String(val1).includes(String(val2))}
  / "POWER" _LPAREN base:SUM _COMMA exp:SUM _RPAREN { return Number(base) ** Number(exp); }
  / "ROUND" _LPAREN num:SUM _COMMA prec:SUM _RPAREN { const fac=10**Number(prec); return Math.round(Number(num)*fac)/fac; }
  / "LN" _LPAREN val:SUM _RPAREN { return Math.log(Number(val)); }
  / "LOG10" _LPAREN val:SUM _RPAREN { return Math.log10(Number(val)); }
  / "LOG" _LPAREN val:SUM _COMMA base:SUM _RPAREN { return Math.log(Number(val)) / Math.log(base); }
  / "IF" _LPAREN val:SUM _COMMA tVal:SUM _COMMA fVal:SUM _RPAREN { return !!val ? tVal : fVal; }
  / "OR" _LPAREN val1:SUM _COMMA val2:SUM _RPAREN { return (!!val1 || !!val2); }
  / "AND" _LPAREN val1:SUM _COMMA val2:SUM _RPAREN { return (!!val1 && !!val2); }
  / "NOT" _LPAREN val:SUM _RPAREN { return (!val); }  
  / "FALSE" _LPAREN _RPAREN { return false; }
  / "TRUE" _LPAREN _RPAREN { return true; }
  / val:NUM _PERCENT { return Number(val) / 100; }
  / NUM
  / val:VAR _PERCENT { return Number(val) / 100; }
  / VAR
  / STR

NUM
  = _ digits:([0-9]+"."[0-9]+) _ { return Number(digits.flat().join("")); }
  / _ digits:[0-9]+ _ { return Number(digits.join("")); }

STR
  = _ '"' chars:([^"]*) '"' _ { return chars.join(""); }
  / _ "'" chars:([^']*) "'" _ { return chars.join(""); }
 
VAR
  = _ chars:([a-z0-9_]+) _ { return options.values[chars.join("")]; }

_CONCAT = _ "&" _
_PLUS   = _ "+" _
_MINUS = _ "-" _
_MULT = _ "*" _
_DIV = _ "/" _
_POWER = _ "^" _
_PERCENT = _ "%" _
_EQ = _ "=" _
_NE = _ "<>" _
_GT = _ ">" _
_GE = _ ">=" _
_LT = _ "<" _
_LE = _ "<=" _
_LPAREN = _ "(" _
_RPAREN = _ ")" _
_COMMA = _ "," _

_ = [ \t\n\r]*
