# Lemmings FSM Verification Plan

## Test Cases

- [ ] Reset initializes to WALK_LEFT
- [ ] Walk left on ground
- [ ] Walk right after left bump
- [ ] Walk left after right bump
- [ ] Safe fall (<20 cycles)
- [ ] Fatal fall (>=20 cycles)
- [ ] Dig left
- [ ] Dig right
- [ ] Digging transitions to falling when ground disappears
- [ ] Splat state is permanent