## 多重拦截机制->原版的单一 block 机制 + 改版的 attract 机制。

- 当一个拥有 attract 域的士兵 soldier.target_id 为空时，其行为和正常士兵一致，会拦截敌人，并走到拦截的敌人面前。
- 当这个士兵成功走到拦截的敌人面前时，它的 attract 域开始生效，开始在 melee_range 范围内索敌（只搜索 #blockers == 0 的敌人）。如果成功索敌，就把敌人的 attract_source_id 置为 self.id。
- 当敌人的 attract_source_id 有效时，禁止其他士兵拦截它。结合之前只有 #blockers == 0 的敌人才会被 attract 的要求，可知当敌人的 attract_source_id 有效时，敌人的 #blockers 必为 0。我们让敌人直接走到和士兵近战的合适位置。
- 当敌人还没有走到和士兵近战的合适位置，但是 attract 它的士兵已经死亡时，直接解除限制，让敌人正常行动。
- 当士兵拦截的敌人死亡，但是 attract 的敌人还没有抵达时，士兵保持 idle 状态，原地等待 attract 的敌人抵达。当 attract 的敌人抵达时，将敌人的 attract_source_id 置为 nil，并更新士兵和敌人，使得士兵成为敌人的 blocker。

