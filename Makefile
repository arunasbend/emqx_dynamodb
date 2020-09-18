REBAR = rebar3

compile:
	$(REBAR) compile

clean:
	@rm -rf _build
	@rm -f data/app.*.config data/vm.*.args rebar.lock
