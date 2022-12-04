servedocs:
	mkdocs serve
viewdocs:
	firefox http://127.0.0.1:8000
diagrams:
	./postProcess.sh src/section1.md
	./postProcess.sh src/section2.md
	./postProcess.sh src/section3.md
	./postProcess.sh src/section4.md
	./postProcess.sh src/section5.md
builddocs: diagrams
	mkdocs build
deploy: builddocs
	mkdocs gh-deploy
# epub:
# 	mkdocs2pandoc > piquetBook.pd
# 	mkdocscombine -o piquetBook.pd
# 	pandoc --toc -f markdown+grid_tables -t epub -o piquetBook.epub piquetBook.pd
epub:
	sh makeEpub.sh
init:
	cat .env.nixenv | sed s/dbuser:/$$(whoami):/ > .env.local
dev: checknix
	nix develop
checknix:
	bash ./nixfiles/checknix.sh
