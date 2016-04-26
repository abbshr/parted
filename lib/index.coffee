assert = require 'assert'
{v3: murmur} = require 'murmurhash'
util = require 'archangel-util'

class Ring
  constructor: (args) ->
    {@nodes, @replica} = args
    @virtual_nodes = {}
    @reverse_map = {}
    @ring = []
    @_init()

  _init: ->
    # O(mn*logp)
    @_ensureVirtualNode node for node in @nodes
    @_ensureReverseMap()

  _keygen: (node, replica_num) ->
    "#{node}\##{replica_num}"

  _hash: (id) -> murmur id

  _ensureReverseMap: ->
    for key, idx in @ring
      @reverse_map[@virtual_nodes[key]][key] = idx

  # O(mlogn)
  _ensureVirtualNode: (node) ->
    # index of the virtual_nodes key in @ring
    @reverse_map[node] = {}

    for i in [0...@replica]
      key = @_hash @_keygen node, i
      @virtual_nodes[key] = node
      util.orderList.insert @ring, key
      # @reverse_map[node][key] = yes

  # O(mlogn)
  addNode: (node) ->
    @nodes.push node
    @_ensureVirtualNode node
    @_ensureReverseMap()

  # O(n)
  removeNode: (node) ->
    for key, idx of @reverse_map[node]
      delete @virtual_nodes[key]
      delete @ring[idx]

    step = 0
    for key, idx in @ring
      if key?
        nidx = idx - step
        @ring[nidx] = key
        @reverse_map[@virtual_nodes[key]][key] = nidx
      else
        step++

    @ring = @ring[...@ring.length - @replica]

    util.unorderList.rm @nodes, node
    delete @reverse_map[node]

  # O(logn)
  schedule: (resource) ->
    assert.ok(@ring.length > 0)

    key = @_search @_hash resource
    @virtual_nodes[key]

  # O(logn)
  _search: (hash, start = 0, end = @ring.length - 1) =>
    idx = (start + end) // 2
    mid = @ring[idx]

    if hash > mid
      if start is end
        @ring[(idx + 1) % @ring.length]
      else
        @_search hash, idx + 1, end
    else if hash < mid
      if start is idx
        mid
      else
        @_search hash, start, idx - 1
    else
      mid

module.exports = Ring
