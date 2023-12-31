require 'test/unit'
require 'cell'

class CellTestCase < Test::Unit::TestCase

    def test_name
        assert_equal :null,     Cell::Null.new.name
        assert_equal :empty,    Cell::Empty.new.name
        assert_equal :start,    Cell::Start.new(from=:top, to=:bottom).name
        assert_equal :end,      Cell::End.new(from=:top, to=:bottom).name
        assert_equal :street,   Cell::Street.new([[:top, :bottom]]).name
        assert_equal :crossing, Cell::Crossing.new(from=:top, to=:bottom).name
        assert_equal :stop,     Cell::Stop.new(from=:top, to=:bottom).name
        assert_equal :tunnel,   Cell::Tunnel.new(1, :top).name
        assert_equal :tree,     Cell::Tree.new.name
        assert_equal :waterway, Cell::Waterway.new.name
    end

    def test_directions
        assert_equal %i(),           Cell::Null.new.directions
        assert_equal %i(),           Cell::Empty.new.directions
        assert_equal %i(top bottom), Cell::Start.new(from=:top, to=:bottom).directions
        assert_equal %i(top bottom), Cell::End.new(from=:top, to=:bottom).directions
        assert_equal %i(top bottom), Cell::Street.new([[:top, :bottom]]).directions
        assert_equal %i(top bottom), Cell::Crossing.new(from=:top, to=:bottom).directions
        assert_equal %i(top bottom), Cell::Stop.new(from=:top, to=:bottom).directions
        assert_equal %i(top),        Cell::Tunnel.new(1, :top).directions
        assert_equal %i(),           Cell::Tree.new.directions
        assert_equal %i(),           Cell::Waterway.new.directions
    end

    def test_blocked_directions
        assert_equal %i(top bottom left right), Cell::Null.new.blocked_directions
        assert_equal %i(top bottom left right), Cell::Empty.new.blocked_directions
        assert_equal %i(left right),            Cell::Start.new(from=:top, to=:bottom).blocked_directions
        assert_equal %i(left right),            Cell::End.new(from=:top, to=:bottom).blocked_directions
        assert_equal %i(left right),            Cell::Street.new([[:top, :bottom]]).blocked_directions
        assert_equal %i(left right),            Cell::Crossing.new(from=:top, to=:bottom).blocked_directions
        assert_equal %i(left right),            Cell::Stop.new(from=:top, to=:bottom).blocked_directions
        assert_equal %i(bottom left right),     Cell::Tunnel.new(1, :top).blocked_directions
        assert_equal %i(top bottom left right), Cell::Tree.new.blocked_directions
        assert_equal %i(top bottom left right), Cell::Waterway.new.blocked_directions
    end

    def test_operator_equals
        assert_true Cell::Empty.new == Cell::Empty.new
        assert_true Cell::Street.new([[:top, :bottom]]) == Cell::Street.new([[:top, :bottom]])

        assert_false Cell::Tree.new == Cell::Waterway.new
        assert_false Cell::Start.new(from=:top, to=:bottom) == Cell::End.new(from=:top, to=:bottom)
        assert_false Cell::Street.new([[:top, :bottom]]) == Cell::Street.new([[:top, :right]])

        # TODO: <two-way> は値の順番が違うだけの場合は同値と判断する.
        assert_false Cell::Street.new([[:top, :bottom]]) == Cell::Street.new([[:bottom, :top]])
    end

end

