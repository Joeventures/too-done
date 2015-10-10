require "too_done/version"
require "too_done/init_db"
require "too_done/user"
require "too_done/session"
require "too_done/todo_list"
require "too_done/task"

require "thor"
require "pry"

module TooDone
  class App < Thor

    desc "add 'TASK'", "Add a TASK to a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which the task will be filed under."
    #binding.pry
    option :date, :aliases => :d,
      :desc => "A Due Date in YYYY-MM-DD format."
    def add(task)
      # find or create the right todo list
      # create a new item under that list, with optional date
      list = TodoList.find_or_create_by(user_id: current_user.id, name: options[:list])
      if options[:date] == nil
        due_date = DateTime.now
      else
        due_date = DateTime.parse options[:date]
      end
      added_task = Task.create(todo_list_id: list.id,
                               due_date: due_date,
                               name: task,
                               completed: false)
    end

    desc "edit", "Edit a task from a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be edited."
    def edit
      # find the right todo list
      list = TodoList.find_by user_id: current_user.id, name: options[:list]
      # BAIL if it doesn't exist and have tasks
      if list == nil
        puts "Sorry. List not found."
        exit
      end
      # display the tasks and prompt for which one to edit
      tasks = Task.where todo_list_id: list.id, completed: false
      tasks.each do |task|
        #binding.pry
        due_date = task.due_date.strftime unless task.due_date == nil
        puts "ID: #{task.id} | Task: #{task.name} | Due: #{due_date}"
      end
      puts "Which task would you like to edit?"
      task_id = STDIN.gets.chomp.to_i
      # allow the user to change the title, due date
      puts "Enter the new title, or leave blank to leave it alone:"
      new_title = STDIN.gets.chomp
      puts "Enter the new due date in 'YYYY-MM-DD' format, or leave blank to leave it alone:"
      new_due_date = STDIN.gets.chomp

      edit_this_task = Task.find(task_id)
      edit_this_task.name = new_title unless new_title.empty?
      edit_this_task.due_date = new_due_date unless new_due_date.empty?
      edit_this_task.save
      puts "Task updated!"
    end

    desc "done", "Mark a task as completed."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be completed."
    def done
      # find the right todo list
      list = TodoList.find_by user_id: current_user.id, name: options[:list]
      # BAIL if it doesn't exist and have tasks
      if list == nil
        puts "Sorry. List not found."
        exit
      end
      # display the tasks and prompt for which one(s?) to mark done
      tasks = Task.where todo_list_id: list.id, completed: false
      tasks.each do |task|
        due_date = task.due_date.strftime unless task.due_date == nil
        puts "ID: #{task.id} | Task: #{task.name} | Due: #{due_date}"
      end
      puts "Which task would you like to mark as completed?"
      task_id = STDIN.gets.chomp.to_i
      done_this_task = Task.find(task_id)
      done_this_task.update completed: true
      puts "You're done!"
    end

    desc "show", "Show the tasks on a todo list in reverse order."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be shown."
    option :completed, :aliases => :c, :default => false, :type => :boolean,
      :desc => "Whether or not to show already completed tasks."
    option :sort, :aliases => :s, :enum => ['history', 'overdue'],
      :desc => "Sorting by 'history' (chronological) or 'overdue'.
      \t\t\t\t\tLimits results to those with a due date."
    def show
      # find or create the right todo list
      list = TodoList.find_by user_id: current_user.id, name: options[:list]
      if list == nil
        puts "Sorry. List not found."
        exit
      end
      tasks = Task.where todo_list_id: list.id, completed: false
      if tasks == nil
        puts "Relax. All tasks in this list have been completed."
        exit
      end
      # show the tasks ordered as requested, default to reverse order (recently entered first)
      tasks = tasks.order due_date: :desc 
      binding.pry

    end

    desc "delete [LIST OR USER]", "Delete a todo list or a user."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which will be deleted (including items)."
    option :user, :aliases => :u,
      :desc => "The user which will be deleted (including lists and items)."
    def delete
      # BAIL if both list and user options are provided
      # BAIL if neither list or user option is provided
      # find the matching user or list
      # BAIL if the user or list couldn't be found
      # delete them (and any dependents)
    end

    desc "switch USER", "Switch session to manage USER's todo lists."
    def switch(username)
      user = User.find_or_create_by(name: username)
      user.sessions.create
    end

    private
    def current_user
      Session.last.user
    end
  end
end

# binding.pry
TooDone::App.start(ARGV)
