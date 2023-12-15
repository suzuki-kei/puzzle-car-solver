require 'runner'

class Solver

    def solve(initial_field)
        cells = initial_field.cells
        answer_field = new_empty_field(initial_field)

        # 動かせないセルを initial_field と同じ場所に配置する.
        fixed_cells, cells = cells.partition(&:fixed?)
        place_fixed_cells(answer_field, fixed_cells)

        # 一時停止セルを横断歩道の横に配置する.
        stop_cells, cells = cells.partition(&:stop?)
        place_stop_cells(answer_field, stop_cells)

        # 十字路を配置する.
        cross_street_cells, cells = cells.partition(&:cross_street?)
        place_cross_street_cells(answer_field, cross_street_cells)

        # 残りのセルを総当たりで配置し, 正解を探す.
        solved, attempts = traverse(answer_field, cells)
        [(solved ? answer_field : nil), attempts]
    end

    private

    def new_empty_field(initial_field)
        Field.new_empty_field(initial_field.row_size, initial_field.column_size)
    end

    def solved?(field)
        begin
            !!Runner.new.run(field)
        rescue CarCrushed
            false
        end
    end

    def place_fixed_cells(answer_field, fixed_cells)
        fixed_cells.each do |cell|
            answer_field[cell.row][cell.column] = cell
        end
    end

    def place_stop_cells(answer_field, stop_cells)
        stop_cells.each do |stop_cell|
            place_stop_cell(answer_field, stop_cell)
        end
    end

    def place_stop_cell(answer_field, stop_cell)
        row, column = find_stop_cell_position(answer_field, stop_cell)
        answer_field[row][column] = stop_cell
    end

    def find_stop_cell_position(answer_field, stop_cell)
        crossing_cell = answer_field.cells.select(&:crossing?).find do |crossing_cell|
            stop_cell.to == crossing_cell.to
        end

        case crossing_cell.from
            when :top
                [crossing_cell.row - 1, crossing_cell.column]
            when :bottom
                [crossing_cell.row + 1, crossing_cell.column]
            when :left
                [crossing_cell.row, crossing_cell.column - 1]
            when :right
                [crossing_cell.row, crossing_cell.column + 1]
            else
                raise 'BUG'
        end
    end

    def place_cross_street_cells(answer_field, cross_street_cells)
        cross_street_cells.each do |cross_street_cell|
            place_cross_street_cell(answer_field, cross_street_cell)
        end
    end

    def place_cross_street_cell(answer_field, cross_street_cell)
        row, column = find_cross_street_cell_position(answer_field, cross_street_cell)
        answer_field[row][column] = cross_street_cell
    end

    def find_cross_street_cell_position(answer_field, cross_street_cell)
        answer_field.cells.select(&:empty?).each do |cell|
            if cell.neighbors.size == 4 && cell.neighbors.all?(&:may_be_passable?)
                return [cell.row, cell.column]
            end
        end
    end

    def traverse(answer_field, cells, attempts=0)
        if cells.empty?
            [solved?(answer_field), attempts]
        else
            empty_cell = answer_field.cells.select(&:empty?).first
            row, column = empty_cell.row, empty_cell.column

            cells.each.with_index do |cell, i|
                attempts += 1
                puts "[DEBUG] attempts=#{attempts}" if attempts % 1000 == 0

                if can_be_placed?(answer_field, row, column, cell)
                    answer_field[row][column] = cell
                    remaining_cells = cells.take(i) + cells.drop(i + 1)
                    solved, attempts = traverse(answer_field, remaining_cells, attempts)

                    if solved
                        return [solved, attempts]
                    else
                        answer_field[row][column] = empty_cell
                    end
                end
            end

            [false, attempts]
        end
    end

    def can_be_placed?(answer_field, row, column, cell)
        # Cell::Empty の場合は通過できるか未確定なので,
        # 通過できる場合と通過できない場合の両方を考慮して判断する.
        lower = cell.neighbors.count(&:passable?)
        upper = lower + cell.neighbors.count(&:empty?)

        (lower..upper).any? do |count|
            case count
                when 1
                    placeable_tunnel_cell?(answer_field, row, column, cell)
                when 2
                    placeable_street_cell?(answer_field, row, column, cell)
                when 3
                    placeable_tunnel_cell?(answer_field, row, column, cell) ||
                        placeable_street_cell?(answer_field, row, column, cell)
                when 4
                    placeable_street_cell?(answer_field, row, column, cell)
                else
                    false
            end
        end
    end

    # cell が answer_field[row][column] に配置可能な Cell::Tunnel の場合に true.
    def placeable_tunnel_cell?(answer_field, row, column, cell)
        cell.tunnel? && neighbor_is_empty_or_passable?(answer_field, row, column, cell.direction)
    end

    # cell が answer_field[row][column] に配置可能な Cell::Street の場合に true.
    def placeable_street_cell?(answer_field, row, column, cell)
        cell.street? && cell.two_ways.flatten.all? do |direction|
            neighbor_is_empty_or_passable?(answer_field, row, column, direction)
        end
    end

    def neighbor_is_empty_or_passable?(answer_field, row, column, direction)
        case direction
            when :top
                answer_field[row - 1][column].may_be_passable?
            when :bottom
                answer_field[row + 1][column].may_be_passable?
            when :left
                answer_field[row][column - 1].may_be_passable?
            when :right
                answer_field[row][column + 1].may_be_passable?
            else
                raise 'BUG'
        end
    end

end

