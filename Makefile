.PHONY: all compile deps clean test rel clean-deps

REBAR_CONFIG = rebar.config

APP_NAME = ertpsv

all: clean deps test

clean-deps: clean deps

deps: get-deps update-deps
	@rebar -C $(REBAR_CONFIG) compile

update-deps:
	@rebar -C $(REBAR_CONFIG) update-deps

get-deps:
	@rebar -C $(REBAR_CONFIG) get-deps
compile:
	@rebar -C $(REBAR_CONFIG) compile skip_deps=true
	@rebar -C $(REBAR_CONFIG) xref skip_deps=true

rel: compile
	mkdir -p rel
	(cd rel && rebar generate)

backup-rel:
	rm -rf old_rel
	mv rel old_rel

new-rel:
	(rm -rf rel && mkdir -p rel)
	(cd rel && rebar -C $(REBAR_CONFIG) create-node nodeid=eudpsv)
	(sed -i -e "s/lib_dirs, \[\]/lib_dirs, \[\"..\/deps\"\]/g" rel/reltool.config)
	(sed -i -e "s/include}/include},{lib_dir, \"..\"}/" rel/reltool.config)
	(sed -i -e "3i \% start lager application " rel/files/vm.args)
	(sed -i -e "4i -s lager" rel/files/vm.args)
	(cd rel && rebar generate)

test:
	rm -rf .eunit
	@rebar -C $(REBAR_CONFIG) eunit skip_deps=true

clean:
	@rebar -C $(REBAR_CONFIG) clean skip_deps=true

distclean: clean
	@rebar -C $(REBAR_CONFIG) clean
	@rebar -C $(REBAR_CONFIG) delete-deps
	rm -rf dev

dialyze-init:
	dialyzer --build_plt --apps erts kernel stdlib mnesia crypto public_key snmp reltool
	dialyzer --add_to_plt --plt ~/.dialyzer_plt --output_plt $(APP_NAME).plt -c .
	dialyzer -c ebin -Wunmatched_returns -Werror_handling -Wrace_conditions -Wunderspecs

dialyze: compile
	dialyzer --check_plt --plt $(APP_NAME).plt -c .
	dialyzer -c ebin
