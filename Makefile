all: pdf
pdf: resume.pdf
resume.pdf: _resume/resume.tex
	cd _resume; xelatex -output-directory=../out resume.tex; cp ../out/resume.pdf ../
clean:
	rm -f resume.pdf