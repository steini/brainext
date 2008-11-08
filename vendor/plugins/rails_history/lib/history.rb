module History
  def self.included(base)
    base.extend(ClassMethods)
  end

  class Container
    attr_writer :max, :default
    # create a new page history
    #
    # - the max parameter is the number of visited page to remember,
    # - the default parameter is the location where to redirect the user if the history is empty.
    #   it can be a url or a Hash like { :controller => "foo", :action => "bar" }
    def initialize(options = {})
      options = { :max => 5 }.merge(options)
      @max = options[:max]
      @default = options[:default]
      @skip = { }
    end

    # where to log messages
    def logger
      RAILS_DEFAULT_LOGGER
    end

    # store a page in the history
    def store(session, request, response)
      controller = request.parameters[:controller]
      action = request.parameters[:action]

      # we are forced to skip
      unless session[:skip_next].nil? or session[:skip_next] <= 0
        session[:skip_next] -= 1
        return
      end

      # don't store redirects
      if response.headers and response.headers["Status"] and response.headers["Status"][0,1] == "3"
        logger.debug("history: skipped redirect")
        return
      end

      # don't store skiped action
      if @skip[controller] and @skip[controller].include?(action)
        logger.debug("history: skipped action to skip")
        return
      end

      # don't store xml http request
      if request.xhr?
        logger.debug("history: skipped XML HTTP request")
        return
      end

      # don't store posts, puts and deletes
      if request.post? or request.put? or request.delete?
        logger.debug("history: skipped request")
        return
      end
      force_store session, request, response
    end

    # force addition of current request to the history
    def force_store(session, request, response)
      session[:history] ||= []

      # don't store refresh
      if request.request_uri == session[:history].last
        logger.debug("history: skipped refresh request")
        return
      end

      session[:history].push(request.request_uri)
      while session[:history].size > @max do
        session[:history].shift
      end
      logger.debug("history: added #{request.request_uri}")
    end

    # fetch the last location
    def peek(session, how_many = 1)
      session[:history] ||= []
      index = session[:history].size - how_many.to_i
      if index >= 0
        session[:history][index]
      else
        @default.dup
      end
    end

    # fetch a page from the history
    def back(session, how_many = 1)
      session[:history] ||= []
      last = nil

      (1..how_many.to_i).each do
        last = session[:history].pop

        if logger.debug?
          if last.nil?
            logger.debug("history: history empty, not removing anything")
          else
            logger.debug("history: removed #{last}")
          end
        end
      end

      if last.nil? and @default
        # if we have a default location, and history
        # is empty, redirect to it.
        last = @default.dup

        # don't store the rendering of our default location
        # if it is rendered by our application
        if @default.respond_to?(:[])
          logger.debug("not storing the next request")
          session[:skip_next] = 1
        end
      else
        # when we redirect back, we need to avoid saving uri
        # when we call store_location after the redirect
        logger.debug("not storing the next request")
        session[:skip_next] = 1
      end
      last
    end

    # add actions to the list of action to skip for the given controller
    def skip(controller, *actions)
      actions.map! { |action| action.to_s }
      @skip[controller] ||= []
      @skip[controller].concat(actions)
    end
  end

  module ClassMethods
    # initialize history plugin. options is a hash with the following parameters
    # - the max parameter is the number of visited page to remember,
    # - the default parameter is the location where to redirect the user if the history is empty.

    def history(options)
      logger.debug("history: setting up history")

      include History::InstanceMethods
      class_eval do
        ActionController::Base.history_container ||= History::Container.new(options)
        after_filter :store_location
      end

    end

    # don't store the given actions in the history
    def history_skip(*actions)
      actions.flatten!
      class_eval do
        ActionController::Base.history_container.skip(self.controller_name, *actions)
      end
    end
  end

  module InstanceMethods
    # look at last location. If <tt>how_many</tt> is given, fetch the nth location.
    def peek_last_location(how_many = 1)
      ActionController::Base.history_container.peek(session, how_many.to_i)
    end

    # fetch last location. If <tt>how_many</tt> is given, fetch the nth location.
    def last_location(how_many = 1)
      ActionController::Base.history_container.back(session, how_many.to_i)
    end

    # redirect to last saved location. If <tt>how_many</tt> is given, fetch the nth location.
    def redirect_back(how_many = 1)
      # it does not make sense to redirect_back an xml http request
      return false if request.xhr?

      last = ActionController::Base.history_container.back(session, how_many.to_i)
      unless last.nil?
        redirect_to(last)
        return true
      else
        return false
      end
    end

    # store location
    def store_location(force = false)
      if force
        ActionController::Base.history_container.force_store(session, request, response)
      else
        ActionController::Base.history_container.store(session, request, response)
      end
    end
  end
end

ActionController::Base.class_eval do
  cattr_accessor :history_container
  history_container = History::Container.new
  logger.debug("loading history")
  include History
end
