##############################################################################
#
# (c) Alexey Naidyonov 2014
# License CC-BY 3.0
#

TOP := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

CWD := $(shell pwd)

CACHE_PATH = $(TOP)/.latex-cache
MEDIA_PATH = $(TOP)/media

ifdef NOTIFY
  ifeq ($(shell which terminal-notifier),)
    notify       = osascript -e 'display notification "Slide $(@F) processed" with title "Slides processor"';
    notify_error = osascript -e 'display notification "Error processing slide $(@F)" with title "Slides processor"';
  else
    notify       = terminal-notifier -message "Slide $(@F) processed" -title "Slides processor" -open "file://$(TOP)/$(@F)";
    notify_error = terminal-notifier -message "Error processing slide $(@F)";
  endif
endif

relpath   = $(if $(subst $(CWD),,$(TOP)),$1,$(subst $(TOP)/,,$1))

THEME_FILES = itoolabs-beamer.cls itoolabs-graphics.sty itoolabs-graphics.lua
$(foreach f,$(THEME_FILES),$(if $(shell kpsewhich $f),,$(error $f TeX file is required, see git.itoolabs.com/tex)))
THEME_SOURCES = $(foreach f,$(THEME_FILES),$(shell kpsewhich $f))

all: talk.pdf

.PHONY: all watch $(CACHE_PATH)

$(CACHE_PATH):
	@mkdir -p $(CACHE_PATH)

%.pdf: %.tex $(THEME_SOURCES) $(CACHE_PATH)
	@printf "Producing %s (see %s)..." "$(@F)" "$(call relpath,$(CACHE_PATH)/$(notdir $(<:.tex=))-build.log)" ; \
	 printf "pass 1..." ; \
	 export TEXINPUTS=$(TOP)/:$(CACHE_PATH)/:$(MEDIA_PATH)//:$${TEXINPUTS} ; \
	 lualatex --shell-escape --halt-on-error --output-format=pdf \
		  --output-directory=$(CACHE_PATH) "\\def\\outputdir{$(CACHE_PATH)}\\input{$<}" \
		  > $(CACHE_PATH)/$(notdir $(<:.tex=))-build.log </dev/null ; \
	 if [[ $$? != 0 ]]; then \
	 	printf "error!\n"; tail -n 25 $(CACHE_PATH)/$(notdir $(<:.tex=))-build.log ; \
		$(call notify_error) exit -1; \
	 fi ;\
	 printf "pass 2..." ;\
	 lualatex --shell-escape --halt-on-error --output-format=pdf \
		  --output-directory=$(CACHE_PATH) "\\def\\outputdir{$(CACHE_PATH)}\\input{$<}" \
		  > $(CACHE_PATH)/$(notdir $(<:.tex=))-build.log </dev/null ; \
	 if [[ $$? != 0 ]]; then \
		printf "error!\n"; tail -n 25 $(CACHE_PATH)/$(notdir $(<:.tex=))-build.log ; \
		$(call notify_error) exit - 1; \
	 else \
		$(call notify) printf "done\n" ; \
		cp $(CACHE_PATH)/$(@F) $@ ; \
		if [ -n "$(OPENRESULT)" ]; then open -g -a Preview $@ ; fi ;\
	 fi

watch: $(filter-out watch,$(MAKECMDGOALS))
	@echo "Watching for changes. Keep writing!"
	@fswatch -r $(THEME_SOURCES) $(wildcard $(TOP)/*.tex) | (while read f; do \
		if [ -n "$(OPENRESULT)" ]; then do_open="OPENRESULT=1"; fi; \
		$(MAKE) NOTIFY=1 $$do_open $^; \
	 done )
