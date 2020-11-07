const { TestScheduler } = require("jest");
const excel = require("./excel.node.js");

const values = {
  today: "2020-09-22",
  future: "2020-10-04",
  rate: 1.25,
  dollar_to_euro: 1.1,
  dollar_in_uyp: 43,
  money: 100000,
};

describe("check NUM:", () => {
  it("should accept integers", () => expect(excel.parse("=22")).toBe(22));
  it("should accept floats", () => expect(excel.parse("=22.09")).toBe(22.09));
});

describe("check STR:", () => {
  it("should accept single quotes", () => expect(excel.parse("='myTest'")).toBe("myTest"));
  it("should accept double quotes", () => expect(excel.parse('="OtherTest"')).toBe("OtherTest"));
});

describe("check VAR:", () => {
  it("should recognize a existing var", () => expect(excel.parse("=rate", { values })).toBe(1.25));
  it("should return undefined for other vars", () => expect(excel.parse("=someOther", { values })).toBeUndefined());
});

describe("basic sums:", () => {
  it("should do integer+integer", () => expect(excel.parse("=22+9")).toBe(31));
  it("should do float+float", () => expect(excel.parse("=22.9+0.60")).toBeCloseTo(23.5));
  it("should add date+number", () => expect(excel.parse("='2020-09-22'+10")).toBe("2020-10-02"));
  it("should add number+date", () => expect(excel.parse("=-8+'2020-09-22'")).toBe("2020-09-14"));
});
