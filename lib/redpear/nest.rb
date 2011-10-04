class Redpear::Nest < ::Nest

  [:mapped_hmget, :mapped_hmset].each do |meth|
    define_method(meth) do |*args, &block|
      redis.send(meth, self, *args, &block)
    end
  end

  def mapped_hmget_all
    mapped_hmget *hkeys
  end

end
