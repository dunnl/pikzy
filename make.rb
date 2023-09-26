require 'erb'
require 'tempfile'
require 'fileutils'

def command?(command)
  system("which #{command} > /dev/null 2>&1")
end

def oneTikzToPng (tikz_filename)

  template_fd = File.open("template.tex", "r")
  template = ERB.new(template_fd.read()).result(binding)
  template_fd.close()

  # Compute paths
  basename = File.basename(tikz_filename, ".tikz") # Truncate .tikz
  output_path = basename + ".png"

  Dir.mktmpdir {|dir|
    FileUtils.cp(tikz_filename, "#{dir}")
    FileUtils.cp("tealeaves.tikzstyles", "#{dir}")
    FileUtils.cp("tikzit.sty", "#{dir}")

  # By default this call appends random numbers to the .tex extension
  # Unfortunately pdflatex cannot tolerate this!
  # Pass a 2-argument array to Tempfile.new() to avoid this
  #target = Tempfile.new(['target', '.tex'], '.')
  target = File.open("#{dir}/#{basename}.tex", "w")
  target_file = target.path()
  target.write(template)
  target.close()

  puts "Converting .tikz file: #{tikz_filename}"
  puts "Temporary .tex file: #{target_file}"
  puts "Output file will be #{output_path}"
  #puts template.result(binding)


  Dir.chdir("#{dir}") do
    build_command = "pdflatex -output-directory=#{dir} -interaction=batchmode -shell-escape #{target_file}"
    #build_command = "pdflatex -output-directory=#{dir} -interaction=batchmode --shell-escape target.tex"
    puts "Running " + build_command
    Kernel.system(build_command)
    #sleep(120)
  end

  #sleep(120)
  FileUtils.cp("#{dir}/#{output_path}", ".")
  }
end

filename = ARGV.first
oneTikzToPng(filename)
