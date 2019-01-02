require 'bundler/setup'
require 'sinatra'
require 'json'
require 'open-uri'

set :bind, '0.0.0.0'

helpers do
  def search_ror test_org_name
                test_org_name = test_org_name.tr(';','')
		uri ="http://ror-api.labs.crossref.org/organizations?query=#{URI::encode(test_org_name)}" 
		res = open(uri).read
		return  JSON.parse(res)
	end
end

get '/heartbeat/?' , :provides => [:html, :json] do
	status = {:named => "ROR Reconciler", :status => "OK",  :pid => "#{$$}", :ruby_version => "#{RUBY_VERSION}", :phusion => defined?(PhusionPassenger) ? true : false }
	status.to_json
end

post '/reconcile/?' , :provides => [:html, :json] do
	content_type :json
	queries = JSON.parse params['queries']
	return {}.to_json unless queries['q0'].has_key?('type')
	results = {}
	queries.each_pair do |key,q|
                puts "*** query-> #{q['query']}"
		hits = search_ror(q['query'])
		results[key]=Hash.new
		results[key]['result'] = Array.new
		score = 0;
		type = {"id" => "/organization/organization", "name" => "Organization"}
                puts hits
                puts "-----------------------------"
		hits['hits'].each do |hit|
			ror = hit['id']
			entry = {"id" => ror, "name"=>hit["name"], "type" => [type], "score"=> score, "match" => "false", "uri" => ror}
			results[key]['result'].push(entry)
			score =+ 1
		end
                
	end
	results.to_json
end

get '/reconcile/?' , :provides => [:html, :json] do
	callback = params['callback']
	default_types = [{"id"=>"/ror/organization_name", "name"=>"ROR"}]
	r = {"name" => "ROR Reconciliation Service",  "identifierSpace" => "http://ror.org/organization", "schemaSpace" => "http://ror.org/ns/type.object.id", "defaultTypes" => default_types}
	content_type :js
	p = JSON.pretty_generate(r)
	"#{callback}(#{p})"
end

