class Post < Redpear::Model
  column :title
  column :body
  column :votes, :counter
  column :created_at, :timestamp
end

class Comment < Redpear::Model
  column :content
  index  :post_id
end
