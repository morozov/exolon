Exolon.scl: Exolon.trd
	trd2scl Exolon.trd Exolon.scl

# The compressed screen is created by Laser Compact v5.2
# and cannot be generated at the build time
# see https://spectrumcomputing.co.uk/?cat=96&id=21446
Exolon.trd: boot.$$B hob/screenz.$$C exolon.$$C
# Create a temporary file first in order to make sure the target file
# gets created only after the entire job has succeeded
	$(eval TMPFILE=$(shell mktemp))

	createtrd $(TMPFILE)
	hobeta2trd boot.\$$B $(TMPFILE)
	hobeta2trd hob/screenz.\$$C $(TMPFILE)
	hobeta2trd exolon.\$$C $(TMPFILE)

# Write the correct length to the first file (offset 13)
# The length is 1 (boot) + 20 (loading screen) + 147 (data) = 168
# Got to use the the octal notation since it's the only format of binary data POSIX printf understands
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/printf.html#tag_20_94_13
	printf '\250' | dd of=$(TMPFILE) bs=1 seek=13 conv=notrunc status=none

# Remove two other files (fill 2×16 bytes starting offset 16 with zeroes)
	dd if=/dev/zero of=$(TMPFILE) bs=1 seek=16 count=32 conv=notrunc status=none

# Rename the temporary file to target name
	mv $(TMPFILE) Exolon.trd

Exolon.tap.zip:
	wget http://www.worldofspectrum.org/pub/sinclair/games/e/Exolon.tap.zip

EXOLON.TAP: Exolon.tap.zip
	unzip -u Exolon.tap.zip && touch EXOLON.TAP

exolon.000: EXOLON.TAP
	tapto0 -f EXOLON.TAP

# The files here have a non-standard header 2A at offset 2 that 0tohob doesn't like
# The standard header is 03
	printf '\03' | dd of=exolon.000 bs=1 seek=2 conv=notrunc status=none

exolon.$$C: exolon.000
	0tohob exolon.000

boot.bin: src/boot.asm
	pasmo --bin src/boot.asm boot.bin

boot.bas: src/boot.bas boot.bin
# Replace the __LOADER__ placeholder with the machine codes with bytes represented as {XX}
	sed "s/__LOADER__/$(shell hexdump -ve '1/1 "{%02x}"' boot.bin)/" src/boot.bas > boot.bas

boot.tap: boot.bas
	bas2tap -sboot -a10 boot.bas boot.tap

boot.000: boot.tap
	tapto0 -f boot.tap

boot.$$B: boot.000
	0tohob boot.000

clean:
	rm -f \
		*.000 \
		*.\$$B \
		*.\$$C \
		*.bas \
		*.bin \
		*.TAP \
		*.tap \
		*.trd \
		*.zip