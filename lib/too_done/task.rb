module TooDone
  class Task < ActiveRecord::Base
    has_many :todo_lists
  end
end