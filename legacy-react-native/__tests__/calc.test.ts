import { evaluate, simplifyFraction } from "@/app/lib/calc";

describe("expression evaluator", () => {
  test("respects operator precedence", () => {
    expect(evaluate("2+2*3")).toBe(8);
    expect(evaluate("(2+2)*3")).toBe(12);
    expect(evaluate("10/2-1")).toBe(4);
  });
  test("supports unary minus", () => {
    expect(evaluate("-5+3")).toBe(-2);
    expect(evaluate("3*-2")).toBe(-6);
  });
  test("right-associative power", () => {
    expect(evaluate("2^3^2")).toBe(512); // 2^(3^2) = 2^9
  });
  test("scientific functions", () => {
    expect(evaluate("sin(0)")).toBeCloseTo(0, 9);
    expect(evaluate("cos(0)")).toBeCloseTo(1, 9);
    expect(evaluate("sin(pi/2)")).toBeCloseTo(1, 9);
    expect(evaluate("log(100)")).toBeCloseTo(2, 9);
    expect(evaluate("ln(e)")).toBeCloseTo(1, 9);
    expect(evaluate("sqrt(16)")).toBeCloseTo(4, 9);
  });
  test("factorial", () => {
    expect(evaluate("5!")).toBe(120);
    expect(evaluate("0!")).toBe(1);
  });
  test("π and e constants", () => {
    expect(evaluate("pi")).toBeCloseTo(Math.PI, 9);
    expect(evaluate("e")).toBeCloseTo(Math.E, 9);
  });
  test("rejects unknown identifier", () => {
    expect(() => evaluate("foo(1)")).toThrow();
  });
});

describe("fraction simplification", () => {
  test("reduces 4/8 to 1/2", () => {
    expect(simplifyFraction(4, 8)).toEqual({ n: 1, d: 2 });
  });
  test("preserves negative numerator", () => {
    expect(simplifyFraction(-3, 6)).toEqual({ n: -1, d: 2 });
  });
});
