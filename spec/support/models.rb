class Post < Redpear::Model
  column :title
  column :votes, :counter
  column :created_at, :timestamp
  score  :rank
  index  :user_id
end

class Comment < Redpear::Model
  column  :content
  index   :post_id
end

class User < Redpear::Model
  column :name
end

class ManagerConnection < Redpear::Connection
end

class Employee < User
end

class Manager < Employee
  self.connection = ManagerConnection.new
  self.scope      = 'execs'
end
