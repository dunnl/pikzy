require 'erb'
require 'tempfile'
require 'fileutils'

TEMPLATE_DIR = "./template"

def escape_spaces(input_string)
  # Use gsub to replace all spaces with '\ '
  escaped_string = input_string.gsub(' ', '\ ')
  return escaped_string
  #return input_string
end

def command?(command)
  system("which #{command} > /dev/null 2>&1")
end

def oneTikzToPng (tikz_path)
  puts "oneTikzToPng: Called on #{tikz_path}"

  begin
    # Compute some paths
    tikz_dir = File.dirname(tikz_path)
    basename = File.basename(tikz_path, ".tikz")
    tikz_filename = basename + ".tikz"
    png_filename = basename + ".png"
    tex_filename = basename + ".tex"
    template_filename = File.join(TEMPLATE_DIR, "template.tex")

    # Interpolate template.tex and write out the result
    template_file = File.open(template_filename, "r")
    template_contents = ERB.new(template_file.read()).result(binding)
    template_file.close()

    # Open a temporary directory and copy all our files there
    Dir.mktmpdir {|tmp|
      puts "Creating temporary directory #{tmp}"

      puts "Copying contents of the \"./template\" directory"
      FileUtils.cp_r("#{TEMPLATE_DIR}/.", tmp)
      # N.B. Adding "/." copies the contents without creating "template/" under #{tmp}

      puts "Copying #{tikz_path}"
      FileUtils.cp(tikz_path, tmp)

      build_command = ["pdflatex", "-output-directory=#{tmp}", "-interaction=nonstopmode", "-shell-escape", escape_spaces(tex_filename)]
      #build_command = ["pdflatex", "-output-directory=#{tmp}", "-interaction=nonstopmode", escape_spaces(tex_filename)]

      Dir.chdir("#{tmp}") do
        puts "Moving inside temporary directory #{tmp}"

        # Write out interpolated .TeX file to compile
        main_file = File.open(tex_filename, "w")
        puts "Creating #{tex_filename} from template"
        main_file.write(template_contents)
        main_file.close()

        puts "Running command: #{build_command.join(' ')}"
        puts "Output file will be #{png_filename}"

        unless(system(*build_command, in: '/dev/null', out: '/dev/null'))
          exit_status = $?.exitstatus
          raise "Build command returned non-zero status: #{exit_status}"
        end
      end

      outdir = File.join("_out", tikz_dir)
      puts "Back to original working directory. Copying #{png_filename} to #{outdir}"
      FileUtils.mkdir_p(outdir)
      FileUtils.cp("#{tmp}/#{png_filename}", "#{outdir}")
    }
  rescue Errno::ENOENT => e
    puts "Caught ENOENT exception: #{e.message}"
  rescue RuntimeError => e
    puts "Runtime error: #{e.message}"
  rescue => e
    puts "Caught unknown exception: #{e.message}"
  end
  puts "**************************************************************************"
end

def manyTikzToPng (tikz_filenames)
  tikz_filenames.each {|x|
    puts "Calling on #{x}"
    oneTikzToPng("#{x}")
  }
end

def fileTikzToPng(tikz_filenames_file)
  File.readlines("#{tikz_filenames_file}", chomp: true).each do |line|
    oneTikzToPng("#{line}")
  end
end


filename = ARGV.first
fileTikzToPng(filename)
