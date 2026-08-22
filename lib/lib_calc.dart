import 'dart:math' as math;

class CalcError implements Exception {
  final String message;
  CalcError(this.message);
  @override
  String toString() => 'CalcError: $message';
}

class _Tok {
  final String type;
  final dynamic value;
  _Tok(this.type, this.value);
}

/// Binary operator precedence. Unary minus is NOT here — it is a separate
/// prefix operator (`_unaryMinus`) so that it binds looser than `^`
/// (`-2^2 == -4`) while still applying to an exponent (`2^-3 == 0.125`).
const Map<String, ({int prec, bool right})> _ops = {
  '+': (prec: 1, right: false),
  '-': (prec: 1, right: false),
  '*': (prec: 2, right: false),
  '/': (prec: 2, right: false),
  '%': (prec: 2, right: false),
  '^': (prec: 4, right: true),
};

/// Token value for prefix negation. Sits between `*` (2) and `^` (4) so that
/// `-2^2` parses as `-(2^2)` and `-2*3` as `(-2)*3`.
const String _unaryMinus = 'u-';
const int _unaryMinusPrec = 3;

double _apply(String op, double a, double b) {
  switch (op) {
    case '+':
      return a + b;
    case '-':
      return a - b;
    case '*':
      return a * b;
    case '/':
      return a / b;
    case '%':
      return a % b;
    case '^':
      return math.pow(a, b).toDouble();
    default:
      throw CalcError('Bad op $op');
  }
}

double _fn(String name, double a) {
  switch (name) {
    case 'sin':
      return math.sin(a);
    case 'cos':
      return math.cos(a);
    case 'tan':
      return math.tan(a);
    case 'asin':
      return math.asin(a);
    case 'acos':
      return math.acos(a);
    case 'atan':
      return math.atan(a);
    case 'log':
      return math.log(a) / math.ln10;
    case 'ln':
      return math.log(a);
    case 'sqrt':
      return math.sqrt(a);
    case 'exp':
      return math.exp(a);
    case 'abs':
      return a.abs();
    case 'ceil':
      return a.ceilToDouble();
    case 'floor':
      return a.floorToDouble();
    case 'round':
      return a.roundToDouble();
    default:
      throw CalcError('Unsupported function $name');
  }
}

/// Largest n whose factorial still fits in a double — 171! overflows to
/// infinity, so looping beyond this only burns CPU without changing the answer.
const int _maxFactorial = 170;

double _factorial(double n) {
  if (n.isNaN || n < 0 || n != n.truncateToDouble()) return double.nan;
  // Bail out before the loop: without this, an input like 1e15 spins the
  // (single-threaded) UI isolate for hours to produce the same Infinity.
  if (n > _maxFactorial) return double.infinity;
  double f = 1;
  for (int k = 2; k <= n.toInt(); k++) {
    f *= k;
  }
  return f;
}

List<_Tok> _tokenize(String input) {
  final src = input.replaceAll('π', 'pi').replaceAll('√', 'sqrt').replaceAll(RegExp(r'\s+'), '');
  final tokens = <_Tok>[];
  int i = 0;
  while (i < src.length) {
    final c = src[i];
    if (RegExp(r'[0-9.]').hasMatch(c)) {
      int j = i;
      while (j < src.length && RegExp(r'[0-9.]').hasMatch(src[j])) {
        j++;
      }
      final text = src.substring(i, j);
      final value = double.tryParse(text);
      if (value == null) {
        // e.g. "1.2.3" — surface the library's own error type rather than
        // letting a FormatException escape to callers that catch CalcError.
        throw CalcError('Invalid number "$text"');
      }
      tokens.add(_Tok('num', value));
      i = j;
      continue;
    }
    if (RegExp(r'[a-zA-Z]').hasMatch(c)) {
      int j = i;
      while (j < src.length && RegExp(r'[a-zA-Z]').hasMatch(src[j])) {
        j++;
      }
      final ident = src.substring(i, j).toLowerCase();
      if (ident == 'pi') {
        tokens.add(_Tok('num', math.pi));
      } else if (ident == 'e') {
        tokens.add(_Tok('num', math.e));
      } else {
        tokens.add(_Tok('fn', ident));
      }
      i = j;
      continue;
    }
    if (c == '(') {
      tokens.add(_Tok('lparen', null));
      i++;
      continue;
    }
    if (c == ')') {
      tokens.add(_Tok('rparen', null));
      i++;
      continue;
    }
    if (c == '!') {
      tokens.add(_Tok('op', '!'));
      i++;
      continue;
    }
    if (_ops.containsKey(c)) {
      final last = tokens.isEmpty ? null : tokens.last;
      // A +/- is *prefix* (sign) rather than binary whenever it does not
      // follow a value — i.e. at the start, or after another operator or '('.
      // A postfix '!' yields a value, so "3!+1" is a binary '+'.
      final followsValue = last != null &&
          (last.type == 'num' || last.type == 'rparen' || (last.type == 'op' && last.value == '!'));
      final isPrefix = !followsValue;
      if (c == '-' && isPrefix) {
        tokens.add(_Tok('uop', _unaryMinus));
        i++;
        continue;
      }
      if (c == '+' && isPrefix) {
        // Unary plus is a no-op ("+5" == "5"); drop it rather than treating it
        // as a binary '+' with a missing left operand.
        i++;
        continue;
      }
      tokens.add(_Tok('op', c));
      i++;
      continue;
    }
    throw CalcError('Unexpected char $c');
  }
  return tokens;
}

double evaluate(String input) {
  final tokens = _tokenize(input);
  final out = <_Tok>[];
  final ops = <_Tok>[];

  for (final tok in tokens) {
    if (tok.type == 'num') {
      out.add(tok);
    } else if (tok.type == 'fn') {
      ops.add(tok);
    } else if (tok.type == 'op') {
      if (tok.value == '!') {
        if (out.isEmpty || out.last.type != 'num') {
          throw CalcError("'!' must follow a number");
        }
        final n = out.removeLast().value as double;
        out.add(_Tok('num', _factorial(n)));
        continue;
      }
      final opCur = _ops[tok.value];
      while (ops.isNotEmpty && opCur != null) {
        final top = ops.last;
        if (top.type == 'fn') {
          out.add(ops.removeLast());
          continue;
        }
        // A pending prefix negation participates in precedence just like a
        // binary operator, so `-2*3` pops it but `2^-3` does not.
        final int? topPrec =
            top.type == 'uop' ? _unaryMinusPrec : (top.type == 'op' ? _ops[top.value]?.prec : null);
        if (topPrec == null) break;
        if ((!opCur.right && opCur.prec <= topPrec) || (opCur.right && opCur.prec < topPrec)) {
          out.add(ops.removeLast());
          continue;
        }
        break;
      }
      ops.add(tok);
    } else if (tok.type == 'uop') {
      // Prefix operator: binds to the operand that follows, so it never pops
      // anything already on the stack.
      ops.add(tok);
    } else if (tok.type == 'lparen') {
      ops.add(tok);
    } else if (tok.type == 'rparen') {
      while (ops.isNotEmpty && ops.last.type != 'lparen') {
        out.add(ops.removeLast());
      }
      if (ops.isEmpty) throw CalcError('Mismatched parens');
      ops.removeLast();
      if (ops.isNotEmpty && ops.last.type == 'fn') {
        out.add(ops.removeLast());
      }
    }
  }
  while (ops.isNotEmpty) {
    final t = ops.removeLast();
    if (t.type == 'lparen' || t.type == 'rparen') {
      throw CalcError('Mismatched parens');
    }
    out.add(t);
  }

  final stack = <double>[];
  for (final tok in out) {
    if (tok.type == 'num') {
      stack.add(tok.value as double);
    } else if (tok.type == 'op') {
      if (stack.length < 2) throw CalcError('Bad expr');
      final b = stack.removeLast();
      final a = stack.removeLast();
      stack.add(_apply(tok.value as String, a, b));
    } else if (tok.type == 'uop') {
      if (stack.isEmpty) throw CalcError('Bad expr');
      stack.add(-stack.removeLast());
    } else if (tok.type == 'fn') {
      if (stack.isEmpty) throw CalcError('Bad expr');
      final a = stack.removeLast();
      stack.add(_fn(tok.value as String, a));
    }
  }
  if (stack.length != 1) throw CalcError('Invalid expr');
  return stack.single;
}

({int n, int d}) simplifyFraction(int num, int den) {
  if (den == 0) return (n: 0, d: 0);
  final sign = (num * den < 0) ? -1 : 1;
  int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }
  final g = gcd(num, den);
  return (n: sign * (num.abs() ~/ g), d: den.abs() ~/ g);
}
