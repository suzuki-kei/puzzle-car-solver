
class FieldSerializer

    def serialize(field)
        serialize_rows(field.rows)
    end

    private

    def serialize_rows(rows)
        rows.map(&method(:serialize_row)).join("\n")
    end

    def serialize_row(row)
        row.map(&method(:serialize_cell)).join(' ')
    end

    def serialize_cell(cell)
        case
            when cell.empty?
                "#{cell.name}"
            when cell.start?
                "#{cell.name}({from=#{cell.from},to=#{cell.to}})"
            when cell.end?
                "#{cell.name}({from=#{cell.from},to=#{cell.to}})"
            when cell.street?
                serialized_two_ways = serialize_two_ways(cell.two_ways)
                "#{cell.name}(#{serialized_two_ways})"
            when cell.crossing?
                "#{cell.name}({from=#{cell.from},to=#{cell.to}})"
            when cell.stop?
                "#{cell.name}({from=#{cell.from},to=#{cell.to}})"
            when cell.tunnel?
                "#{cell.name}(#{cell.id},#{cell.direction})"
            when cell.tree?
                "#{cell.name}"
            when cell.waterway?
                "#{cell.name}"
            else
                raise "BUG: #{cell.name}"
        end
    end

    def serialize_two_ways(two_ways)
        two_ways.map(&method(:serialize_two_way)).join(',')
    end

    def serialize_two_way(two_way)
        "{#{two_way.join(',')}}"
    end

end

