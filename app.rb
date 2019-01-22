require 'bundler/setup'
require 'sinatra'
require 'json'
require 'open-uri'

set :bind, '0.0.0.0'
set :protection, except: :frame_options

ROR_API = 'https://api.ror.org'.freeze
ROR_RECON = 'http://reconcile.ror.org'.freeze
MAX_RESULTS = 5

helpers do
  def search_ror(test_org_name)
    test_org_name = test_org_name.tr(';', '')
    uri = "#{ROR_API}/organizations?query=#{URI.encode(test_org_name)}"
    res = open(uri).read
    JSON.parse(res)
  end

  def get_ror(ror)
    uri = "#{ROR_API}/organizations/#{URI.encode(ror)}"
    res = open(uri).read
    JSON.parse(res)
  end
end

get '/heartbeat/?', provides: %i[html json] do
  status = { max_results: MAX_RESULTS, named: 'ROR Reconciler', status: 'OK', pid: $PROCESS_ID.to_s, ruby_version: RUBY_VERSION.to_s, phusion: defined?(PhusionPassenger) ? true : false }
  status.to_json
end

get '/preview/*.*', provides: [:html] do
  ror = params['splat'].join('.')
  ror_record = get_ror(ror)

  erb :preview, locals: { ror_api: ROR_API, ror_record: ror_record }
end

post '/reconcile/?', provides: %i[html json] do
  content_type :json
  queries = JSON.parse params['queries']
  return {}.to_json unless queries['q0'].key?('type')

  results = {}
  queries.each_pair do |key, q|
    hits = search_ror(q['query'])
    results[key] = {}
    results[key]['result'] = []
    score = hits['items'].length
    type = { 'id' => '/ror/organization', 'name' => 'Organization' }
    hits['items'][0, MAX_RESULTS].each do |hit|
      ror = hit['id']
      entry = { 'id' => ror, 'name' => hit['name'], 'type' => [type], 'score' => score, 'match' => 'false', 'uri' => ror }
      results[key]['result'].push(entry)
      score -= 1
    end
  end
  results.to_json
end

get '/flyout/?', provides: [:json] do
  callback = params.delete('callback')
  ror = params['id']
  ror_record = get_ror(ror)

  html = File.open('views/flyout.erb').read
  template = ERB.new(html)
  b = binding
  b.local_variable_set(:ror_record, ror_record)
  b.local_variable_set(:ror_api, ROR_API)
  # template = ERB.new(html).result(b)
  # template.result
  json = { 'id' => ror, 'html' => template.result(b) }.to_json
  if callback
    content_type :js
    response = "#{callback}(#{json})"
  else
    content_type :json
    response = json
  end
  response
end

get '/suggest/?', provides: [:json] do
  callback = params.delete('callback')
  prefix = params['prefix']
  prefix += '*'
  puts '-->' + prefix

  results = []
  hits = search_ror(prefix)
  score = hits['items'].length

  hits['items'][0, MAX_RESULTS].each do |hit|
    ror = hit['id']
    entry = { 'id' => ror, 'name' => hit['name'], 'score' => score, 'description' => hit['country']['country_name'] }
    results.push(entry)
    score -= 1
  end

  json = { 'result' => results }.to_json

  if callback
    content_type :js
    response = "#{callback}(#{json})"
  else
    content_type :json
    response = json
  end

  response
end

get '/reconcile/?', provides: %i[html json] do
  callback = params.delete('callback')

  default_types = [

    { 'id' => '/ror/organization', 'name' => 'Organization' }
  ]
  view =  { 'url' => "#{ROR_RECON}/reconcile" }

  preview = {
    'width' => 400,
    'height' => 100,
    'url' => "#{ROR_RECON}/preview/{{id}}"
  }

  entity = { 'flyout_service_path' => '/flyout?id=${id}', 'service_path' => '/suggest', 'service_url' => ROR_RECON }

  suggest = { 'entity' => entity }

  json = { 'name' => 'ROR Reconciliation Service',
           'identifierSpace' => 'http://ror.org/organization',
           'schemaSpace' => 'http://ror.org/ns/type.object.id',
           'defaultTypes' => default_types,
           'view' => view,
           'suggest' => suggest,
           'preview' => preview }.to_json

  if callback
    content_type :js
    response = "#{callback}(#{json})"
  else
    content_type :json
    response = json
  end

  response
end

get '/', provides: [:html] do
  redirect 'https://www.ror.org', 'Roar!'
end
