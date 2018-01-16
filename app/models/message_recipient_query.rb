class MessageRecipientQuery
  attr_accessor :query
  attr_accessor :type
  attr_accessor :id
  attr_accessor :model

  def initialize(query, type, id, model)
    @query = query
    @type = type
    @id = id
    @model = model
  end

  def self.parse(query, model = nil)
    # Format:
    # model::ID
    # model--modifier::ID
    match = query.match(/(.*)::(\d*)/)
    type = match[1]
    id = match[2]

    # Find the backing database model, ensuring the given ID exists for that model.
    model_name = nil
    case type
    when "bus-list", "bus-list--applied", "bus-list--eligible"
      model ||= BusList.find_by_id(id)
      model_name = "Bus List"
    when "school"
      model ||= School.find_by_id(id)
      model_name = "School"
    else
      raise "Unknown recipient query type: #{type.inspect} (in message recipient query: #{query.inspect}"
    end
    raise "Could not find #{model_name} with ID #{id.inspect} (in message recipient query: #{query.inspect}" if model.blank?

    MessageRecipientQuery.new(
      query,
      type,
      id,
      model
    )
  end

  def self.friendly_name(query, model = nil)
    recipient_query = parse(query, model)
    model = recipient_query.model

    case recipient_query.type
    when "bus-list"
      "Bus List: #{model.name} (signed up for bus)"
    when "bus-list--eligible"
      "Bus List: #{model.name} (eligible, not signed up for bus)"
    when "bus-list--applied"
      "Bus List: #{model.name} (applied/not accepted)"
    when "school"
      "Confirmed or Accepted: #{model.name}"
    else
      raise "Unknown recipient query type: #{recipient_query.type.inspect} (in message recipient query: #{r.inspect}"
    end
  end
end
