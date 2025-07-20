## 出怪机制
```lua
waves{
    {
        delay: 这个 wave 开始后，等待 delay 段时间后实际出怪。
        path_index: 这个 wave 的出怪属于哪个主路径。
        spawns{
            {
                max: 这个 spawn 生成敌人的总数。
                creep: 这个 spawn 中敌人的模板名。
                creep_aux: 这个 spawn 中另一种可能出现的敌人的模板名。
                max_same: 在本 spawn 拥有 creep_aux 时被启用。当这个 spawn 已经生成了 max_same 个 creep/creep_aux 后，转为生成 creep_aux/creep。
                path: 在 fixed_sub_path 为 1 时启用，此时敌人的子路径序号为 path。
                fixed_sub_path: 为 0 时，禁用 path，此时敌人的子路径序号随机。
                interval: 在 max 为 0 时生效，使得再推迟 interval 段时间后处理下一个 spawn 的出怪，
                interval_next: 本 spawn 结束 interval_next 段时间后，开始处理下一个 spawn 的出怪。
            }
        }
    }
}
```
