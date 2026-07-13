import 'lib_currency.dart';

enum FilingStatus { single, joint, head }

class Bracket {
  final double upTo;
  final double rate;
  const Bracket(this.upTo, this.rate);
}

const Map<RegionId, double> salesTaxRate = {
  RegionId.US: 0.085,
  RegionId.UK: 0.20,
  RegionId.EU: 0.19,
  RegionId.CA: 0.13,
  RegionId.AU: 0.10,
  RegionId.IN: 0.18,
  RegionId.JP: 0.10,
  RegionId.BR: 0.17,
  RegionId.MX: 0.16,
  RegionId.KR: 0.10,
  RegionId.AE: 0.05,
};

const Map<RegionId, Map<FilingStatus, double>> standardDeduction = {
  RegionId.US: {FilingStatus.single: 15000, FilingStatus.joint: 30000, FilingStatus.head: 22500},
  // UK: the £12,570 personal allowance is already modelled as the 0% band in
  // the bracket table below, so applying it again as a standard deduction would
  // double-count it. Keep this at 0 and let the brackets handle the allowance.
  RegionId.UK: {FilingStatus.single: 0, FilingStatus.joint: 0, FilingStatus.head: 0},
  RegionId.EU: {FilingStatus.single: 10908, FilingStatus.joint: 21816, FilingStatus.head: 10908},
  RegionId.CA: {FilingStatus.single: 15705, FilingStatus.joint: 15705, FilingStatus.head: 15705},
  RegionId.AU: {FilingStatus.single: 18200, FilingStatus.joint: 18200, FilingStatus.head: 18200},
  RegionId.IN: {FilingStatus.single: 75000, FilingStatus.joint: 75000, FilingStatus.head: 75000},
  RegionId.JP: {FilingStatus.single: 480000, FilingStatus.joint: 480000, FilingStatus.head: 480000},
  RegionId.BR: {FilingStatus.single: 28560, FilingStatus.joint: 28560, FilingStatus.head: 28560},
  RegionId.MX: {FilingStatus.single: 0, FilingStatus.joint: 0, FilingStatus.head: 0},
  RegionId.KR: {FilingStatus.single: 1500000, FilingStatus.joint: 1500000, FilingStatus.head: 1500000},
  RegionId.AE: {FilingStatus.single: 0, FilingStatus.joint: 0, FilingStatus.head: 0},
};

const inf = double.infinity;

const _usSingle = [
  Bracket(11925, 0.10),
  Bracket(48475, 0.12),
  Bracket(103350, 0.22),
  Bracket(197300, 0.24),
  Bracket(250525, 0.32),
  Bracket(626350, 0.35),
  Bracket(inf, 0.37),
];
const _usJoint = [
  Bracket(23850, 0.10),
  Bracket(96950, 0.12),
  Bracket(206700, 0.22),
  Bracket(394600, 0.24),
  Bracket(501050, 0.32),
  Bracket(751600, 0.35),
  Bracket(inf, 0.37),
];
const _usHead = [
  Bracket(17000, 0.10),
  Bracket(64850, 0.12),
  Bracket(103350, 0.22),
  Bracket(197300, 0.24),
  Bracket(250500, 0.32),
  Bracket(626350, 0.35),
  Bracket(inf, 0.37),
];
const _ukAll = [
  Bracket(12570, 0),
  Bracket(50270, 0.20),
  Bracket(125140, 0.40),
  Bracket(inf, 0.45),
];
const _euAll = [
  Bracket(11604, 0),
  Bracket(17005, 0.14),
  Bracket(66760, 0.24),
  Bracket(277825, 0.42),
  Bracket(inf, 0.45),
];
const _caAll = [
  Bracket(55867, 0.15),
  Bracket(111733, 0.205),
  Bracket(173205, 0.26),
  Bracket(246752, 0.29),
  Bracket(inf, 0.33),
];
const _auAll = [
  Bracket(18200, 0),
  Bracket(45000, 0.16),
  Bracket(135000, 0.30),
  Bracket(190000, 0.37),
  Bracket(inf, 0.45),
];
const _inAll = [
  Bracket(400000, 0),
  Bracket(800000, 0.05),
  Bracket(1200000, 0.10),
  Bracket(1600000, 0.15),
  Bracket(2000000, 0.20),
  Bracket(2400000, 0.25),
  Bracket(inf, 0.30),
];
const _jpAll = [
  Bracket(1950000, 0.05),
  Bracket(3300000, 0.10),
  Bracket(6950000, 0.20),
  Bracket(9000000, 0.23),
  Bracket(18000000, 0.33),
  Bracket(40000000, 0.40),
  Bracket(inf, 0.45),
];

const Map<RegionId, Map<FilingStatus, List<Bracket>>> incomeTaxBrackets = {
  RegionId.US: {FilingStatus.single: _usSingle, FilingStatus.joint: _usJoint, FilingStatus.head: _usHead},
  RegionId.UK: {FilingStatus.single: _ukAll, FilingStatus.joint: _ukAll, FilingStatus.head: _ukAll},
  RegionId.EU: {FilingStatus.single: _euAll, FilingStatus.joint: _euAll, FilingStatus.head: _euAll},
  RegionId.CA: {FilingStatus.single: _caAll, FilingStatus.joint: _caAll, FilingStatus.head: _caAll},
  RegionId.AU: {FilingStatus.single: _auAll, FilingStatus.joint: _auAll, FilingStatus.head: _auAll},
  RegionId.IN: {FilingStatus.single: _inAll, FilingStatus.joint: _inAll, FilingStatus.head: _inAll},
  RegionId.JP: {FilingStatus.single: _jpAll, FilingStatus.joint: _jpAll, FilingStatus.head: _jpAll},
  RegionId.BR: {FilingStatus.single: _brAll, FilingStatus.joint: _brAll, FilingStatus.head: _brAll},
  RegionId.MX: {FilingStatus.single: _mxAll, FilingStatus.joint: _mxAll, FilingStatus.head: _mxAll},
  RegionId.KR: {FilingStatus.single: _krAll, FilingStatus.joint: _krAll, FilingStatus.head: _krAll},
  RegionId.AE: {FilingStatus.single: _aeAll, FilingStatus.joint: _aeAll, FilingStatus.head: _aeAll},
};

// Brazil: progressive 2024-26 (BRL)
const _brAll = [
  Bracket(28560, 0),
  Bracket(33920, 0.075),
  Bracket(45012, 0.15),
  Bracket(55976, 0.225),
  Bracket(inf, 0.275),
];

// Mexico: progressive ISR 2025 (MXN). Simplified — uses key brackets.
const _mxAll = [
  Bracket(8952, 0.0192),
  Bracket(75984, 0.0640),
  Bracket(133536, 0.1088),
  Bracket(155224, 0.16),
  Bracket(185852, 0.1792),
  Bracket(374838, 0.2136),
  Bracket(590796, 0.2352),
  Bracket(1127926, 0.30),
  Bracket(1503902, 0.32),
  Bracket(4511707, 0.34),
  Bracket(inf, 0.35),
];

// South Korea: progressive 2024-25 (KRW)
const _krAll = [
  Bracket(14000000, 0.06),
  Bracket(50000000, 0.15),
  Bracket(88000000, 0.24),
  Bracket(150000000, 0.35),
  Bracket(300000000, 0.38),
  Bracket(500000000, 0.40),
  Bracket(1000000000, 0.42),
  Bracket(inf, 0.45),
];

// UAE: 0% personal income tax (corporate tax exists at 9% above AED 375k profit,
// but personal earnings are not federally taxed).
const _aeAll = [
  Bracket(inf, 0),
];

class TaxResult {
  final double taxableIncome;
  final double taxOwed;
  final double effectiveRate;
  final double marginalRate;
  final double takeHome;
  final double takeHomeMonthly;
  const TaxResult({
    required this.taxableIncome,
    required this.taxOwed,
    required this.effectiveRate,
    required this.marginalRate,
    required this.takeHome,
    required this.takeHomeMonthly,
  });
}

TaxResult computeIncomeTax(
  double grossIncome,
  RegionId region,
  FilingStatus status, {
  bool applyStandardDeduction = true,
  double stateLocalRate = 0,
}) {
  final deduction = applyStandardDeduction ? (standardDeduction[region]![status] ?? 0) : 0;
  final taxable = (grossIncome - deduction).clamp(0, double.infinity).toDouble();
  final brackets = incomeTaxBrackets[region]![status]!;

  double owed = 0;
  double prevCap = 0;
  double marginal = 0;
  for (final b in brackets) {
    if (taxable <= prevCap) break;
    final slice = (taxable < b.upTo ? taxable : b.upTo) - prevCap;
    owed += slice * b.rate;
    marginal = b.rate;
    prevCap = b.upTo;
  }

  owed += taxable * stateLocalRate;
  marginal = marginal + stateLocalRate;

  final takeHome = (grossIncome - owed).clamp(0, double.infinity).toDouble();
  return TaxResult(
    taxableIncome: taxable,
    taxOwed: owed,
    effectiveRate: grossIncome > 0 ? owed / grossIncome : 0,
    marginalRate: marginal,
    takeHome: takeHome,
    takeHomeMonthly: takeHome / 12,
  );
}
