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
        atask = Task.create(name: task,list: alist)

        puts "Added #{task} to #{options[:list]}."

      # create a new item under that list, with optional date
    end

    desc "edit", "Edit a task from a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be edited."
    def edit
      # find the right todo list
       alist = List.find_or_create_by(name: options[:list],user_id: current_user.id)
      # BAIL if it doesn't exist and have tasks
      # display the tasks and prompt for which one to edit
      display_list(alist)
      puts "Enter the name of the completed task:"
      task_completed = STDIN.gets.chomp
      # allow the user to change the title, due date
    end

    desc "done", "Mark a task as completed."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be completed."
    def done
      # find the right todo list
      alist = List.find_or_create_by(name: options[:list],user_id: current_user.id)
      # BAIL if it doesn't exist and have tasks
      # display the tasks and prompt for which one(s?) to mark done
      display_list(alist)

      puts "Enter the name of the completed task:"
      task_completed = STDIN.gets.chomp
      #update to completed
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
      alist = List.find_or_create_by(name: options[:list],user_id: current_user.id)
      # show the tasks ordered as requested, default to reverse order (recently entered first)
      display_list(alist)
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

    def display_list(alist)
      tasks = Task.where(list_id = alist.id).order(id: :desc)

      tasks.each do |task|
        puts "Completed: #{task.completed}, Task: #{task.name}, Due Date: #{task.due_date}"
      end
    end

  end
end

# binding.pry
TooDone::App.start(ARGV)
