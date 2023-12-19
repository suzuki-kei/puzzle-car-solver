require 'car'

class Solver

    def initialize(initial_field)
        @initial_field = initial_field
        @answer_field = Field.new_empty_field(*initial_field.size)
        @unplaced_cells = initial_field.cells.to_a
        @cache = {}
        @attempts = 0
    end

    def solve
        # 動かせないセルを initial_field と同じ場所に配置する.
        place_fixed_cells

        # 一時停止セルを横断歩道の横に配置する.
        place_stop_cells

        # 残りのセルを総当たりで配置し, 正解を探す.
        [traverse(@unplaced_cells) ? @answer_field : nil, @attempts]
     end

    private

    def solved?
        begin
            Car.new(@answer_field).run!
        rescue CarCrushed
            false
        end
    end

    def place_fixed_cells
        @unplaced_cells.reject! do |cell|
            attempt_to_place_fixed_cell(cell)
        end
    end

    def attempt_to_place_fixed_cell(cell)
        unless cell.fixed?
            return false
        end

        true.tap do
            @answer_field[cell.row][cell.column] = cell
        end
    end

    def place_stop_cells
        @unplaced_cells.reject! do |cell|
            attempt_to_place_stop_cell(cell)
        end
    end

    def attempt_to_place_stop_cell(cell)
        unless cell.stop?
            return false
        end

        true.tap do
            row, column = find_stop_cell_position_to_place(cell)
            @answer_field[row][column] = cell
        end
    end

    def find_stop_cell_position_to_place(stop_cell)
        crossing_cell = @answer_field.cells.find do |cell|
            cell.crossing? && cell.to == stop_cell.to && cell.neighbor(cell.from).empty?
        end

        crossing_cell.neighbor(crossing_cell.from).position
    end

    def traverse(cells)
        if cells.empty?
            solved?
        else
            empty_cell = @answer_field.cells.select(&:empty?).first
            row, column = empty_cell.position

            cells.each.with_index do |cell, i|
                @attempts += 1
                puts "[DEBUG] attempts=#{@attempts}" if @attempts % 1000 == 0

                solved = cached(row, column, cell, cells) do
                    if can_be_placed?(row, column, cell)
                        @answer_field[row][column] = cell
                        traverse(cells.take(i) + cells.drop(i + 1))
                    else
                        false
                    end
                end

                if solved
                    return true
                else
                    @answer_field[row][column] = empty_cell
                end
            end

            false
        end
    end

    def cached(row, column, cell, unplaced_cells)
        cell = PositionedCell.peel_cell(cell)
        unplaced_cells = PositionedCell.peel_cells(unplaced_cells)

        # 同じセルが存在しない場合は同じ盤面は出現しないのでキャッシュしない.
        if unplaced_cells.count(cell) < 2
            return yield
        end

        @answer_field[row][column] = cell
        cache_key = @answer_field.hash
        @answer_field[row][column] = Cell::Empty.new

        if (solved = @cache[cache_key]).nil?
            yield.tap do |solved|
                @cache[cache_key] = solved
            end
        else
            solved
        end
    end

    def can_be_placed?(row, column, cell)
        method_names = %i(
            tunnel_cell_can_be_placed?
            street_cell_can_be_placed?
        )
        method_names.any? do |method_name|
            send(method_name, row, column, cell)
        end
    end

    # cell が answer_field[row][column] に配置可能な Cell::Tunnel の場合に true.
    def tunnel_cell_can_be_placed?(row, column, cell)
        cell.tunnel? &&
            !blocked_by_neighbor_cells?(row, column, cell) &&
            !block_neighbor_cells?(row, column, cell)
    end

    # cell が answer_field[row][column] に配置可能な Cell::Street の場合に true.
    def street_cell_can_be_placed?(row, column, cell)
        cell.street? &&
            !blocked_by_neighbor_cells?(row, column, cell) &&
            !block_neighbor_cells?(row, column, cell)
    end

    # cell への進入方向が隣接セルに塞がれると確定する場合は false を返す.
    def blocked_by_neighbor_cells?(row, column, cell)
        cell.directions.any? do |direction|
            neighbor_cell = @answer_field[row][column].neighbor(direction)
            reverse_direction = Cell.reverse_direction(direction)
            !neighbor_cell.empty? && !neighbor_cell.directions.include?(reverse_direction)
        end
    end

    # 隣接セルの進行方向を塞ぐ場合は false を返す.
    def block_neighbor_cells?(row, column, cell)
        cell.blocked_directions.any? do |blocked_direction|
            neighbor_cell = @answer_field[row][column].neighbor(blocked_direction)
            reverse_direction = Cell.reverse_direction(blocked_direction)
            neighbor_cell.directions.include?(reverse_direction)
        end
    end

end

