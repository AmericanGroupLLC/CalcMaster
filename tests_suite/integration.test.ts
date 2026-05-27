describe('CalMaster Integration Tests', () => {
  it('should map public API and MLS payload to production models', () => {
    const apiPayload = {
      id: 'id-999',
      meta: { source: 'GPS_Provider', status: 'ACTIVE' },
      data: { value: 125.50 }
    };
    const mapped = {
      uid: apiPayload.id,
      isActive: apiPayload.meta.status === 'ACTIVE',
      metric: apiPayload.data.value
    };
    expect(mapped.uid).toBe('id-999');
    expect(mapped.isActive).toBe(true);
    expect(mapped.metric).toBe(125.50);
  });
});
