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
  =  "="  val:EXPR  { return val; }

EXPR
  =  val:EXP_C  { return val; }

EXP_C
  =  val1:EXP_AS  ">"   val2:EXP_AS  { return val1 > val2; }
  /  val1:EXP_AS  ">="  val2:EXP_AS  { return val1 >= val2; }
  /  val1:EXP_AS  "<"   val2:EXP_AS  { return val1 < val2; }
  /  val1:EXP_AS  "<="  val2:EXP_AS  { return val1 <= val2; }
  /  val1:EXP_AS  "="   val2:EXP_AS  { return val1 == val2; }
  /  val1:EXP_AS  "<>"  val2:EXP_AS  { return val1 != val2; }
  /  val1:EXP_AS  { return val1; }

EXP_AS "sum"
  =  val1:EXP_PD  "+"   val2:EXP_AS  { return val1 + val2; }
  /  val1:EXP_PD  "-"   val2:EXP_AS  { return val1 - val2; }
  /  val1:EXP_PD  "&"   val2:EXP_AS  { return String(val1) + String(val2); }
  /  val1:EXP_PD  { return val1; }

EXP_PD
  =  val1:EXP_X  "*"  val2:EXP_PD  { return val1 * val2; }
  /  val1:EXP_X  "/"  val2:EXP_PD  { return val1 / val2; }
  /  val1:EXP_X  { return val1; }

EXP_X
  =  val1:VALUE  "^"  val2:EXP_X  { return val1 ** val2; }
  /  val1:VALUE  { return val1; }

VALUE "value"
  =  "-"  val:VALUE  { return -val; }
  /  "("  val:EXPR  ")"  pct:("%")?  { return pct ? val/100 : val; }

  /  "CONCAT"i  "("  val1:EXPR rest:(  ","  EXPR  )* ")"  {
      return rest.reduce((acc, element) => acc + String(element[3]), String(val1));
  	}
  /  "STARTS"i  "("  val1:EXPR  ","  val2:EXPR  ")"  { return String(val1).startsWith(String(val2))}
  /  "INCLUDES"i  "("  val1:EXPR  ","  val2:EXPR  ")"  { return String(val1).includes(String(val2))}

  /  "EXP_X"i  "("  base:EXPR  ","  exp:EXPR  ")"  { return Number(base) ** Number(exp); }
  /  "ROUND"i  "("  num:EXPR  ","  prec:EXPR  ")"  { const fac=10**Number(prec); return Math.round(Number(num)*fac)/fac; }
  /  "LN"i  "("  val:EXPR  ")"  { return Math.log(Number(val)); }
  /  "LOG10"i  "("  val:EXPR  ")"  { return Math.log10(Number(val)); }
  /  "LOG"i  "("  val:EXPR  ","  base:EXPR  ")"  { return Math.log(Number(val)) / Math.log(base); }

  /  "IF"i  "("  val:EXPR  ","  tVal:EXPR  ","  fVal:EXPR  ")"  { return !!val ? tVal : fVal; }
  /  "OR"i  "("  val1:EXPR rest:(  ","  EXPR  )* ")"  {
      return rest.reduce((acc, element) => acc || !!element[3], !!val1);
  	}
  /  "AND"i  "("  val1:EXPR rest:(  ","  EXPR  )* ")"  {
      return rest.reduce((acc, element) => acc && !!element[3], !!val1);
  	}
  /  "NOT"i  "("  val:EXPR  ")"  { return (!val); }  
  /  "FALSE"i  "()"  { return false; }
  /  "TRUE"i  "()"  { return true; }

  /  val:NUM  "%"  { return val / 100; }
  /  val:NUM  { return val; }
  /  val:VAR  pct:("%")?  { return pct ? Number(val) / 100 : Number(val); }
  /  val:STR  { return val; }

NUM "number"
  =  digits:([0-9]+"."[0-9]+)  { return Number(digits.flat().join("")); }
  /  digits:[0-9]+  { return Number(digits.join("")); }

STR "string"
  =  '"' chars:([^"]*) '"'  { return chars.join(""); }
  /  "'" chars:([^']*) "'"  { return chars.join(""); }
 
VAR "variable"
  =  chars:([a-z0-9_]+)  { return options.values[chars.join("")]; }
