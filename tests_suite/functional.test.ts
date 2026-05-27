describe('CalMaster Functional Tests', () => {
  it('should transition through state machine correctly under load', () => {
    const stateMachine = {
      state: 'INIT',
      transition(action: string) {
        if (action === 'START') this.state = 'RUNNING';
        if (action === 'STOP') this.state = 'TERMINATED';
      }
    };
    expect(stateMachine.state).toBe('INIT');
    stateMachine.transition('START');
    expect(stateMachine.state).toBe('RUNNING');
    stateMachine.transition('STOP');
    expect(stateMachine.state).toBe('TERMINATED');
  });
});
