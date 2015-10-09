module TooDone
  class TodoList < ActiveRecord::Base
    belongs_to :users
  end
end