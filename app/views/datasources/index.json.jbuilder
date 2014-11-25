json.array!(@datasources) do |datasource|
  json.extract! datasource, :id, :datasource_type, :user_id
  json.url datasource_url(datasource, format: :json)
end
