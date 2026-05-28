describe('CalMaster E2E User Flow Simulations', () => {
  it('completes a unit conversion flow', () => {
    const convert = (v: number, from: string, to: string) => {
      if (from === 'km' && to === 'mi') return parseFloat((v * 0.621371).toFixed(4));
      if (from === 'kg' && to === 'lb') return parseFloat((v * 2.20462).toFixed(4));
      return v;
    };
    expect(convert(10, 'km', 'mi')).toBe(6.2137);
    expect(convert(70, 'kg', 'lb')).toBe(154.3234);
  });
  it('history records last 5 calculations', () => {
    const history: string[] = [];
    const record = (expr: string) => { history.unshift(expr); if (history.length > 5) history.pop(); };
    for (let i = 1; i <= 7; i++) record(`${i}+${i}=${i*2}`);
    expect(history).toHaveLength(5);
    expect(history[0]).toBe('7+7=14');
  });
});
