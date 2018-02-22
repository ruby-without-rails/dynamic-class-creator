require 'json'

# @class [ModelException]
class ModelException < StandardError
  attr_reader :status, :message, :data, :code

  def initialize(message, status = 400, code = 0, data = {})
    @status = status
    @message = message
    @data = data
    @code = code
  end

  ##
  # Convert Exception contents to a Json string. All attributes must
  # be Json serializable.
  def to_json
    ::JSON.generate(to_hash)
  end

  def to_hash
    {status: @status, message: @message, code: @code, data: @data}
  end

  def to_response
    [@status, to_json]
  end
end