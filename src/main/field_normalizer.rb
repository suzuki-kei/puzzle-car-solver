
class FieldNormalizer

    def normalize(field)
        normalize!(field.clone)
    end

    def normalize!(field)
        field.tap do
            normalize_street_cells!(field)
            normalize_tunnel_cells!(field)
        end
    end

    private

    DIRECTION_TO_SORT_KEY_MAP = {
        :top    => 1,
        :left   => 2,
        :right  => 3,
        :bottom => 4,
    }.freeze

    def normalize_street_cells!(field)
        field.cells.select(&:street?).each do |street_cell|
            row, column = street_cell.position
            field[row][column] = normalize_street_cell(street_cell)
        end
    end

    # トンネルの出現順に ID を振り直す
    def normalize_tunnel_cells!(field)
        map = {}

        field.cells.select(&:tunnel?).each do |tunnel_cell|
            if (new_id = map[tunnel_cell.id]).nil?
                new_id = map.size + 1
                map[tunnel_cell.id] = new_id
            end

            row, column = tunnel_cell.position
            field[row][column] = Cell::Tunnel.new(new_id, tunnel_cell.direction)
        end
    end

    def normalize_street_cell(street_cell)
        Cell::Street.new(normalize_two_ways(street_cell.two_ways))
    end

    def normalize_two_ways(two_ways)
        two_ways.map(&method(:normalize_two_way)).sort_by do |two_way|
            to_sort_key_from_direction(two_way[0])
        end
    end

    def normalize_two_way(two_way)
        two_way.sort_by(&method(:to_sort_key_from_direction))
    end

    def to_sort_key_from_direction(direction)
        DIRECTION_TO_SORT_KEY_MAP.fetch(direction)
    end

end

