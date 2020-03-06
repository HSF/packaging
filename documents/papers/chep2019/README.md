# Modern Software Stack Building for HEP
## CHEP 2019 Paper

### whoami

This is the LaTeX for the CHEP2019 proceedings paper, see
<https://indico.cern.ch/event/773049/contributions/3473203/>
for the conference slides.

### LaTeX

The paper uses the EPJ class file (`webofc.cls`) and the correct
BibTeX style (`woc.bst`).

Note that the class file is incompatible with biber, but the results
from natbib are good enough.

### Compiling

The LaTeX is pretty standard stuff (it will compile auto-magically)
in VS Code. If you want to build it by hand it's just:

```
pdflatex modern-stack
bibtex modern-stack
pdflatex modern-stack
```

(Evidently watch out for `Rerun to get citations correct` messages and
rerun pdflatex as needed.)