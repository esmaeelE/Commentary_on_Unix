# $Id: Makefile,v 1.4 2023/09/28 03:54:36 grog Exp $
# Makefile for Lions Book
# This file is an afterthought.  It effectively repeats in the correct
# format the instructions in the file Readme

TBL = /usr/bin/tbl
PIC = /usr/bin/pic
TROFF = groff -U
NROFF = nroff
CLEANUP=/usr/bin/gcleanup.sed
MACROFILE = ${TOOLS}/tmac.G
HTMACROFILE = ${TOOLS}/tmac.html
TOOLS = /home/Book/tools
GS	=	gs
FIGURES = slides.ps
PAPER = a4
# Set to -b for backtraces on error
# ROFFDEBUG=	-b

# Basic layout parameters
HEIGHT?=	10i
WIDTH?=		6i
EXAMPLE-SIZE?=	8
TEXTSIZE?=	10
LINESPACING?=	12

.SUFFIXES: .gif .ps .ppm .eps .pdf .tex .mm .G

SRC	=	${TEX}

TEX	=	ch1.tex ch10.tex ch11.tex ch12.tex ch13.tex ch14.tex ch15.tex \
		ch16.tex ch17.tex ch18.tex ch19.tex ch2.tex ch20.tex ch21.tex ch22.tex \
		ch23.tex ch24.tex ch25.tex ch26.tex ch3.tex ch4.tex ch5.tex ch6.tex \
		ch7.tex ch8.tex ch9.tex fig23_1.tex fig23_2.tex fig23_3.tex \
		fig23_4.tex lionc.tex preface.tex title.tex

AUX	=	Makefile

all:	lionc.pdf

pdf lionc.pdf: lionc.ps
	ps2pdf lionc.ps

lionc.ps: lionc.dvi
	dvips lionc.dvi -o lionc.ps

lionc.dvi: ${SRC}
	latex lionc.tex
	latex lionc.tex

clean:
	rm -f *.dvi *.ps *.pdf *.toc *.log *.aux

.G.ps .mm.ps:
	@echo +++ $@
	touch $*.xref
	-soelim $< | ${PIC} | ${TBL} | \
	    ${TROFF} ${ROFFDEBUG} -rex=${EXAMPLE-SIZE} -r$$$$ -rL${HEIGHT} -rW${WIDTH} -rPS=${TEXTSIZE} \
	    -rN=1 -rLS=${LINESPACING} -mpic ${MACROFILE} - >$@ 2>$*.toc 
	if [ $$? -ne 0 ]; then cat $*.toc; exit 1; fi
	grep '><PAGENO:' $*.toc | sed 's/><PAGENO://' > $*.xref
	-soelim $*.xref $< | ${PIC} | ${TBL} | \
	    ${TROFF} ${ROFFDEBUG} -rex=${EXAMPLE-SIZE} -r$$$$ -rL${HEIGHT} -rW${WIDTH} -rPS=${TEXTSIZE} \
	    -rN=1 -rLS=${LINESPACING} -mpic ${MACROFILE} - >$@ 2>$*.toc
	if [ $$? -ne 0 ]; then cat $*.toc; exit 1; fi
	@-grep -v "><" $*.toc || exit 0
	@-grep %%Pages $*.ps |awk '{print $$2 " pages"}'

book.tar.gz: ${TEX} ${AUX}
	tar cvf book.tar ${TEX} ${AUX}
	gzip -f book.tar
