json.name @forecast.data.name

json.weather @forecast.data.weather do |weather|
  json.id weather["id"]
  json.main weather["main"]
  json.description weather["description"]
  json.icon weather["icon"]
end

json.main do
  json.temp @forecast.data.main["temp"]
  json.feels_like @forecast.data.main["feels_like"]
  json.temp_min @forecast.data.main["temp_min"]
  json.temp_max @forecast.data.main["temp_max"]
  json.pressure @forecast.data.main["pressure"]
  json.humidity @forecast.data.main["humidity"]
  json.sea_level @forecast.data.main["sea_level"]
  json.grnd_level @forecast.data.main["grnd_level"]
end

json.cached @forecast.in_cache
