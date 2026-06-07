ACME ?= acme
BUILD := build

.PHONY: all sid bin fetch verify test clean

all: verify

$(BUILD):
	mkdir -p $(BUILD)

bin: | $(BUILD)
	$(ACME) -f plain -o $(BUILD)/lastninja.bin src/lastninja.asm

fetch: | $(BUILD)
	python3 tools/fetch_sid.py $(BUILD)/Last_Ninja.sid

sid: bin
	python3 tools/build_sid.py $(BUILD)/lastninja.bin $(BUILD)/lastninja.sid

verify: sid fetch
	python3 tools/verify.py $(BUILD)/lastninja.sid $(BUILD)/Last_Ninja.sid

test:
	python3 -m pytest -v

clean:
	rm -rf $(BUILD)
