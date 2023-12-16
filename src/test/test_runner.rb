require 'test/unit'
require 'cell'
require 'exception'
require 'field'
require 'runner'

class RunnerTestCase < Test::Unit::TestCase

    def test_run!
        assert_nothing_raised do
            Runner.new(Field.new([
                [Cell::Start.new(from=:top, to=:bottom)],
                [Cell::End.new(from=:top, to=:bottom)],
            ])).run!
        end

        assert_nothing_raised do
            Runner.new(Field.new([
                [Cell::Start.new(from=:top, to=:bottom), Cell::End.new(from=:bottom, to=:top)],
                [Cell::Street.new([[:top, :right]]),     Cell::Street.new([[:left, :top]])],
            ])).run!
        end

        assert_raise(CarCrushed) do
            Runner.new(Field.new([
                [Cell::Start.new(from=:top, to=:bottom)],
                [Cell::Tree.new],
            ])).run!
        end
    end

end

