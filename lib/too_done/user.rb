module TooDone
  class User < ActiveRecord::Base
    has_many :sessions
    has_many :todo_lists
    belongs_to :tasks
  end
end
