require 'exception'
require 'field'
require 'solver'

def main
    initial_field = Field.from_file('data/problem-11.txt')
    puts '==== initial field'
    puts initial_field.serialize

    puts '==== solved field'
    solved_field, attempts = Solver.new.solve(initial_field)
    puts "attempts = #{attempts}"
    puts solved_field.serialize if solved_field
rescue Interrupt
    # Ctrl+C で終了した場合はスタックトレースを出さずに終了する.
end

main if $0 == __FILE__

