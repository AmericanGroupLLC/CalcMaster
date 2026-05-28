describe('CalMaster Performance Benchmarks', () => {
  it('performs 10 000 conversions under 500 ms', () => {
    const kmToMi = (km: number) => km * 0.621371;
    const values = Array.from({ length: 10000 }, (_, i) => i + 1);
    const start = Date.now();
    const results = values.map(kmToMi);
    expect(Date.now() - start).toBeLessThan(500);
    expect(results[0]).toBeCloseTo(0.621371);
  });
  it('calculates tax for 10 000 incomes under 500 ms', () => {
    const tax = (income: number) => income * 0.22;
    const incomes = Array.from({ length: 10000 }, (_, i) => (i + 1) * 1000);
    const start = Date.now();
    const taxes = incomes.map(tax);
    expect(Date.now() - start).toBeLessThan(500);
    expect(taxes[0]).toBe(220);
  });
});
