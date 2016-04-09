exports.orderList =
  insert: (lst, item) ->
    pos = nearly lst, item
    if pos is -1
      lst.unshift item
    else if pos is lst.length - 1
      lst.push item
    else
      lst.splice pos, 0, item

  nearly: (lst, p, start, end) ->
    start ?= 0
    end ?= lst.length - 1

    idx = lst.indexOf p, start
    if ~idx and idx <= end
      idx
    else
      binSearch lst, p, start, end

binSearch = (lst, p, start, end) ->
  idx = (start + end) // 2
  mid = lst[idx]

  if p > mid
    if start is end
      idx + 1
    else
      binSearch lst, p, start + idx + 1, end
  else if p < mid
    if start is end
      idx
    else
      binSearch lst, p, start, mid - 1
  else
    idx
