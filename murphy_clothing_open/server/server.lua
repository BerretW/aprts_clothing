MergeTable = function(t1, t2)
    t1 = t1 or {}
    if not t2 then return t1 end
    for k, v in pairs(t2 or {}) do
      if type(v) == "table" then
        if type(t1[k] or false) == "table" then
          table.merge(t1[k] or {}, t2[k] or {})
        else
          t1[k] = v
        end
      else
        t1[k] = v
      end
    end
    return t1
  end

