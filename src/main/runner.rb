require 'exception'

class Runner

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
        from_tunnel_cell = @cell
        to_tunnel_cell = @field.other_side_tunnel_cell(from_tunnel_cell)
        from, to = from_tunnel_cell.direction, to_tunnel_cell.direction
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
        @cell = next_cell(to)
    end

    def validate_direction_connectivity(from, to)
        valid_direction_pairs = [
            [:top, :bottom],
            [:bottom, :top],
            [:left, :right],
            [:right, :left],
        ]

        unless valid_direction_pairs.include?([from, to])
            raise CarCrushed
        end
    end

    def next_cell(to)
        case to
            when :top
                @field[@cell.row - 1][@cell.column]
            when :bottom
                @field[@cell.row + 1][@cell.column]
            when :left
                @field[@cell.row][@cell.column - 1]
            when :right
                @field[@cell.row][@cell.column + 1]
            else
                raise "BUG: row=#{@cell.row}, column=#{@cell.column}, to=#{to}"
        end
    end

    def find_two_way(cell, previous_to)
        two_way = cell.two_ways.find do |two_way|
            two_way.include?(reverse_direction(previous_to))
        end

        if two_way.nil?
            raise CarCrushed
        end

        if two_way[0] == reverse_direction(previous_to)
            two_way
        else
            two_way.reverse
        end
    end

    def reverse_direction(direction)
        map = {
            :top    => :bottom,
            :bottom => :top,
            :left   => :right,
            :right  => :left,
        }
        map.fetch(direction)
    end

end

