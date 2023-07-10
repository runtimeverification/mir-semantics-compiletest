 
.PHONY: clean clean-mir default ui-mir

default: ui-mir

clean: clean-mir

RUSTC:=rustc
RUSTC_OPTIONS=-C overflow-checks=off

UI_RS=$(shell find ui -name '*.rs')
UI_MIR=$(patsubst %.rs,%.mir,${UI_RS})

# Remove MIR files
clean-mir:
	find . -name "*.mir" -type f -delete

ui-mir: ${UI_MIR}

# Default MIR generation
ui/%.mir: ui/%.rs
	$(RUSTC) --emit mir $(RUSTC_OPTIONS) -o $@ ui/$*.rs

#####################################
# Execution outputs


UI_EXE=$(patsubst %.rs,%.exe,${UI_RS})
ui-exe: ${UI_EXE}

# Default compilation
ui/%.exe: ui/%.rs
	$(RUSTC) -o $(RUSTC_OPTIONS) $@ ui/$*.rs
