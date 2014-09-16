require 'user'

module ConSharkHelper
  def self.generate_get_params get_params_hash
    get_params_string = ''
    get_params_hash.each do |key, value|
      get_params_string << key + '=' + value + '&'
    end
    get_params_string[0..-2]
  end

  def self.add_connection_to_user(full_user_list, connection_object, query_user)
    already_existing_user = full_user_list.select { |usr| usr.user == query_user }
    if already_existing_user.empty?
      user = User.new(query_user)
    else
      user = already_existing_user.first
    end

    user.add_connection connection_object

    user
  end
end
