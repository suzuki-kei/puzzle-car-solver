require 'cell'
require 'exception'

class FieldDeserializer

    def deserialize(serialized_field)
        field_rows = deserialize_field(serialized_field)
        validate_field_rows(field_rows)
        Field.new(field_rows)
    end

    private

    def deserialize_field(serialized_field)
        serialized_field.strip.lines.map(&:strip).map.with_index do |serialized_rows, row_index|
            serialized_rows.split.map.with_index do |serialized_cell, column_index|
                begin
                    deserialize_cell(serialized_cell)
                rescue InvalidCellDefinition
                    message = [
                        "serialized_cell=[#{serialized_cell}]",
                        "row=#{row_index + 1}",
                        "column=#{column_index + 1}",
                    ].join(', ')
                    raise InvalidCellDefinition, message
                end
            end
        end
    end

    def deserialize_cell(serialized_cell)
        re_direction = /(top|bottom|left|right)/
        re_from      = /from=#{re_direction}/
        re_to        = /to=#{re_direction}/
        re_one_way   = /{#{re_from},#{re_to}}/
        re_two_way   = /{#{re_direction},#{re_direction}}/
        re_two_ways  = /#{re_two_way}(?:,#{re_two_way})*/
        re_id        = /([1-9][0-9]*)/

        case serialized_cell
            when /\Aempty\z/
                Cell::Empty.new
            when /\Astart\(#{re_one_way}\)\z/
                from, to = $~[1..].map(&:to_sym)
                Cell::Start.new(from, to)
            when /\Aend\(#{re_one_way}\)\z/
                from, to = $~[1..].map(&:to_sym)
                Cell::End.new(from, to)
            when /\Astreet\(#{re_two_ways}\)\z/
                two_ways = $&.scan(re_two_way).map{|matches| matches.map(&:to_sym)}
                Cell::Street.new(two_ways)
            when /\Acrossing\(#{re_one_way}\)\z/
                from, to = $~[1..].map(&:to_sym)
                Cell::Crossing.new(from, to)
            when /\Astop\(#{re_one_way}\)\z/
                from, to = $~[1..].map(&:to_sym)
                Cell::Stop.new(from, to)
            when /\Atunnel\(#{re_id},#{re_direction}\)\z/
                id, direction = $~[1..].map(&:to_sym)
                Cell::Tunnel.new(id, direction)
            when /\Atree\z/
                Cell::Tree.new
            when /\Awaterway\z/
                Cell::Waterway.new
            else
                raise InvalidCellDefinition, serialized_cell
        end
    end

    def validate_field_rows(field_rows)
        # 全ての行の長さが同じであることを検証する.
        if field_rows.map(&:size).tally.size != 1
            message = '長さの異なる行が存在します'
            raise InvalidFieldDefinition, message
        end

        # スタート地点が 1 つだけであることを検証する.
        if field_rows.flatten.count(&:start?) != 1
            message = 'スタート地点の数が 1 ではありません'
            raise InvalidFieldDefinition, message
        end

        # ゴール地点が 1 つだけであることを検証する.
        if field_rows.flatten.count(&:end?) != 1
            message = 'ゴール地点の数が 1 ではありません'
            raise InvalidFieldDefinition, message
        end

        # 全てのトンネルが対になっていることを検証する.
        # (対になっている = 同じ id のトンネルが存在する)
        field_rows.flatten.select(&:tunnel?).map(&:id).tally.each do |id, count|
            if count != 2
                message = "トンネルの id=#{id} が #{count} 個存在します"
                raise InvalidCellDefinition, message
            end
        end
    end

end

