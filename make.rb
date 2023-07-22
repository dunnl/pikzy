def command?(command)
  system("which #{command} > /dev/null 2>&1")
end

# Notice "\\usepackage" to avoid "\u"
def oneTikzToPng (source)
  document = <<-EOF
    \\documentclass[convert]{standalone}
    \\usepackage{tikzit}
    \\input{tealeaves.tikzstyles}
    \\begin{document}
    \\input{#{source}}
    \\end{document}
  EOF
  fdout = File.open("./tmp.tex", "w")
  fdout.write(document)
  fdout.close
  dir = File.dirname(source)
  out = File.basename(source)
  command = "pdflatex ./tmp.tex -output-directory #{}"
  Kernel.spawn(command)
  Kernel.spawn("mv standalone.png #{source}.png")
end

oneTikzToPng ("demo.tikz")

