
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

    attr_reader :cell, :row, :column

    def initialize(cell, row, column)
        cell = self.class.peel_cell(cell)
        @cell, @row, @column = cell, row, column
    end

    def method_missing(name, *arguments)
        if cell.respond_to?(name)
            cell.send(name, *arguments)
        else
            super
        end
    end

    def ==(other)
        cell == other.cell && row == other.row && column == other.column
    end

end

