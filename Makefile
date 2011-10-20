MYLIBS=
COMPILER=ghc
GHCPRE=$(COMPILER) --make -O3 -i$(MYLIBS) -threaded

lifespan: Lifespan.hs
	$(GHCPRE) -o lifespan Lifespan.hs

clean:
	rm -rf lifespan *.hi *.o

all: lifespan
	exit

test: lifespan
	./lifespan 1 nmap localhost

install: lifespan
	install -Sc lifespan /usr/local/bin
