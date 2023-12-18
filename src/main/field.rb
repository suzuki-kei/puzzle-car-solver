require 'exception'
require 'field_deserializer'
require 'field_serializer'
require 'positioned_cell'

class Field

    class RowAccessor

        def initialize(field, row)
            @field, @row = field, row
        end

        def [](column)
            if (0...@field.row_size).include?(@row) && (0...@field.column_size).include?(column)
                cell = @field.rows[@row][column]
            else
                cell = Cell::Null.new
            end

            PositionedCell.new(@field, cell, @row, column)
        end

        def []=(column, cell)
            @field.rows[@row][column] = PositionedCell.peel_cell(cell)
        end

    end

    def self.from_file(file_path)
        FieldDeserializer.new.deserialize(File.read(file_path))
    end

    def self.new_empty_field(row_size, column_size)
        Field.new(Array.new(row_size) {
            Array.new(column_size, Cell::Empty.new)
        })
    end

    attr_reader :rows

    def initialize(rows)
        @rows = PositionedCell.peel_rows(rows)
    end

    def ==(other)
        equal_size?(other) && equal_all_cells?(other)
    end

    def [](row)
        RowAccessor.new(self, row)
    end

    def size
        [row_size, column_size]
    end

    def row_size
        @rows.size
    end

    def column_size
        @rows.first.size
    end

    def each
        if block_given?
            enumerator.each do |cell|
                yield cell
            end
        else
            enumerator
        end
    end

    def cells
        each
    end

    def start_cell
        enumerator.find(&:start?)
    end

    def other_side_tunnel_cell(from_tunnel_cell)
        enumerator.select(&:tunnel?).find do |tunnel_cell|
            tunnel_cell != from_tunnel_cell && tunnel_cell.id == from_tunnel_cell.id
        end
    end

    def serialize
        FieldSerializer.new.serialize(self)
    end

    private

    def equal_size?(other)
        row_size == other.row_size && column_size == other.column_size
    end

    def equal_all_cells?(other)
        @rows.flatten == other.rows.flatten
    end

    def enumerator
        Enumerator.new(row_size * column_size) do |yielder|
            Enumerator.product(0...row_size, 0...column_size).each do |row, column|
                yielder << PositionedCell.new(self, @rows[row][column], row, column)
            end
        end
    end

end

