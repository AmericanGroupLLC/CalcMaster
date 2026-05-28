describe('CalMaster Unit Tests', () => {
  describe('Scientific calculator operations', () => {
    it('square root of 144 = 12', () => { expect(Math.sqrt(144)).toBe(12); });
    it('2^10 = 1024', () => { expect(Math.pow(2, 10)).toBe(1024); });
    it('log10(1000) = 3', () => { expect(parseFloat(Math.log10(1000).toFixed(10))).toBe(3); });
    it('sin(0) = 0', () => { expect(Math.sin(0)).toBe(0); });
    it('cos(0) = 1', () => { expect(Math.cos(0)).toBe(1); });
  });
  describe('Unit conversion', () => {
    const kmToMi = (km: number) => parseFloat((km * 0.621371).toFixed(4));
    const kgToLb = (kg: number) => parseFloat((kg * 2.20462).toFixed(4));
    const celToFah = (c: number) => parseFloat(((c * 9/5) + 32).toFixed(2));
    it('1 km = 0.6214 mi', () => { expect(kmToMi(1)).toBe(0.6214); });
    it('1 kg = 2.2046 lb', () => { expect(kgToLb(1)).toBe(2.2046); });
    it('0°C = 32°F', () => { expect(celToFah(0)).toBe(32); });
    it('100°C = 212°F', () => { expect(celToFah(100)).toBe(212); });
    it('-40°C = -40°F', () => { expect(celToFah(-40)).toBe(-40); });
  });
  describe('Tax calculation', () => {
    const calcTax = (income: number, rate: number) => parseFloat((income * rate / 100).toFixed(2));
    it('10% tax on 50000', () => { expect(calcTax(50000, 10)).toBe(5000); });
    it('22% tax on 89075', () => { expect(calcTax(89075, 22)).toBe(19596.5); });
    it('zero income', () => { expect(calcTax(0, 22)).toBe(0); });
  });
  describe('Expression parsing', () => {
    const isValidExpr = (e: string) => /^[\d\s\+\-\*\/\.\(\)]+$/.test(e);
    it('valid expression', () => { expect(isValidExpr('3 + 4 * 2')).toBe(true); });
    it('invalid with letters', () => { expect(isValidExpr('3 + abc')).toBe(false); });
    it('empty string is invalid', () => { expect(isValidExpr('')).toBe(false); });
  });
});
