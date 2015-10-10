require "too_done/version"
require "too_done/init_db"
require "too_done/user"
require "too_done/session"
require "too_done/list"
require "too_done/task"


require "thor"
require "pry"

module TooDone
  class App < Thor

    desc "add 'TASK'", "Add a TASK to a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which the task will be filed under."
    option :date, :aliases => :d,
      :desc => "A Due Date in YYYY-MM-DD format."
    def add(task)
      # find or create the right todo list
    
        binding.pry
        alist = List.find_or_create_by(name: options[:list],user_id: current_user.id)
        if options[:date] == ""
          atask = Task.create(name: task,list: alist)
        else
          atask = Task.create(name: task,list: alist,due_date: options[:date])
        end 


        puts "Added #{task} to #{options[:list]}."

      # create a new item under that list, with optional date
    end

    desc "edit", "Edit a task from a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be edited."
    def edit
      completed = false
      sort = "desc"
      # find the right todo list
       alist = List.find_or_create_by(name: options[:list],user_id: current_user.id)
      # BAIL if it doesn't exist and have tasks
      # display the tasks and prompt for which one to edit
      display_list(alist,completed,sort)
      puts "Enter the name of the task to edit:"
      task_to_edit = STDIN.gets.chomp
      # allow the user to change the title, due date
      puts "Enter the field to edit (title or due date)"
      field_to_edit = STDIN.gets.chomp
      puts "Enter the new value:"
      new_value = STDIN.gets.chomp

      task = Task.find_by(name: task_to_edit)
      if field_to_edit == "due date"
        task.update(due_date: new_value)
      else
        task.update(name: new_value)
      end
      puts "#{task.name} updated."
    end

    desc "done", "Mark a task as completed."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be completed."
    def done
      completed = false
      sort = "desc"
      # find the right todo list
      alist = List.find_or_create_by(name: options[:list],user_id: current_user.id)
      # BAIL if it doesn't exist and have tasks
      # display the tasks and prompt for which one(s?) to mark done
      display_list(alist,completed,sort)

      puts "Enter the name of the completed task:"
      task_completed = STDIN.gets.chomp
      #update to completed
      task = Task.find_by(name: task_completed)
      task.update(completed: true)
      puts "#{task_completed} marked as completed"
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
      completed = options[:completed]
      sort = "desc"
      if options[:sort] == 'history' || options[:sort] == 'overdue'
        sort = options[:sort]
      end
    
      # find or create the right todo list
      alist = List.find_or_create_by(name: options[:list],user_id: current_user.id)
      # show the tasks ordered as requested, default to reverse order (recently entered first)
      display_list(alist,completed,sort)
    end

    desc "delete [LIST OR USER]", "Delete a todo list or a user."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which will be deleted (including items)."
    option :user, :aliases => :u,
      :desc => "The user which will be deleted (including lists and items)."
    def delete
      #UT won. Changing code just to commit to github
      # BAIL if both list and user options are provided
      # BAIL if neither list or user option is provided
      # find the matching user or list
      alist = List.find_or_create_by(name: options[:list],user_id: current_user.id)
      # BAIL if the user or list couldn't be found
      # delete them (and any dependents)
      # delete tasks then the lists then user
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

    def display_list(alist,completed,sort)
      #sort = desc (default) , history or overdue
      #completed: show completed tasks

      tasks = Task.where(list_id = alist.id, completed: completed).order(id: :desc)

      tasks.each do |task|
        puts "Completed: #{task.completed}, Task: #{task.name}, Due Date: #{task.due_date}"
      end
    end

  end
end

# binding.pry
TooDone::App.start(ARGV)
