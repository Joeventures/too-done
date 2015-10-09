module TooDone
  class TodoList < ActiveRecord::Base
    belongs_to :users
    has_many :tasks
  end
end