let latexSource = tikz-src:
    ''
    \documentclass[convert]{standalone}
    \usepackage{tikzit}
    \input{tealeaves.tikzstyles}
    \begin{document}
    \input{${tikz-src}}
    \end{document}
    ''
in;
(import <nixpkgs> {}).runCommand "tikz-builder" {} ''
  pdflatex ${latexSource}
''
