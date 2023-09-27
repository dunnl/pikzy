require 'erb'
require 'tempfile'
require 'fileutils'

$template_directory = "./template/"

def escape_spaces(input_string)
  # Use gsub to replace all spaces with '\ '
  escaped_string = input_string.gsub(' ', '\ ')
  return escaped_string
  #return input_string
end

def command?(command)
  system("which #{command} > /dev/null 2>&1")
end

def oneTikzToPng (tikz_filename)
  puts "oneTikzToPng: Called on #{tikz_filename}"

  # Compute some paths
  original_dir = File.basename(Dir.getwd) # Current directory of script
  tikz_dir = File.dirname(tikz_filename)

  basename = File.basename(tikz_filename, ".tikz")
  base_tikz_filename = basename + ".tikz" # Strip leading directory
  png_filename = basename + ".png"
  tex_filename = basename + ".tex"

  # Interpolate variables into template.tex
  template_fd = File.open("#{$template_directory}/template.tex", "r")
  template = ERB.new(template_fd.read()).result(binding)
  template_fd.close()

  # Open a temporary directory and copy all our files there
  Dir.mktmpdir {|dir|
    puts "Copying template/ directory into temporary directory #{dir}"
    FileUtils.cp_r("template/.", "#{dir}")
    # The "/." is documented in the FileUtils
    # It copies all the files instead of creating "template/" under #{dir}

    puts "Copying `#{tikz_filename}` into temporary directory #{dir}"
    FileUtils.cp("#{tikz_filename}", "#{dir}")

    # By default this call appends random numbers to the .tex extension
    # Unfortunately pdflatex cannot tolerate this!
    # Pass a 2-argument array to Tempfile.new() to avoid this
    #target = Tempfile.new(['target', '.tex'], '.')

    # Create interpolated file
    target = File.open("#{dir}/#{tex_filename}", "w")
    target.write(template)
    target.close()

    puts "Creating .tex file in temporary directory: #{target.path()}"
    puts "Output file will be #{png_filename}"

    build_command = "pdflatex -output-directory=#{dir} -interaction=nonstopmode -shell-escape #{escape_spaces(target.path())} > /dev/null"

    Dir.chdir("#{dir}") do
      puts "Inside temporary directory #{dir}"
      puts "Running command: " + build_command
      begin
        Kernel.system(build_command)
      rescue Errno::ENOENT => e
        puts "Caught ENOENT exception: #{e.message}"
      rescue => e
        puts "Caught unknown exception: #{e.message}"
      end
    end

    puts "Copying #{dir}/#{png_filename} to _out/"
    outdir = "_out/#{tikz_dir}/"
    FileUtils.mkdir_p(outdir)
    FileUtils.cp("#{dir}/#{png_filename}", "#{outdir}")
    puts "**************************************************************************"
  }
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
