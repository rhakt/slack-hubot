module.exports = do ->
  obj = {}
  obj.random =  (arr)-> arr[Math.floor Math.random() * arr.length]

  return obj
