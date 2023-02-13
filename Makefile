 
.PHONY: clean clean-mir ui-mir

clean: clean-mir

UI_RS=$(shell find ui -name '*.rs')
UI_MIR=$(patsubst %.rs,%.mir,${UI_RS})

echo:
	echo $(UI_RS)

# Remove MIR files
clean-mir:
	find . -name "*.mir" -type f -delete

ui-mir: ${UI_MIR}

# Default MIR generation
ui/%.mir: ui/%.rs
	rustc --emit mir -o $@ ui/$*.rs

# 'async-await' tests use 2021 ed. 
ui/async-await/%.mir: ui/async-await/%.rs 
	rustc --edition 2021 \
	      --emit mir \
		  -o $@ ui/async-await/$*.rs 

# 'try-block' tests use 2018 ed. 
ui/try-block/%.mir: ui/try-block/%.rs 
	rustc --edition 2018 \
	      --emit mir \
		  -o $@ ui/try-block/$*.rs 

# 'closures/2229_closure_analysis/run_pass' tests use 2021 ed. 
ui/closures/2229_closure_analysis/run_pass/%.mir: ui/closures/2229_closure_analysis/run_pass/%.rs 
	rustc --edition 2021 \
	      --emit mir \
		  -o $@ ui/closures/2229_closure_analysis/run_pass/$*.rs

# 'closures/2229_closure_analysis/optimization' tests use 2021 ed. 
ui/closures/2229_closure_analysis/optimization/%.mir: ui/closures/2229_closure_analysis/optimization/%.rs 
	rustc --edition 2021 \
	      --emit mir \
		  -o $@ ui/closures/2229_closure_analysis/optimization/$*.rs

# 'test-attrs' tests use the '--test' flag. 
ui/test-attrs/%.mir: ui/test-attrs/%.rs 
	rustc --test --emit mir -o $@ ui/test-attrs/$*.rs 

# 'try-block/try-is-identifier-edition2015.rs' use 2015 ed. 
ui/try-block/try-is-identifier-edition2015.mir: ui/try-block/try-is-identifier-edition2015.rs
	rustc --edition 2015 \
	      --emit mir \
		  -o ui/try-block/try-is-identifier-edition2015.mir \
		  ui/try-block/try-is-identifier-edition2015.rs

# 'numbers-arithmetic/promoted_overflow_opt.rs' use the '-O' flag. 
ui/numbers-arithmetic/promoted_overflow_opt.mir: ui/numbers-arithmetic/promoted_overflow_opt.rs
	rustc --emit mir \
	      -O \
		  -o ui/numbers-arithmetic/promoted_overflow_opt.mir \
		  ui/numbers-arithmetic/promoted_overflow_opt.rs

		  