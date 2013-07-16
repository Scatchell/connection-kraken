module ConSharkHelper
    def self.generate_get_params get_params_hash
        get_params_string = ''
        get_params_hash.each do |key, value|
            get_params_string << key + '=' + value + '&'
        end
        get_params_string[0..-2]
    end
end
