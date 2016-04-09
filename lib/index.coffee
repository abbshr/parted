{v3: murmur} = require 'murmurhash'
util = require './util'

class Ring
  constructor: (args) ->
    {@nodes, @replica} = args
    @virtual_nodes = {}
    @reverse_map = {}
    @ring = []

    # O(mn*logp)
    @_ensureVitualNode node for node in @nodes

  _keygen: (node, replica_num) ->
    "#{node}\##{replica_num}"

  _hash: (id) -> murmur id

  # O(mlogn)
  _ensureVitualNode: (node) ->
    # index of the virtual_nodes key in @ring
    @reverse_map[node] = {}

    for i in [0...@replica]
      key = @_hash @_keygen node, i
      @virtual_nodes[key] = node
      @reverse_map[node][key] = util.orderList.insert @ring, key

  # O(mlogn)
  addNode: (node) ->
    @nodes.push node
    @_ensureVitualNode node

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

    ringlen = @ring.length - @reverse_map[node].length
    @ring = @ring[...ringlen]

    util.unorderList.rm @nodes, node
    delete @reverse_map[node]

  # O(logn)
  schedule: (resource) ->
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
      if start is end
        mid
      else
        @_search hash, start, mid - 1
    else
      @virtual_nodes[mid]

module.exports = Ring
