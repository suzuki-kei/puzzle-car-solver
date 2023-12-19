require 'test/unit'
require 'car'
require 'cell'
require 'exception'
require 'field'

class CarTestCase < Test::Unit::TestCase

    def test_run!
        assert_nothing_raised do
            Car.new(Field.new([
                [Cell::Start.new(from=:top, to=:bottom)],
                [Cell::End.new(from=:top, to=:bottom)],
            ])).run!
        end

        assert_nothing_raised do
            Car.new(Field.new([
                [Cell::Start.new(from=:top, to=:bottom), Cell::End.new(from=:bottom, to=:top)],
                [Cell::Street.new([[:top, :right]]),     Cell::Street.new([[:left, :top]])],
            ])).run!
        end

        assert_raise(CarCrushed) do
            Car.new(Field.new([
                [Cell::Start.new(from=:top, to=:bottom)],
                [Cell::Tree.new],
            ])).run!
        end
    end

    # トンネルを含むフィールドを扱えることのテスト.
    # 過去に問題 03 で動作確認している時にトンネルを正しく扱えない不具合が見つかった.
    def test_problem_03_run!
        # トンネルを含むフィールド (問題 03 の正解データ)
        field = FieldDeserializer.new.deserialize(<<-'EOS')
            end({from=bottom,to=top})  waterway          tunnel({1,bottom})    tree
            street({top,bottom})       waterway          street({top,bottom})  tree
            street({top,bottom})       waterway          street({top,bottom})  tree
            street({top,bottom})       waterway          street({top,right})   street({left,bottom})
            street({top,bottom})       waterway          waterway              street({top,bottom})
            street({top,right})        tunnel({1,left})  waterway              start({from=bottom,to=top})
        EOS

        assert_nothing_raised do
            Car.new(field).run!
        end
    end

end

