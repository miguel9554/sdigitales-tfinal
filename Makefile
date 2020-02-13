BASE_REL_DIR = ../../
VER_DIR      = ./verification/

# Waves output format (vcd,fst)
WOF = fst
WAVES_NAME = waves.$(WOF)
WLIB_NAME  = work-obj93.cf

RUN_FLAGS = --disp-time
RUN_FLAGS =

DATA_FILES = $(wildcard $(VER_DIR)*/*.dat)

SRC_DIRS  = $(wildcard ./src/*)
SRC_FILES = $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.vhdl))

GHDL_OPTIONS = --std=02 --ieee=synopsys
GTKWAVE_OPTIONS = --optimize

SRC_REL_FILES = $(addprefix $(BASE_REL_DIR),$(SRC_FILES))

TBS       = $(notdir $(wildcard $(VER_DIR)*))
TBS_WAVES = $(addsuffix /$(WAVES_NAME),$(addprefix $(VER_DIR),$(TBS)))
TBS_EXE   = $(addprefix $(VER_DIR),$(join $(addsuffix /,$(TBS)),$(TBS)))
TBS_WLIBS = $(addsuffix /$(WLIB_NAME),$(addprefix $(VER_DIR),$(TBS)))

.PHONY: all
all:
	@echo "Must provide one of the following TestBenches:"
	@$(foreach tb,$(TBS),echo "  "$(tb);)
	@echo


# Genera la work library
$(TBS_WLIBS):
	@echo "Generating WORK Library for $@"
	@cd $(dir $@) && \
	 	ghdl -i $(GHDL_OPTIONS) *.vhdl $(SRC_REL_FILES)


$(DATA_FILES): $(VER_DIR)tb_%/stimulus.dat : utils/stimulus_generation/%.py
	@echo "Generating data file for $@"
	python $<

# Esta regla nos dice que los ejecutables dependen del vhdl que está en la carpeta del TB (verification/TB),
# de WLIB (la librería work, está en la carpeta del testbench) y de todos los archivos fuente
.SECONDEXPANSION:
$(TBS_EXE) : % : %.vhdl $$(dir $$@)$(WLIB_NAME) $(SRC_FILES)
	@cd $(dir $@) && \
		ghdl -m $(GHDL_OPTIONS) $(notdir $@)


# Esta regla nos dicen que los waves dependen del ejecutable verification/TESTBENCH/TESTBENCH y de los data files
# Después, llama al ejecutable pasando como parámetros el nombre de salida del waveform y los run flags
.SECONDEXPANSION:
$(TBS_WAVES): $(VER_DIR)%/waves.$(WOF) : $$(subst waves.$$(WOF),,$$@)% $(DATA_FILES)
	$< --$(WOF)=$@ $(RUN_FLAGS)
	@echo "File $< Updated! (Reload Waveform)"


# Esta regla nos dice que los testbench dependen de verification/TESTBENCH/wave.WOF
$(TBS): % : $(VER_DIR)%/waves.$(WOF)
	@echo "Done $@!"


$(TBS:%=gtkwave_%): gtkwave_% : $(VER_DIR)%/waves.$(WOF)
	gtkwave $< $(GTKWAVE_OPTIONS) &


.PHONY: clean
clean:
	$(foreach tb,$(VER)$(TBS),rm -f $(VER_DIR)$(tb)/*.o;)
	rm -f $(TBS_EXE)
	rm -f $(TBS_WAVES)
	rm -f $(TBS_WLIBS)
	@clear
	@echo "Clean!"







# Other "USEFUL" things
.PHONY: list_targets
list_targets:
	@echo "TESTS:"
	@$(foreach tb,$(TBS),echo "  "$(tb);)
	@echo "EXE"
	@$(foreach tb,$(TBS_EXE),echo "  "$(tb);)
	@echo "WAVES"
	@$(foreach tb,$(TBS_WAVES),echo "  "$(tb);)
	@echo "WLIBS"
	@$(foreach tb,$(TBS_WLIBS),echo "  "$(tb);)
	@echo


.PHONY: list_src_files
list_src_files:
	@echo "SRC FILES"
	@$(foreach tb,$(SRC_FILES),echo "  "$(tb);)
	@echo


.PHONY: list_tests
list_tests:
	@echo "SRC FILES"
	@$(foreach tb,$(TBS),echo "  "$(tb);)
	@echo

