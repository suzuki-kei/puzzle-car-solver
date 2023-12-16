require 'car'

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
            Car.new(field).run!
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
        crossing_cell = answer_field.cells.find do |cell|
            cell.crossing? && cell.to == stop_cell.to && cell.neighbor(cell.from).empty?
        end

        empty_cell = crossing_cell.neighbor(crossing_cell.from)
        [empty_cell.row, empty_cell.column]
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
        cell = answer_field.cells.select(&:empty?).find do |cell|
            cell.neighbors.size == 4 && cell.neighbors.all?(&:maybe_passable?)
        end
        [cell.row, cell.column]
    end

    def traverse(answer_field, cells, cache=Hash.new, attempts=0)
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
                    serialized_field = answer_field.serialize
                    if (solved = cache[serialized_field]).nil?
                        remaining_cells = cells.take(i) + cells.drop(i + 1)
                        solved, attempts = traverse(answer_field, remaining_cells, cache, attempts)
                        cache[serialized_field] = solved
                    end

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
        tunnel_cell_can_be_placed?(answer_field, row, column, cell) ||
            street_cell_can_be_placed?(answer_field, row, column, cell)
    end

    # cell が answer_field[row][column] に配置可能な Cell::Tunnel の場合に true.
    def tunnel_cell_can_be_placed?(answer_field, row, column, cell)
        cell.tunnel? &&
            !blocked_by_neighbor_cells?(answer_field, row, column, cell) &&
            !block_neighbor_cells?(answer_field, row, column, cell)
    end

    # cell が answer_field[row][column] に配置可能な Cell::Street の場合に true.
    def street_cell_can_be_placed?(answer_field, row, column, cell)
        cell.street? &&
            !blocked_by_neighbor_cells?(answer_field, row, column, cell) &&
            !block_neighbor_cells?(answer_field, row, column, cell)
    end

    # cell への進入方向が隣接セルに塞がれると確定する場合は false を返す.
    def blocked_by_neighbor_cells?(answer_field, row, column, cell)
        cell.directions.any? do |direction|
            neighbor_cell = answer_field[row][column].neighbor(direction)
            reverse_direction = Cell.reverse_direction(direction)
            !neighbor_cell.empty? && !neighbor_cell.directions.include?(reverse_direction)
        end
    end

    # 隣接セルの進行方向を塞ぐ場合は false を返す.
    def block_neighbor_cells?(answer_field, row, column, cell)
        cell.blocked_directions.any? do |blocked_direction|
            neighbor_cell = answer_field[row][column].neighbor(blocked_direction)
            reverse_direction = Cell.reverse_direction(blocked_direction)
            neighbor_cell.directions.include?(reverse_direction)
        end
    end

end

