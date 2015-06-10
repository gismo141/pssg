REPO := $(shell git config --get remote.origin.url)
GHPAGES = gh-pages

LESSC    = node_modules/less/bin/lessc
LESSFILE = less/main.less

CSSDIR  = $(GHPAGES)/css
CSSFILE = $(CSSDIR)/main.css

all: init clean $(GHPAGES) $(CSSFILE) $(addprefix $(GHPAGES)/, $(addsuffix .html, $(basename $(wildcard *.md))))

$(GHPAGES)/%.html: %.md
    pandoc -s --template "_layout" -c "css/main.css" -f markdown -t html5 -o "$@" "$<"

$(CSSFILE): $(CSSDIR) $(LESSFILE)
    $(LESSC) "$(LESSFILE)" "$(CSSFILE)"

$(CSSDIR):
    mkdir -p "$(CSSDIR)"

$(GHPAGES):
    @echo $(REPO)
    git clone "$(REPO)" "$(GHPAGES)"
    @echo "Donezo"
    (cd $(GHPAGES) && git checkout $(GHPAGES)) || (cd $(GHPAGES) && git checkout --orphan $(GHPAGES) && git rm -rf .)

init:
    @command -v pandoc > /dev/null 2>&1 || (echo 'pandoc not found http://johnmacfarlane.net/pandoc/installing.html' && exit 1)
    @[ -x $(LESSC) ] || npm install

serve:
    cd $(GHPAGES) && python -m SimpleHTTPServer

clean:
    rm -rf $(GHPAGES)

commit:
    cd $(GHPAGES) && \
        git add . && \
        git commit --edit --message="Publish @$$(date)"
    cd $(GHPAGES) && \
        git push origin $(GHPAGES)

.PHONY: init clean commit serve