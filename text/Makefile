all: cattle.pdf cattle_slides30.pdf
		
cattle.pdf: cattle.tex
	pdflatex cattle > /dev/null
	pdflatex cattle > /dev/null
	rm cattle.aux cattle.log

cattle_slides30.pdf: cattle_slides30.txt preamble.tex
	python /usr/local/bin/wiki2pdf.py cattle_slides30.txt > /dev/null
