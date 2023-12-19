require 'field'
require 'solver'

class Application

    def run
        subcommand = ARGV.first || 'solve'

        case subcommand
            when 'solve'
                solve_problems
            when 'normalize-problem-files'
                normalize_problem_files
            else
                $stderr.puts "Invalid subcommand: subcommand=[#{subcommand}]"
                exit(1)
        end
    rescue Interrupt
        # Ctrl+C で終了した場合はスタックトレースを出さずに終了する.
    end

    def solve_problems
        problem_file_paths.each do |file_path|
            puts "==== #{file_path}"
            initial_field = Field.from_file(file_path)
            solved_field, attempts = Solver.new(initial_field).solve
            puts "attempts = #{attempts}"
            puts solved_field.serialize.gsub(/^/, '    ')
        end
    end

    def normalize_problem_files
        problem_file_paths.each do |file_path|
            field = Field.from_file(file_path)
            open(file_path, 'w') do |file|
                file.puts field.normalize.serialize
                file.puts
            end
        end
    end

    def problem_file_paths
        Dir['data/sample-problem-*.txt', 'data/problem-*.txt']
    end

end
