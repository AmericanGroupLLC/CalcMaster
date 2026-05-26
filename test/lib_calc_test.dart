import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:calcmaster/lib_calc.dart';

void main() {
  group('evaluate — basic arithmetic', () {
    test('addition', () => expect(evaluate('2+3'), 5.0));
    test('subtraction', () => expect(evaluate('10-4'), 6.0));
    test('multiplication', () => expect(evaluate('3*4'), 12.0));
    test('division', () => expect(evaluate('10/4'), 2.5));
    test('modulo', () => expect(evaluate('10%3'), 1.0));
    test('exponentiation', () => expect(evaluate('2^10'), 1024.0));
    test('unary minus', () => expect(evaluate('-5'), -5.0));
    test('unary minus in expression', () => expect(evaluate('10+-5'), 5.0));
    test('decimal numbers', () => expect(evaluate('1.5+2.5'), 4.0));
    test('integer result', () => expect(evaluate('6/2'), 3.0));
  });

  group('evaluate — operator precedence', () {
    test('multiplication before addition', () => expect(evaluate('2+3*4'), 14.0));
    test('division before subtraction', () => expect(evaluate('10-6/2'), 7.0));
    test('exponent before multiplication', () => expect(evaluate('2*3^2'), 18.0));
    test('parentheses override precedence', () => expect(evaluate('(2+3)*4'), 20.0));
    test('nested parentheses', () => expect(evaluate('((2+3)*4)+1'), 21.0));
  });

  group('evaluate — scientific functions', () {
    test('sin(0)', () => expect(evaluate('sin(0)'), closeTo(0.0, 1e-10)));
    test('cos(0)', () => expect(evaluate('cos(0)'), closeTo(1.0, 1e-10)));
    test('tan(0)', () => expect(evaluate('tan(0)'), closeTo(0.0, 1e-10)));
    test('sqrt(4)', () => expect(evaluate('sqrt(4)'), 2.0));
    test('sqrt(9)', () => expect(evaluate('sqrt(9)'), 3.0));
    test('abs(-5)', () => expect(evaluate('abs(-5)'), 5.0));
    test('abs(5)', () => expect(evaluate('abs(5)'), 5.0));
    test('log(100)', () => expect(evaluate('log(100)'), closeTo(2.0, 1e-10)));
    test('ln(e)', () => expect(evaluate('ln(${math.e})'), closeTo(1.0, 1e-10)));
    test('ceil(2.3)', () => expect(evaluate('ceil(2.3)'), 3.0));
    test('floor(2.9)', () => expect(evaluate('floor(2.9)'), 2.0));
    test('round(2.5)', () => expect(evaluate('round(2.5)'), 3.0));
  });

  group('evaluate — constants', () {
    test('pi', () => expect(evaluate('pi'), closeTo(math.pi, 1e-10)));
    test('e', () => expect(evaluate('e'), closeTo(math.e, 1e-10)));
    test('pi in expression', () => expect(evaluate('2*pi'), closeTo(2 * math.pi, 1e-10)));
  });

  group('evaluate — factorial (postfix ! operator)', () {
    test('5! = 120', () => expect(evaluate('5!'), 120.0));
    test('0! = 1', () => expect(evaluate('0!'), 1.0));
    test('1! = 1', () => expect(evaluate('1!'), 1.0));
    test('10! = 3628800', () => expect(evaluate('10!'), 3628800.0));
    test('factorial in expression', () => expect(evaluate('3!+1'), 7.0));
  });

  group('evaluate — edge cases', () {
    test('division by zero returns infinity', () => expect(evaluate('1/0'), double.infinity));
    test('zero divided by zero returns NaN', () => expect(evaluate('0/0').isNaN, isTrue));
    test('empty string throws', () => expect(() => evaluate(''), throwsA(isA<CalcError>())));
    test('invalid expression throws', () => expect(() => evaluate('abc'), throwsA(isA<CalcError>())));
    test('large number', () => expect(evaluate('1000000*1000000'), 1e12));
    test('negative result', () => expect(evaluate('3-10'), -7.0));
    test('chained operations', () => expect(evaluate('1+2+3+4+5'), 15.0));
  });
}
