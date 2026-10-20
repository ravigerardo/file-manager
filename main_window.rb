require 'glimmer-dsl-libui'

require_relative 'state'

class FileManager
  include Glimmer

  Row = Struct.new(:type, :links, :owner, :group, :fsize, :updated_at, :name)
  attr_accessor :state

  def initialize
    @state = WindowState.new
    set_rows
  end

  def navegate_to(path)
    self.state.pwd = path
    set_rows
    self.state.history = @state.history[0..@state.index_history]
    self.state.history << path
    self.state.index_history = @state.history.size - 1
  end

  def move_forward_in_history
    return unless can_move_in_history?(is_backward: false)

    navegate_in_history(index: @state.index_history + 1)
  end

  def move_backward_in_history
    return unless can_move_in_history?(is_backward: true)

    navegate_in_history(index: @state.index_history - 1)
  end

  def navegate_in_history(index: 0)
    self.state.index_history = index
    path = @state.history[index]
    self.state.pwd = path
    set_rows
  end

  def can_move_in_history?(is_backward: false)
    return false if is_backward && @state.index_history < 1
    return false if !is_backward && @state.index_history >= @state.history.size - 1

    true
  end

  def set_rows
    rows = []
    raw_rows = `ls -l #{@state.pwd}`.split("\n").drop(1)
    raw_rows.each do |c|
      raw_columns = c.split
      rows << Row.new(
        type: raw_columns[0],
        links: raw_columns[1],
        owner: raw_columns[2],
        group: raw_columns[3],
        fsize: raw_columns[4],
        updated_at: "#{raw_columns[5]} #{raw_columns[6]} #{raw_columns[7]}",
        name: raw_columns[8..].join("\s")
      )
    end

    self.state.rows = rows
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
              navegate_in_history(index: 0)
            end
          }
          button('⬅️') {
            stretchy false

            on_clicked do
              move_backward_in_history
            end
          }
          button('➡️') {
            stretchy false

            on_clicked do
              move_forward_in_history
            end
          }
          label {
            stretchy false

            text <= [self.state, :pwd]
          }
        }
        table {
          text_column('Name')
          text_column('Size')
          text_column('Updated at')

          on_row_double_clicked do |_table, index|
            row = @state.rows[index]
            realpath = `realpath #{@state.pwd}/"#{row.name}"`.chop.gsub("\s", "\\\s")

            if row.type[0] == 'd'
              navegate_to realpath
            elsif row.type[0] == '-'
              command = AppState.instance.os == :macos ? 'open' : 'xdg-open'
              `#{command} #{realpath}`
            end
          end

          cell_rows <= [self.state, :rows, { column_attributes: %i[name fsize updated_at] }]
        }
      }
    }.show
  end
end
