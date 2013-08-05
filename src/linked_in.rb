class LinkedIn
  def self.query_for_people query_keyword
    linked_in_api_url = 'https://api.linkedin.com/v1/people-search'
    search_sorting = ':(people:(id,first-name,last-name,distance,picture-url),num-results)'
    users = LinkedInUser.all
    people_json = {}
    users.each do |user|
      response = HTTParty.get(linked_in_api_url + search_sorting,
                              :query => {
                                  :keywords => query_keyword,
                                  :format => 'json',
                                  :oauth2_access_token => user.token.content
                              })
      person_json = JSON.parse(response.body)
      if person_json['numResults'] > 0
        people_json[user] = person_json['people']['values']
      end
    end

    people_json
  end

  def self.query_current_user access_token
    linked_in_api_url = 'https://api.linkedin.com/v1/people/~'
    search_sorting = ':(id,first-name,last-name,picture-url)'

    people_json = []
    response = HTTParty.get(linked_in_api_url + search_sorting,
                            :query => {
                                :format => 'json',
                                :oauth2_access_token => access_token
                            })

    OpenStruct.new(JSON.parse(response.body))
  end
end