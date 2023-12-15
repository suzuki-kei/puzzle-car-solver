require 'exception'
require 'field'
require 'solver'

def main
    file_path = 'data/problem-11.txt'

    initial_field = Field.from_file(file_path)
    puts "==== initial field (file_path=#{file_path})"
    puts initial_field.serialize
    puts

    solved_field, attempts = Solver.new.solve(initial_field)
    puts "==== solved field (attempts=#{attempts})"
    puts solved_field.serialize if solved_field
    puts
rescue Interrupt
    # Ctrl+C で終了した場合はスタックトレースを出さずに終了する.
end

main if $0 == __FILE__

