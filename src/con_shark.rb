$: << Dir.pwd.concat('/src/helpers')
$: << Dir.pwd.concat('/src')

require 'sinatra'
require 'sinatra/flash'
require 'con_shark_helper'
require 'httparty'
require 'json'
require 'securerandom'
require 'linked_in'
require 'linked_in_user'
require 'token'

enable :sessions

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/con_shark.db")

include ConSharkHelper

DataMapper.finalize.auto_upgrade!

configure do
    set :redirect_uri, 'http://localhost:9393/link_linked_in'
end

get '/' do
    @users = LinkedInUser.all :order => :id.desc
    @title = 'Main Page'
    erb :home
end

get '/link_linked_in' do
    if params[:code]
        code = params[:code]
        parse_and_save_token code
        flash[:error] = 'User saved successfully'
        redirect '/'
    else
        state = SecureRandom.hex(15)
        main_url = 'https://www.linkedin.com/uas/oauth2/authorization?'
        get_params_hash = {
            'response_type' => 'code',
            'client_id' => '4pxw8zewd2mf',
            'state' => state,
            'redirect_uri' => settings.redirect_uri
        }

        get_params = ConSharkHelper.generate_get_params(get_params_hash)
        redirect main_url + get_params
    end
end

get '/search' do
    @title = 'Search for people'
    people_json = LinkedIn.query_for_people params[:q]
    @people = {}
    if people_json
        people_json.each do |query_user, results|
            results.each do |person|
                person_object = OpenStruct.new(person)
                #todo gen distance text doesn't work anymore...fix
                person_object.distance_text = generate_distance_text(person_object.distance)
                if @people[query_user]
                    @people[query_user].push person_object
                else
                    @people[query_user] = [person_object]
                end
            end
        end
    end

    erb :people
end

get '/:id/delete' do
    @user = LinkedInUser.get params[:id]
    @title = "Confirm deletion of user"
    erb :delete
end

delete '/:id' do
    user = LinkedInUser.get params[:id]

    if user.destroy!
      flash[:error] = 'Record removed successfully'
    else
      flash[:error] = 'Problem removing record ' + user.id.to_s
    end

    if user
        user.errors.each do |error|
            p error
        end
    end

    redirect '/'
end

def save_new_user user, access_token
    linked_in_user = LinkedInUser.create
    linked_in_user.linked_in_id = user.id
    linked_in_user.name = user.firstName + " " + user.lastName
    linked_in_user.picture_url = user.pictureUrl
    linked_in_user.created_at = Time.now
    linked_in_user.updated_at = Time.now

    token = Token.new
    token.content = access_token

    linked_in_user.token = token
    linked_in_user.save
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
    access_token = json['access_token']
    current_user = LinkedIn.query_current_user access_token
    save_new_user current_user, access_token
end
