all:
	rm -f main/1g/e.obj
	make -C db/1g
	make -C db/2g
	make -C main/1g
	make -C main/2g
	make -C print/1g
	make -C dok/1g
	make -C kalk/1g
	make -C razdb/1g
	make -C razoff/1g
	make -C rpt/1g
	make -C server/1g
	make -C sif/1g
	make -C sirov/1g
	make -C smjene/1g
	make -C specif/planika/1g
	make -C specif/tigra/1g
	make -C specif/excl/1g
	make -C sql/1g
	make -C stela/1g
	make -C rabat/1g
	make -C 1g

clean:	
	cd print/1g; make clean
	cd db/1g; make clean
	cd db/2g; make clean
	cd dok/1g; make clean
	cd kalk/1g; make clean
	cd main/1g; make clean
	cd main/2g; make clean
	cd 1g; make clean
	cd razdb/1g; make clean
	cd razoff/1g; make clean
	cd rpt/1g; make clean
	cd server/1g; make clean
	cd sif/1g; make clean
	cd sirov/1g; make clean
	cd smjene/1g; make clean
	cd specif/planika/1g; make clean
	cd specif/tigra/1g; make clean
	cd specif/excl/1g; make clean
	cd sql/1g; make clean
	cd stela/1g; make clean
	cd rabat/1g; make clean
	
