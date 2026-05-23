// Small expression evaluator using shunting-yard. Powers Standard + Scientific calculators.
// Supports: + - * / % ^, parentheses, functions sin/cos/tan/asin/acos/atan/log/ln/sqrt/exp/abs,
// constants pi/e, factorial (n!).

type Token =
  | { type: "num"; value: number }
  | { type: "op"; value: string }
  | { type: "fn"; value: string }
  | { type: "lparen" }
  | { type: "rparen" }
  | { type: "comma" };

const OPS: Record<string, { prec: number; right?: boolean; fn: (a: number, b: number) => number }> = {
  "+": { prec: 1, fn: (a, b) => a + b },
  "-": { prec: 1, fn: (a, b) => a - b },
  "*": { prec: 2, fn: (a, b) => a * b },
  "/": { prec: 2, fn: (a, b) => a / b },
  "%": { prec: 2, fn: (a, b) => a % b },
  "^": { prec: 3, right: true, fn: (a, b) => Math.pow(a, b) },
};

const FNS: Record<string, (a: number) => number> = {
  sin: Math.sin,
  cos: Math.cos,
  tan: Math.tan,
  asin: Math.asin,
  acos: Math.acos,
  atan: Math.atan,
  log: (n) => Math.log10(n),
  ln: Math.log,
  sqrt: Math.sqrt,
  exp: Math.exp,
  abs: Math.abs,
};

function tokenize(input: string): Token[] {
  const tokens: Token[] = [];
  const src = input.replace(/π/g, "pi").replace(/√/g, "sqrt").replace(/\s+/g, "");
  let i = 0;
  while (i < src.length) {
    const c = src[i];
    if ((c >= "0" && c <= "9") || c === ".") {
      let j = i;
      while (j < src.length && (src[j] === "." || (src[j] >= "0" && src[j] <= "9"))) j++;
      tokens.push({ type: "num", value: parseFloat(src.slice(i, j)) });
      i = j;
      continue;
    }
    if ((c >= "a" && c <= "z") || (c >= "A" && c <= "Z")) {
      let j = i;
      while (j < src.length && ((src[j] >= "a" && src[j] <= "z") || (src[j] >= "A" && src[j] <= "Z"))) j++;
      const ident = src.slice(i, j).toLowerCase();
      if (ident === "pi") tokens.push({ type: "num", value: Math.PI });
      else if (ident === "e") tokens.push({ type: "num", value: Math.E });
      else if (FNS[ident]) tokens.push({ type: "fn", value: ident });
      else throw new Error(`Unknown identifier: ${ident}`);
      i = j;
      continue;
    }
    if (c === "(") {
      tokens.push({ type: "lparen" });
      i++;
      continue;
    }
    if (c === ")") {
      tokens.push({ type: "rparen" });
      i++;
      continue;
    }
    if (c === ",") {
      tokens.push({ type: "comma" });
      i++;
      continue;
    }
    if (c === "!") {
      tokens.push({ type: "op", value: "!" });
      i++;
      continue;
    }
    if (OPS[c] !== undefined) {
      // Detect unary minus: a leading "-" or a "-" right after another operator/lparen.
      // Translate into "(-1) *" so it binds at multiplication precedence.
      const last = tokens[tokens.length - 1];
      if (
        c === "-" &&
        (!last || (last.type !== "num" && last.type !== "rparen"))
      ) {
        tokens.push({ type: "num", value: -1 });
        tokens.push({ type: "op", value: "*" });
        i++;
        continue;
      }
      tokens.push({ type: "op", value: c });
      i++;
      continue;
    }
    throw new Error(`Unexpected character: ${c}`);
  }
  return tokens;
}

function factorial(n: number): number {
  if (n < 0 || !Number.isInteger(n)) return NaN;
  let f = 1;
  for (let k = 2; k <= n; k++) f *= k;
  return f;
}

export function evaluate(input: string): number {
  const tokens = tokenize(input);
  const out: Token[] = [];
  const ops: Token[] = [];

  for (const tok of tokens) {
    if (tok.type === "num") {
      out.push(tok);
    } else if (tok.type === "fn") {
      ops.push(tok);
    } else if (tok.type === "op") {
      if (tok.value === "!") {
        // Unary postfix factorial — applied immediately to the last value
        const last = out.pop();
        if (!last || last.type !== "num") throw new Error("'!' must follow a number");
        out.push({ type: "num", value: factorial(last.value) });
        continue;
      }
      while (ops.length) {
        const top = ops[ops.length - 1];
        if (top.type === "fn") {
          out.push(ops.pop()!);
          continue;
        }
        if (top.type === "op") {
          const opTop = OPS[top.value];
          const opCur = OPS[tok.value];
          if (!opTop || !opCur) break;
          if ((!opCur.right && opCur.prec <= opTop.prec) || (opCur.right && opCur.prec < opTop.prec)) {
            out.push(ops.pop()!);
            continue;
          }
        }
        break;
      }
      ops.push(tok);
    } else if (tok.type === "lparen") {
      ops.push(tok);
    } else if (tok.type === "rparen") {
      while (ops.length && ops[ops.length - 1].type !== "lparen") {
        out.push(ops.pop()!);
      }
      if (!ops.length) throw new Error("Mismatched parentheses");
      ops.pop(); // discard '('
      if (ops.length && ops[ops.length - 1].type === "fn") {
        out.push(ops.pop()!);
      }
    }
  }
  while (ops.length) {
    const op = ops.pop()!;
    if (op.type === "lparen" || op.type === "rparen") throw new Error("Mismatched parentheses");
    out.push(op);
  }

  // Evaluate RPN
  const stack: number[] = [];
  for (const tok of out) {
    if (tok.type === "num") {
      stack.push(tok.value);
    } else if (tok.type === "op") {
      const b = stack.pop()!;
      const a = stack.pop()!;
      const fn = OPS[tok.value]?.fn;
      if (!fn) throw new Error(`Unsupported operator ${tok.value}`);
      stack.push(fn(a, b));
    } else if (tok.type === "fn") {
      const a = stack.pop()!;
      const fn = FNS[tok.value];
      if (!fn) throw new Error(`Unsupported function ${tok.value}`);
      stack.push(fn(a));
    }
  }
  if (stack.length !== 1) throw new Error("Invalid expression");
  return stack[0];
}

// Greatest common divisor for fraction simplification.
export function gcd(a: number, b: number): number {
  a = Math.abs(Math.round(a));
  b = Math.abs(Math.round(b));
  while (b) {
    [a, b] = [b, a % b];
  }
  return a || 1;
}

export function simplifyFraction(num: number, den: number): { n: number; d: number } {
  if (den === 0) return { n: NaN, d: 0 };
  const sign = num * den < 0 ? -1 : 1;
  const g = gcd(num, den);
  return { n: (sign * Math.abs(Math.round(num))) / g, d: Math.abs(Math.round(den)) / g };
}
