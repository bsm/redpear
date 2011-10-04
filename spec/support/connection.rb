module RSpec::ConnectionHelperMethods

  def connection
    Redpear::Model.connection
  end

end

RSpec.configure do |c|
  c.include(RSpec::ConnectionHelperMethods)
end
