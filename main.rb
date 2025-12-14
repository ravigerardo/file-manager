require 'glimmer-dsl-libui'

class FileManager
  include Glimmer

  Row = Struct.new(:type, :links, :owner, :group, :fsize, :updated_at, :name)
  attr_accessor :pwd, :rows, :history, :index_history

  HOME_PATH = '~'.freeze

  def initialize
    initial_sate
    set_rows
  end

  def initial_sate
    @pwd = HOME_PATH
    @rows = []
    @history = [HOME_PATH]
    @index_history = 0
  end

  def navegate(path)
    self.pwd = path
    set_rows
    self.history = @history[0..@index_history]
    self.history << path
    self.index_history = @history.size - 1
  end

  def navegate_history(is_back: false)
    return unless can_navegate?(is_back: is_back)

    index = is_back ? self.index_history - 1 : self.index_history + 1
    self.index_history = index
    path = @history[index]
    self.pwd = path
    set_rows
  end

  def can_navegate?(is_back: false)
    return false if is_back && @index_history < 1
    return false if !is_back && @index_history >= @history.size - 1

    true
  end

  def set_rows
    rows = []
    raw_rows = `ls -l #{@pwd}`.split("\n").drop(1)
    raw_rows.each do |c|
      raw_columns = c.split
      rows << Row.new(
        type: raw_columns[0],
        links: raw_columns[1],
        owner: raw_columns[2],
        group: raw_columns[3],
        fsize: raw_columns[4],
        updated_at: "#{raw_columns[5]} #{raw_columns[6]} #{raw_columns[7]}",
        name: raw_columns[8]
      )
    end

    self.rows = rows
  end

  def launch
    window('File Manager 🗃️') {
      margined true

      vertical_box {
        horizontal_box {
          stretchy false

          button('🏠') {
            stretchy false

            on_clicked do
              initial_sate
              set_rows
            end
          }
          button('⬅️') {
            stretchy false

            on_clicked do
              navegate_history is_back: true
            end
          }
          button('➡️') {
            stretchy false

            on_clicked do
              navegate_history
            end
          }
          label {
            stretchy false

            text <= [self, :pwd]
          }
        }
        table {
          text_column('Name')
          text_column('Updated at')
          text_column('Fsize')
          text_column('Type')

          on_row_double_clicked do |_table, index|
            row = @rows[index]
            realpath = `realpath #{@pwd}/#{row.name}`.chop

            if row.type[0] == 'd'
              navegate realpath
            elsif row.type[0] == '-'
              `open #{realpath}`
            end
          end

          cell_rows <= [self, :rows]
        }
      }
    }.show
  end
end

FileManager.new.launch
