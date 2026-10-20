class AppState
  @instance = new
  private_class_method :new

  attr_accessor :os, :home_path

  def self.instance
    @instance
  end

  def set_state(os: nil, home_path: nil)
    @os ||= os
    @home_path ||= home_path
  end
end

class WindowState
  attr_accessor :pwd, :rows, :history, :index_history

  def initialize
    @pwd = AppState.instance.home_path
    @rows = []
    @history = [AppState.instance.home_path]
    @index_history = 0
  end
end
