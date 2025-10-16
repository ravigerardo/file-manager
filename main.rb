require 'glimmer-dsl-libui'

class FileManager
  include Glimmer

  Row = Struct.new(:type, :links, :owner, :group, :fsize, :updated_at, :name)
  attr_accessor :pwd, :rows

  def initialize
    @pwd = '~'
    @rows = []
    set_rows
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
              self.pwd = '~'
              set_rows
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
          text_column('Size')
          text_column('Type')

          on_row_double_clicked do |_table, index|
            row = @rows[index]
            realpath = `realpath #{@pwd}/#{row.name}`.chop

            if row.type[0] == 'd'
              self.pwd = realpath
              set_rows
            elsif row.type[0] == '-'
              `open #{realpath}`
            end
          end

          cell_rows <= [self, :rows]
        }
      }
    }.show
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
end

FileManager.new.launch
