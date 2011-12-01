class Post < Redpear::Model
  column :title
  column :body
  column :votes, :counter
  column :created_at, :timestamp
  zindex :user_id, :votes
end

class Comment < Redpear::Model
  column  :content
  index   :post_id
end

class User < Redpear::Model
  column :name
end
