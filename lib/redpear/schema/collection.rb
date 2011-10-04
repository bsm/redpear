class Redpear::Schema::Collection < Array

  def column(*args)
    reset!
    Redpear::Column.new(*args).tap do |col|
      self << col
    end
  end

  def index(*args)
    reset!
    Redpear::Index.new(*args).tap do |col|
      self << col
    end
  end

  def names
    @names ||= lookup.keys
  end

  def indices
    @indices ||= select(&:index?)
  end

  def lookup
    @lookup ||= inject({}) {|r, c| r.update c.to_s => c }
  end

  def [](name)
    lookup[name.to_s]
  end

  def reset!
    @lookup = @names = @indices = nil
  end

end
