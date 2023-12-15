require 'test/unit'
require 'cell'
require 'field'

class FieldTestCase < Test::Unit::TestCase

    def test_new_empty_field
        field = Field.new_empty_field(3, 5)
        assert_true field.cells.all?(&:empty?)
    end

    def test_operator_equals
        field1 = Field.new_empty_field(row=3, column=5)
        field2 = Field.new_empty_field(row=3, column=5)
        assert_true field1 == field2

        field1 = Field.new_empty_field(row=3, column=5)
        field2 = Field.new_empty_field(row=5, column=3)
        assert_false field1 == field2
    end

    def test_operator_at
        field = Field.new([
            [Cell::Start.new(from=:top, to=:bottom), Cell::End.new(from=:bottom, to=:top)],
            [Cell::Street.new([[:top, :right]]),     Cell::Street.new([[:left, :top]])],
        ])

        # フィールド内
        assert_true field[0][0].cell == Cell::Start.new(from=:top, to=:bottom)
        assert_true field[0][1].cell == Cell::End.new(from=:bottom, to=:top)
        assert_true field[1][0].cell == Cell::Street.new([[:top, :right]])
        assert_true field[1][1].cell == Cell::Street.new([[:left, :top]])

        # フィールド外
        assert_true field[-1][0].cell == Cell::Null.new
        assert_true field[2][0].cell == Cell::Null.new
        assert_true field[0][-1].cell == Cell::Null.new
        assert_true field[0][2].cell == Cell::Null.new
    end

    def test_row_size
        field = Field.new_empty_field(row=3, column=5)
        assert_equal 3, field.row_size
    end

    def test_column_size
        field = Field.new_empty_field(row=3, column=5)
        assert_equal 5, field.column_size
    end

    def test_cells
        field = Field.new([
            [Cell::Start.new(from=:top, to=:bottom), Cell::End.new(from=:bottom, to=:top)],
            [Cell::Street.new([[:top, :right]]),     Cell::Street.new([[:left, :top]])],
        ])
        assert_equal Enumerator, field.cells.class
        assert_equal 4, field.cells.size
        assert_equal Cell::Start.new(from=:top, to=:bottom), field.cells.to_a[0].cell
        assert_equal Cell::End.new(from=:bottom, to=:top), field.cells.to_a[1].cell
        assert_equal Cell::Street.new([[:top, :right]]), field.cells.to_a[2].cell
        assert_equal Cell::Street.new([[:left, :top]]), field.cells.to_a[3].cell
    end

end

