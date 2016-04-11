exports.unorderList =
  rm: (lst, pos) ->
    len = lst.length
    return unless len

    idx = lst.indexOf pos
    return unless !!~idx

    last = lst.pop()
    lst[idx] = last unless idx is len - 1

exports.orderList =
  insert: (lst, item) ->
    pos = @nearly lst, item
    if pos is 0
      lst.unshift item
    else if pos is lst.length
      lst.push item
    else
      lst.splice pos, 0, item

  nearly: (lst, p, start, end) ->
    start ?= 0
    end ?= lst.length and lst.length - 1

    idx = lst.indexOf p, start
    if ~idx and idx <= end
      idx
    else
      binarySearch lst, p, start, end

binarySearch = (lst, p, start, end) ->
  return 0 if lst.length is 0
  idx = (start + end) // 2
  mid = lst[idx]

  if p > mid
    if start is end
      idx + 1
    else
      binarySearch lst, p, idx + 1, end
  else if p < mid
    if start is idx
      idx
    else
      binarySearch lst, p, start, idx - 1
  else
    idx
