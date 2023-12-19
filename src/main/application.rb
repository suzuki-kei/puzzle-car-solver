require 'exception'
require 'field'
require 'pathname'
require 'solver'

class Application

    ROOT_DIR = File.absolute_path("#{File.dirname(__FILE__)}/../..")
    DATA_DIR = "#{ROOT_DIR}/data"
    TARGET_DIR = "#{ROOT_DIR}/target"
    SOLVED_DATA_DIR = "#{TARGET_DIR}/solved"

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
        Pathname.new(SOLVED_DATA_DIR).mkpath

        problem_file_pathnames.each do |pathname|
            puts "==== #{pathname.basename}"
            initial_field = Field.from_file(pathname)
            solved_field, attempts = Solver.new(initial_field).solve
            puts "attempts = #{attempts}"

            open("#{SOLVED_DATA_DIR}/#{pathname.basename}", 'w') do |file|
                file.puts solved_field.serialize
                file.puts
            end
        end
    end

    def normalize_problem_files
        problem_file_pathnames.each do |pathname|
            field = Field.from_file(pathname)
            open(pathname, 'w') do |file|
                file.puts field.normalize.serialize
                file.puts
            end
        end
    end

    def problem_file_pathnames
        patterns = [
            "#{DATA_DIR}/sample-problem-*.txt",
            "#{DATA_DIR}/problem-*.txt",
        ]
        Dir[*patterns].map(&Pathname.method(:new))
    end

end

