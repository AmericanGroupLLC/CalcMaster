import { convert } from "@/app/lib/units";

describe("unit conversions", () => {
  test("distance: 1 mile = 1609.344 m", () => {
    expect(convert(1, "mi", "m", "distance")).toBeCloseTo(1609.344, 3);
  });
  test("distance: 1 km = 0.621371 mi", () => {
    expect(convert(1, "km", "mi", "distance")).toBeCloseTo(0.621371, 5);
  });
  test("volume: 1 gal (US) = 3.78541 L", () => {
    expect(convert(1, "gal", "l", "volume")).toBeCloseTo(3.78541, 4);
  });
  test("weight: 1 kg = 2.20462 lb", () => {
    expect(convert(1, "kg", "lb", "weight")).toBeCloseTo(2.20462, 4);
  });
  test("temperature: 0 °C = 32 °F", () => {
    expect(convert(0, "c", "f", "temperature")).toBeCloseTo(32, 5);
  });
  test("temperature: 100 °C = 212 °F", () => {
    expect(convert(100, "c", "f", "temperature")).toBeCloseTo(212, 5);
  });
  test("temperature: 0 K = -273.15 °C", () => {
    expect(convert(0, "k", "c", "temperature")).toBeCloseTo(-273.15, 5);
  });
  test("speed: 60 mph ≈ 96.5606 km/h", () => {
    expect(convert(60, "mph", "kmh", "speed")).toBeCloseTo(96.5606, 3);
  });
  test("dataSize: 1 GiB = 1073741824 B", () => {
    expect(convert(1, "gib", "b", "dataSize")).toBeCloseTo(1073741824, 0);
  });
  test("fuelEconomy: 1 MPG (US) ≈ 235.215 L/100km", () => {
    expect(convert(1, "mpgus", "l100km", "fuelEconomy")).toBeCloseTo(235.215, 2);
  });
  test("fuelEconomy: 30 MPG (US) ≈ 7.84 L/100km", () => {
    expect(convert(30, "mpgus", "l100km", "fuelEconomy")).toBeCloseTo(7.84, 1);
  });
  test("pressure: 1 atm = 101325 Pa", () => {
    expect(convert(1, "atm", "pa", "pressure")).toBeCloseTo(101325, 0);
  });
  test("pressure: 1 bar = 14.5038 psi", () => {
    expect(convert(1, "bar", "psi", "pressure")).toBeCloseTo(14.5038, 2);
  });
  test("energy: 1 kWh = 3,600,000 J", () => {
    expect(convert(1, "kwh", "j", "energy")).toBeCloseTo(3_600_000, 0);
  });
  test("energy: 1 cal ≈ 4.184 J", () => {
    expect(convert(1, "cal", "j", "energy")).toBeCloseTo(4.184, 5);
  });
  test("area: 1 ac = 4046.86 m²", () => {
    expect(convert(1, "ac", "m2", "area")).toBeCloseTo(4046.86, 1);
  });
  test("area: 1 km² = 0.3861 mi²", () => {
    expect(convert(1, "km2", "mi2", "area")).toBeCloseTo(0.3861, 3);
  });
  test("identity: distance to same unit returns input", () => {
    expect(convert(123.456, "m", "m", "distance")).toBeCloseTo(123.456, 9);
  });
  test("round-trip: km → mi → km is approximately identity", () => {
    const x = 42;
    const round = convert(convert(x, "km", "mi", "distance"), "mi", "km", "distance");
    expect(round).toBeCloseTo(x, 5);
  });
});
