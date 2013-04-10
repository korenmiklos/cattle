all: cattle.pdf cattle_slides30.txt.pdf cattle_slides60.txt.pdf
		
cattle.pdf: cattle.tex
	pdflatex cattle > /dev/null
	pdflatex cattle > /dev/null
	rm cattle.aux cattle.log

cattle_slides30.txt.pdf: cattle_slides30.txt preamble.tex
	wiki2pdf cattle_slides30.txt > /dev/null

cattle_slides60.txt.pdf: cattle_slides60.txt preamble.tex
	wiki2pdf cattle_slides60.txt > /dev/null
