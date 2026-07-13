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

const Map<String, ({int prec, bool right})> _ops = {
  '+': (prec: 1, right: false),
  '-': (prec: 1, right: false),
  '*': (prec: 2, right: false),
  '/': (prec: 2, right: false),
  '%': (prec: 2, right: false),
  '^': (prec: 3, right: true),
};

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

double _factorial(double n) {
  if (n < 0 || n != n.toInt()) return double.nan;
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
      tokens.add(_Tok('num', double.parse(src.substring(i, j))));
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
      // Unary minus -> insert (-1)*
      if (c == '-' && (last == null || (last.type != 'num' && last.type != 'rparen'))) {
        tokens.add(_Tok('num', -1.0));
        tokens.add(_Tok('op', '*'));
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
      while (ops.isNotEmpty) {
        final top = ops.last;
        if (top.type == 'fn') {
          out.add(ops.removeLast());
          continue;
        }
        if (top.type == 'op') {
          final opTop = _ops[top.value];
          final opCur = _ops[tok.value];
          if (opTop == null || opCur == null) break;
          if ((!opCur.right && opCur.prec <= opTop.prec) || (opCur.right && opCur.prec < opTop.prec)) {
            out.add(ops.removeLast());
            continue;
          }
        }
        break;
      }
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
