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

EXCEL "expression"
  = _ "=" _ val:SUM _ { return val; }

SUM "sum"
  = _ val1:PRODUCT rest:( _ ("&" / "+" / "-" / "=" / "<>" / ">" / ">=" / "<" / "<=") _ PRODUCT _ )* _ {
      return rest.length ? rest.reduce(
        (acc, element) =>
          element[1] === "&" ? String(acc) + String(element[3])
            : element[1] === "+" ? addVal1Val2(acc, element[3])
            : element[1] === "-" ? subVal1Val2(acc, element[3])
            : element[1] === "=" ? acc == element[3]
            : element[1] === "<>" ? acc != element[3]
            : element[1] === ">" ? acc > element[3]
            : element[1] === ">=" ? acc >= element[3]
            : element[1] === "<" ? acc < element[3]
            : element[1] === "<=" ? acc <= element[3]
            : NaN,
        val1
      ) : val1;
  	}

PRODUCT "product"
  = _ val1:POWER rest:( _  ("*" / "/") _ POWER _ )* _ {
      return rest.length ? rest.reduce(
        (acc, element) =>
          element[1] === "*"? acc * element[3]
            : element[1] === "/" ? acc / element[3]
            : NaN,
        val1
      ) : val1;
  	}

POWER "power"
  = _ base:VALUE _ "^" _ val:POWER _ { return Number(base) ** Number(val); }
  / _ val:VALUE _ { return val; }

VALUE "value"
  = _ "-" _ val:VALUE _ { return -val; }
  / _ "(" _ val:SUM _ ")" _ "%" _ { return val/100; }
  / _ "(" _ val:SUM _ ")" _ { return val; }
  / _ "CONCAT"i _ "(" _ val1:SUM rest:( _ "," _ SUM _ )* ")" _ {
      return rest.reduce((acc, element) => acc + String(element[3]), String(val1));
  	}
  / _ "STARTS"i _ "(" _ val1:SUM _ "," _ val2:SUM _ ")" _ { return String(val1).startsWith(String(val2))}
  / _ "INCLUDES"i _ "(" _ val1:SUM _ "," _ val2:SUM _ ")" _ { return String(val1).includes(String(val2))}
  / _ "POWER"i _ "(" _ base:SUM _ "," _ exp:SUM _ ")" _ { return Number(base) ** Number(exp); }
  / _ "ROUND"i _ "(" _ num:SUM _ "," _ prec:SUM _ ")" _ { const fac=10**Number(prec); return Math.round(Number(num)*fac)/fac; }
  / _ "LN"i _ "(" _ val:SUM _ ")" _ { return Math.log(Number(val)); }
  / _ "LOG10"i _ "(" _ val:SUM _ ")" _ { return Math.log10(Number(val)); }
  / _ "LOG"i _ "(" _ val:SUM _ "," _ base:SUM _ ")" _ { return Math.log(Number(val)) / Math.log(base); }
  / _ "IF"i _ "(" _ val:SUM _ "," _ tVal:SUM _ "," _ fVal:SUM _ ")" _ { return !!val ? tVal : fVal; }
  / _ "OR"i _ "(" _ val1:SUM rest:( _ "," _ SUM _ )* ")" _ {
      return rest.reduce((acc, element) => acc || !!element[3], !!val1);
  	}
  / _ "AND"i _ "(" _ val1:SUM rest:( _ "," _ SUM _ )* ")" _ {
      return rest.reduce((acc, element) => acc && !!element[3], !!val1);
  	}
  / _ "NOT"i _ "(" _ val:SUM _ ")" _ { return (!val); }  
  / _ "FALSE"i _ "(" _ ")" _ { return false; }
  / _ "TRUE"i _ "(" _ ")" _ { return true; }
  / _ val:NUM _ "%" _ { return Number(val) / 100; }
  / _ val:NUM _ { return Number(val); }
  / _ val:VAR _ "%" _ { return Number(val) / 100; }
  / _ val:VAR _ { return val; }
  / _ val:STR _ { return val; }

NUM "number"
  = _ digits:([0-9]+"."[0-9]+) _ { return Number(digits.flat().join("")); }
  / _ digits:[0-9]+ _ { return Number(digits.join("")); }

STR "string"
  = _ '"' chars:([^"]*) '"' _ { return chars.join(""); }
  / _ "'" chars:([^']*) "'" _ { return chars.join(""); }
 
VAR "variable"
  = _ chars:([a-z0-9_]+) _ { return options.values[chars.join("")]; }

_ "whitespace"
  = [ \t\n\r]*
