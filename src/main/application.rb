require 'exception'
require 'field'
require 'solver'

class Application

    ROOT_DIR = File.absolute_path("#{File.dirname(__FILE__)}/../..")
    DATA_DIR = File.absolute_path("#{ROOT_DIR}/data")

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
    rescue PuzzleCarSolverError => exception
        $stderr.puts "[ERROR] #{exception.class} - #{exception.message}"
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
        Dir["#{DATA_DIR}/sample-problem-*.txt", "#{DATA_DIR}/problem-*.txt"]
    end

end

