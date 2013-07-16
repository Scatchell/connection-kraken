$: << Dir.pwd.concat('/src/helpers')

require 'sinatra'
require 'data_mapper'
require 'con_shark_helper'
require 'httparty'
require 'json'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/con_shark.db")

include ConSharkHelper

class Token
    include DataMapper::Resource
    property :id, Serial
    property :content, Text, :required => true
    #name property?
    property :created_at, DateTime
    property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!

configure do
    set :redirect_uri, 'http://localhost:9393/link_linked_in'
end

get '/' do
    @tokens = Token.all :order => :id.desc
    @title = 'Main Page'
    erb :home
end

get '/link_linked_in' do
    if params[:code]
        code = params[:code]
        parse_and_save_token code
    else
        main_url = 'https://www.linkedin.com/uas/oauth2/authorization?'
        get_params_hash = {
            'response_type' => 'code',
            'client_id' => '4pxw8zewd2mf',
            'state' => 'random',
            'redirect_uri' => settings.redirect_uri
        }

        get_params = ConSharkHelper.generate_get_params(get_params_hash)
        redirect main_url + get_params
    end
end

def save_token access_token
    token = Token.new
    token.content = access_token
    token.created_at = Time.now
    token.updated_at = Time.now
    token.save
end

def parse_and_save_token code
    main_url = 'https://www.linkedin.com/uas/oauth2/accessToken?'
    response = HTTParty.get(main_url,
                            :query => {
        :grant_type => 'authorization_code',
        :code => code,
        :redirect_uri => settings.redirect_uri ,
        :client_id => '4pxw8zewd2mf',
        :client_secret => 'NTJofEsp6EG2GcDY'
    })

    json = JSON.parse(response.body)
    save_token json['access_token']

    return 'Token saved successfully'
end
