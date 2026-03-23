# NASA Presentation & Reference Book - Build System
# Requires: pandoc, marp-cli (npm install -g @marp-team/marp-cli)

.PHONY: all book slides html clean

all: book slides

# ==================== REFERENCE BOOK (PDF) ====================
RESEARCH_FILES = \
	research_testing_as_evidence.md \
	research_runtime_monitoring.md \
	research_deployment_safety.md \
	research_incident_analysis.md \
	research_org_independence.md \
	research_dependency_governance.md \
	research_threat_modeling.md \
	research_metrics.md \
	research_adoption_playbook.md

SLIDE_DECKS = \
	fret_slides.md \
	lustre.md \
	ffbd.md \
	general_ai.md

book: build/reference-book.pdf

build/reference-book.pdf: TABLE_OF_CONTENTS.md $(RESEARCH_FILES) $(SLIDE_DECKS)
	@mkdir -p build
	pandoc \
		--from=markdown \
		--to=pdf \
		--pdf-engine=xelatex \
		--toc \
		--toc-depth=3 \
		--number-sections \
		-V geometry:margin=1in \
		-V fontsize=11pt \
		-V documentclass=report \
		-V mainfont="Inter" \
		-V monofont="JetBrains Mono" \
		-V colorlinks=true \
		-V linkcolor=blue \
		-V urlcolor=blue \
		-V header-includes='\usepackage{fancyhdr}\pagestyle{fancy}\fancyhead[L]{NASA Engineering for Software}\fancyhead[R]{\leftmark}' \
		--metadata title="Applying NASA, Automotive & Safety-Critical Engineering to Software" \
		--metadata author="Leonid Bugaev" \
		--metadata date="$(shell date +%Y-%m-%d)" \
		TABLE_OF_CONTENTS.md $(RESEARCH_FILES) \
		-o $@
	@echo "✅ Reference book built: $@"

# Lightweight PDF via HTML→wkhtmltopdf (no LaTeX required)
book-simple: build/reference-book-simple.pdf

build/reference-book-simple.html: TABLE_OF_CONTENTS.md $(RESEARCH_FILES)
	@mkdir -p build
	pandoc \
		--from=markdown \
		--to=html5 \
		--standalone \
		--toc \
		--toc-depth=3 \
		--number-sections \
		--css=book-style.css \
		--self-contained \
		--metadata title="Applying NASA, Automotive & Safety-Critical Engineering to Software" \
		--metadata author="Leonid Bugaev" \
		--metadata date="$(shell date +%Y-%m-%d)" \
		TABLE_OF_CONTENTS.md $(RESEARCH_FILES) \
		-o $@
	@echo "✅ HTML book built: $@"

build/reference-book-simple.pdf: build/reference-book-simple.html
	wkhtmltopdf \
		--page-size A4 \
		--margin-top 20mm \
		--margin-bottom 20mm \
		--margin-left 25mm \
		--margin-right 20mm \
		--footer-center '[page]' \
		--footer-font-size 9 \
		--enable-local-file-access \
		build/reference-book-simple.html $@
	@echo "✅ Simple reference book PDF built: $@"

# HTML-only version (for web viewing)
book-html: build/reference-book-simple.html

# ==================== PRESENTATION SLIDES (HTML/PDF) ====================
slides: build/presentation.html

build/presentation.html: presentation.md images/*
	@mkdir -p build
	marp presentation.md --html --allow-local-files -o $@
	@echo "✅ Presentation slides built: $@"

slides-pdf: build/presentation.pdf

build/presentation.pdf: presentation.md images/*
	@mkdir -p build
	marp presentation.md --html --allow-local-files --pdf -o $@
	@echo "✅ Presentation PDF built: $@"

# ==================== INDIVIDUAL RESEARCH CHAPTERS ====================
chapters: $(patsubst %.md,build/%.pdf,$(RESEARCH_FILES))

build/%.pdf: %.md
	@mkdir -p build
	pandoc --from=markdown --to=pdf --toc -V geometry:margin=1in $< -o $@
	@echo "✅ Chapter built: $@"

# ==================== CLEAN ====================
clean:
	rm -rf build/
	@echo "🧹 Build artifacts cleaned"
