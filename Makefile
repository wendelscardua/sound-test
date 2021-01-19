PROJECT=sound-test
LD65_FLAGS=
CA65_FLAGS=
NSF2DATA=/mnt/c/NESDev/famitone2d/NSF/nsf2data.exe
TEXT2DATA=/mnt/c/NESDev/famitone2d/text2data.exe
FAMITRACKER=/mnt/c/NESDev/famitracker/FamiTracker.exe
EMULATOR=/mnt/c/NESDev/Mesen.exe

TARGET=${PROJECT}.nes

.PHONY : debug run

default: ${TARGET}

${TARGET}: src/main.o src/reset.o src/ggsound.o src/readjoy.o src/rand.o src/unrle.o src/vram-buffer.o src/audio-data.o
	ld65 $^ -t nes -o ${TARGET} ${LD65_FLAGS}

debug: LD65_FLAGS += --dbgfile ${PROJECT}.nes.dbg
debug: CA65_FLAGS += -g -DDEBUG=1
debug: ${TARGET}

src/main.o: src/main.s src/constants.inc src/header.inc \
	src/ggsound.inc \
	src/vram-buffer.inc \
	src/charmap.inc \
	assets/bg-palettes.pal assets/sprite-palettes.pal \
        assets/metasprites.inc \
	assets/nametables/*.rle \
	assets/chr/*.chr
	ca65 src/main.s ${CA65_FLAGS}

src/audio-data.o: src/audio-data.s assets/audio/sfx.s assets/audio/soundtrack.s
	ca65 src/audio-data.s ${CA65_FLAGS}

assets/audio/soundtrack.s: assets/audio/soundtrack.txt
	python ft_txt_to_asm.py assets/audio/soundtrack.txt

assets/audio/soundtrack.txt: assets/audio/soundtrack.ftm
	${FAMITRACKER} $^ -export $@

assets/audio/sfx.nsf: assets/audio/sfx.ftm
	${FAMITRACKER} assets/audio/sfx.ftm -export assets/audio/sfx.nsf

assets/audio/sfx.s: assets/audio/sfx.nsf
	${NSF2DATA} assets/audio/sfx.nsf -ca65 -ntsc

%.o: %.s
	ca65 $< ${CA65_FLAGS}

clean:
	rm src/*.o *.nes *.dbg assets/audio/soundtrack.s assets/audio/soundtrack.txt \
	   assets/audio/sfx.s assets/audio/sfx.nsf -f

run: debug
	${EMULATOR} ${PROJECT}.nes
