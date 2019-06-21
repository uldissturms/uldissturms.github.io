all: pdf
pdf: uldis_sturms_resume.pdf
uldis_sturms_resume.pdf: _resume/resume.tex
	mkdir -p out; cd _resume; xelatex -output-directory=../out resume.tex; cp ../out/uldis_sturms_resume.pdf ../
clean:
	rm -f uldis_sturms_resume.pdf
