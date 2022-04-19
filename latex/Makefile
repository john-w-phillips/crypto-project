targets = proposal.pdf project-report.pdf

all: $(targets)

clean:
	rm -rf *.log *.aux *.pdf *~
%.pdf: %.tex
	pdflatex $<
