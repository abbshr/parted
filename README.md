Parted
===

Leviathan数据分区器, 使用一致性Hash算法, 根据资源名称映射到环中的一个region, 并且这个region属于某个虚拟节点.

环节点的处理算法已经过优化.

散列运算: `MurmurHash`

## API
```coffee
Ring = require 'node-parted'

ring = new Ring
  nodes: ['172.16.0.10:4567', '172.16.0.11:2333', '172.16.0.16:2333'] # 节点地址
  replica: 100 # 副本集数量

# 添加节点 O(mlogn)
ring.addNode '172.16.10.4:80'

# 移除节点 O(n)
ring.removeNode '172.16.10.4:80'

# 根据键名查找节点 O(logn)
node = ring.schedule 'github::abbshr::parted'
# maybe => '172.16.0.16:2333'
```
