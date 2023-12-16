require 'exception'

class Car

    Step = Data.define(:cell, :from, :to) do

        def to_s
            name_value_map = {
                :cell   => cell.name,
                :row    => cell.row,
                :column => cell.column,
                :from   => from,
                :to     => to,
            }
            attributes = name_value_map.map do |key, value|
                "#{key}=#{value}"
            end
            "#{self.class.name}(#{attributes.join(', ')})"
        end

    end

    def initialize(field)
        @field = field
        @cell = field.start_cell || Cell::Null.new
        @steps = []
    end

    def run!
        until @cell.end?
            next!
        end

        # ゴールに到達できない場合は CarCrushed が発生する.
        # ここを通るということはゴールに到達できたことを意味する.
        true
    end

    def next!
        send("move_from_#{@cell.name}")
    end

    private

    def move_from_null
        raise CarCrushed
    end

    def move_from_empty
        raise CarCrushed
    end

    def move_from_start
        from, to = @cell.from, @cell.to
        move_to(from, to)
    end

    def move_from_end
        from, to = @cell.from, @cell.to
        move_to(from, to)
    end

    def move_from_street
        from, to = find_two_way(@cell, @steps[-1].to)
        move_to(from, to)
    end

    def move_from_crossing
        # 横断歩道の直前では一時停止していなければならない.
        unless @steps[-1].cell.stop?
            raise CarCrushed
        end

        from, to = @cell.from, @cell.to
        move_to(from, to)
    end

    def move_from_stop
        from, to = @cell.from, @cell.to
        move_to(from, to)
    end

    def move_from_tunnel
        other_side_tunnel_cell = @field.other_side_tunnel_cell(@cell)
        from, to = @cell.direction, other_side_tunnel_cell.direction

        # トンネルは隣接しないセルに移動するので move_to() は呼ばずに個別調整する.
        @steps << Step.new(@cell, from, to)
        @cell = other_side_tunnel_cell

        # 次の繰り返しで move_from_tunnel に来ると無限ループするので次のセルに進める.
        from, to = Cell.reverse_direction(@cell.direction), @cell.direction
        move_to(from, to)
    end

    def move_from_tree
        raise CarCrushed
    end

    def move_from_waterway
        raise CarCrushed
    end

    def move_to(from, to)
        validate_direction_connectivity(from, @steps[-1].to) unless @steps.empty?
        @steps << Step.new(@cell, from, to)
        @cell = @cell.neighbor(to)
    end

    def validate_direction_connectivity(from, to)
        unless Cell.direction_connected?(from, to)
            raise CarCrushed
        end
    end

    def find_two_way(cell, previous_to)
        two_way = cell.two_ways.find do |two_way|
            two_way.include?(Cell.reverse_direction(previous_to))
        end

        if two_way.nil?
            raise CarCrushed
        end

        if two_way[0] == Cell.reverse_direction(previous_to)
            two_way
        else
            two_way.reverse
        end
    end

end

