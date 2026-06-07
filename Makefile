# Kick Assembler is a Java jar. Point KICKASS_JAR at KickAss.jar, or override
# the whole invocation with KICKASS=... (e.g. a wrapper script on PATH).
KICKASS_JAR ?= KickAss.jar
KICKASS     ?= java -jar $(KICKASS_JAR)
BUILD       := build

.PHONY: all prg sid fetch verify test clean

all: verify

$(BUILD):
	mkdir -p $(BUILD)

prg: | $(BUILD)
	$(KICKASS) src/lastninja.asm -o $(BUILD)/lastninja.prg

fetch: | $(BUILD)
	python3 tools/fetch_sid.py $(BUILD)/Last_Ninja.sid

sid: prg
	python3 tools/build_sid.py $(BUILD)/lastninja.prg $(BUILD)/lastninja.sid

verify: sid fetch
	python3 tools/verify.py $(BUILD)/lastninja.sid $(BUILD)/Last_Ninja.sid

test:
	python3 -m pytest -v

clean:
	rm -rf $(BUILD)
