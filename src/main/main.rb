require 'exception'
require 'field'
require 'solver'

def main
    Dir['data/sample-problem-*.txt', 'data/problem-*.txt'].each do |file_path|
        puts "==== #{file_path}"
        initial_field = Field.from_file(file_path)
        solved_field, attempts = Solver.new(initial_field).solve
        puts "attempts = #{attempts}"
        puts solved_field.serialize.gsub(/^/, '    ')
    end
rescue Interrupt
    # Ctrl+C で終了した場合はスタックトレースを出さずに終了する.
end

main if $0 == __FILE__

