module.exports = do ->

  TO_SEC = 1000
  TO_MIN = 60 * TO_SEC
  TO_HOUR = 60 * TO_MIN
  TO_DAY = 24 * TO_HOUR

  trans =
    sec: TO_SEC
    min: TO_MIN
    hour: TO_HOUR
    day: TO_DAY

  (start, end, unit)->
    unit = unit ? 'day'
    diff = new Date(end - start).getTime()
    return Math.floor diff / trans[unit]
