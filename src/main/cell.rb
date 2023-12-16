
module Cell

    def self.new_cell_class(fields, movable, passable)
        Class.new do
            #
            # NOTE: 外側のスコープの変数をクラス内のスコープに持ち込む.
            #
            #  * https://docs.ruby-lang.org/ja/latest/method/Module/i/define_method.html
            #    - define_method に与えたブロックは, 定義したメソッドの実行時に instance_eval される.
            #    - instance_eval はレシーバクラスのインスタンス上でおこなわれる.
            #  * https://docs.ruby-lang.org/ja/latest/method/BasicObject/i/instance_eval.html
            #    - instance_eval はブロックを評価するときに外側のスコープとローカル変数を共有する.
            #
            private define_method(:fields) { fields }
            private define_method(:movable) { movable }
            private define_method(:passable) { passable }

            attr_reader *fields

            def initialize(*arguments, **keyword_arguments)
                Hash[fields.zip(arguments)].update(keyword_arguments).each do |key, value|
                    unless fields.include?(key)
                        raise ArgumentError, "invalid keyword argument: key=[#{key}]"
                    end
                    if value.nil?
                        raise ArgumentError, "#{key} must not be nil."
                    end
                    instance_variable_set("@#{key}", value)
                end
            end

            # クラス名をスネークケースにしたシンボル.
            def name
                class_name = self.class.name.split('::')[-1]
                class_name.scan(/[A-Z][a-z]*/).map(&:downcase).join('_').to_sym
            end

            def fixed?
                !movable
            end

            def movable?
                movable
            end

            def passable?
                passable
            end

            def maybe_passable?
                empty? || passable?
            end

            def cross_street?
                street? && two_ways.size == 2
            end

            %i(null empty start end street crossing stop tunnel tree waterway).each do |name|
                define_method("#{name}?") do
                    name == self.name
                end
            end

            def ==(other)
                equal_class?(other) && equal_all_fields?(other)
            end

            private

            def equal_class?(other)
                self.class == other.class
            end

            def equal_all_fields?(other)
                fields.all? do |field|
                    self_value = self.instance_variable_get("@#{field}")
                    other_value = other.instance_variable_get("@#{field}")
                    self_value == other_value
                end
            end
        end
    end

    # 隣接するセルが接続されているか判定する.
    # 前のセルを exit_direction 方向に退出し, 次のセルに enter_direction 方向から進入できる場合は true.
    def self.direction_connected?(exit_direction, enter_direction)
        exit_direction == reverse_direction(enter_direction)
    end

    def self.reverse_direction(direction)
        map = {
            :top    => :bottom,
            :bottom => :top,
            :left   => :right,
            :right  => :left,
        }
        map.fetch(direction)
    end

    # Null はフィールド外, Empty は未確定セルを表す.
    Null     = new_cell_class(fields=%i(),             movable=false, passable=false)
    Empty    = new_cell_class(fields=%i(),             movable=true,  passable=false)
    Start    = new_cell_class(fields=%i(from to),      movable=false, passable=true)
    End      = new_cell_class(fields=%i(from to),      movable=false, passable=true)
    Street   = new_cell_class(fields=%i(two_ways),     movable=true,  passable=true)
    Crossing = new_cell_class(fields=%i(from to),      movable=false, passable=true)
    Stop     = new_cell_class(fields=%i(from to),      movable=true,  passable=true)
    Tunnel   = new_cell_class(fields=%i(id direction), movable=true,  passable=true)
    Tree     = new_cell_class(fields=%i(),             movable=false, passable=false)
    Waterway = new_cell_class(fields=%i(),             movable=false, passable=false)

end

