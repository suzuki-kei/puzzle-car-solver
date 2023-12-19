
class PositionedCell

    def self.peel_rows(rows)
        rows.map(&method(:peel_row))
    end

    def self.peel_row(row)
        row.map(&method(:peel_cell))
    end

    def self.peel_cell(cell)
        while cell.class == self
            cell = cell.cell
        end

        cell
    end

    attr_reader :field, :cell, :row, :column

    def initialize(field, cell, row, column)
        cell = self.class.peel_cell(cell)
        @field, @cell, @row, @column = field, cell, row, column
    end

    def position
        [@row, @column]
    end

    def neighbor(direction)
        case direction
            when :top
                @field[@row - 1][@column]
            when :bottom
                @field[@row + 1][@column]
            when :left
                @field[@row][@column - 1]
            when :right
                @field[@row][@column + 1]
            else
                raise "BUG: direction=#{direction}"
        end
    end

    def neighbors
        cells = [
            @field[@row - 1][@column],
            @field[@row + 1][@column],
            @field[@row][@column - 1],
            @field[@row][@column + 1],
        ]
        cells.reject(&:null?)
    end

    def method_missing(name, *arguments)
        if @cell.respond_to?(name)
            @cell.send(name, *arguments)
        else
            super
        end
    end

    def ==(other)
        equal_class?(other) && equal_all_fields?(other)
    end

    private

    def equal_class?(other)
        self.class == other.class
    end

    def equal_all_fields?(other)
        cell == other.cell && row == other.row && column == other.column
    end

end

