class User
  attr_accessor :connections
  def initialize user
    @user = user
    @connections = {'1' => [], '2' => [], '3' => []}
  end

  def add_connection connection
    @connections[connection.distance.to_s].push connection
  end

  def generate_distance_text(distance)
    case distance
      when 0
        distance_text = 'This is you!'
      when 1..3
        distance_text = 'A connection ' + distance.to_s + ' degrees away.'
      when 100
        distance_text = 'You share a group with this connection'
      when -1
        distance_text = 'Out of network'
      else
        distance_text = 'Unknown'
    end
    distance_text
  end

  def connections_with_distance distance
    @connections[distance.to_s]
  end
end