REBAR = rebar
DIALYZER = dialyzer
APP = show_curency

DIALYZER_WARNINGS = -Wunmatched_returns -Werror_handling \
                    -Wrace_conditions -Wunderspecs

.PHONY: all compile test qc clean get-deps build-plt dialyze

ERLC_COMPILE_OPTS = +'{parse_transform, lager_transform}' +'{lager_truncation_size, 1024}'

ERLC_OPTS ?= -W1
ERLC_OPTS += $(ERLC_COMPILE_OPTS)

SHELL_OPTS = $(CURDIR)/ebin $(DEPS_DIR)/*/ebin -eval 'application:ensure_all_started($(PROJECT))' -config sys.config

TEST_ERLC_OPTS = $(ERLC_COMPILE_OPTS)
CT_OPTS = -erl_args -config sys.config

all: deps

deps:
	@$(REBAR) get-deps
	@$(REBAR) compile

compile:
	@$(REBAR) compile

run:
	@$(REBAR) compile
	erl -pa ./ebin -pa ./deps/*/ebin -eval 'application:ensure_all_started($(APP)).'

test: compile
	@$(REBAR) ct skip_deps=true

clean:
	@$(REBAR) clean

get-deps:
	@$(REBAR) get-deps

.dialyzer_plt:
	@$(DIALYZER) --build_plt --output_plt .dialyzer_plt \
	    --apps kernel stdlib

build-plt: .dialyzer_plt

dialyze: build-plt
	@$(DIALYZER) --src src --plt .dialyzer_plt $(DIALYZER_WARNINGS)
