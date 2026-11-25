.PHONY: all clean run

all:
	cabal build

run:
	cabal run --ghc-options="-O2 -threaded -rtsopts" nbody_barnes_hut -- bodies.csv 2 256 +RTS -N

clean:
	cabal clean
