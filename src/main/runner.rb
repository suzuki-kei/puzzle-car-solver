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

    class Context

        attr_reader :field, :steps, :cell

        def initialize(field)
            @field = field
            @cell  = field.start_cell || Cell::Null.new
            @steps = []
        end

        def end?
            @cell.end?
        end

        def move!(from, to)
            validate_direction_connectivity(from, @steps[-1].to) unless @steps.empty?
            @steps << Step.new(@cell, from, to)
            @cell = next_cell(to)
        end

        def dump
            @steps.each.with_index do |step, index|
                puts step
            end
        end

        private

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
                    raise "BUG: row=#{@row}, column=#{@column}, to=#{to}"
            end
        end

    end

    def run(field)
        context = Context.new(field)
        run_steps(context)

        # ゴールに到達できない場合は CarCrushed が発生する.
        # ここを通るということはゴールに到達できたことを意味する.
        true
    end

    private

    def run_steps(context)
        until context.end?
            run_step(context)
        end
    end

    def run_step(context)
        method_name = "move_from_#{context.cell.name}"
        send(method_name, context)
    end

    def move_from_null(context)
        raise CarCrushed
    end

    def move_from_empty(context)
        raise CarCrushed
    end

    def move_from_start(context)
        from, to = context.cell.from, context.cell.to
        context.move!(from, to)
    end

    def move_from_end(context)
        from, to = context.cell.from, context.cell.to
        context.move!(from, to)
    end

    def move_from_street(context)
        from, to = find_two_way(context.cell, context.steps[-1].to)
        context.move!(from, to)
    end

    def move_from_crossing(context)
        # 横断歩道の直前では一時停止していなければならない.
        unless context.steps[-1].cell.stop?
            raise CarCrushed
        end

        from, to = context.cell.from, context.cell.to
        context.move!(from, to)
    end

    def move_from_stop(context)
        from, to = context.cell.from, context.cell.to
        context.move!(from, to)
    end

    def move_from_tunnel(context)
        from_tunnel_cell = context.cell
        to_tunnel_cell = context.field.other_side_tunnel_cell(from_tunnel_cell)
        from, to = from_tunnel_cell.direction, to_tunnel_cell.direction
        context.move!(from, to)
    end

    def move_from_tree(context)
        raise CarCrushed
    end

    def move_from_waterway(context)
        raise CarCrushed
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

