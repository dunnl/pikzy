def command?(command)
  system("which #{command} > /dev/null 2>&1")
end

# Notice "\\usepackage" to avoid "\u"
def oneTikzToPng (source)
  document = <<-EOF
    \\documentclass[convert={density=300,outext=.png}]{standalone}
    \\usepackage{dsfont}
    \\include{includes/macros}
    \\usepackage{tikzit}
    \\input{tealeaves.tikzstyles}
    \\begin{document}
    \\input{#{source}}
    \\end{document}
  EOF
  puts "Called on source #{source}"
  dir = File.dirname(source)[2...]
  puts "Directory is #{dir}"
  out = File.basename(source, ".tikz")
  puts "Output file is #{out}"

  tmp = "tmp_#{out}.tex"
  tmppng = "tmp_#{out}.png"
  outpngdir = "_out/#{dir}"
  outpng = "_out/#{dir}/#{out}.png"

  fdout = File.open("#{tmp}", "w")
  puts "Writing #{tmp}"
  fdout.write(document)
  puts "Closing file #{tmp}"
  fdout.close

  puts "DOING pdflatex --shell-escape #{tmp}; mkdir -p \"#{outpngdir}\"; mv #{tmppng} \"#{outpng}\""
  Kernel.system("pdflatex --interaction=batchmode --shell-escape #{tmp} > /dev/null")
  Kernel.system("mkdir -p \"#{outpngdir}\" && mv #{tmppng} \"#{outpng}\"")
end

filename = ARGV.first
oneTikzToPng(filename)
