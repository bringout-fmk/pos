liball:
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
	make -C fissta/1g
	make -C evidpl/1g
	make -C integ/1g
	make -C 1g exe

cleanall:	
	make -C print/1g clean
	make -C db/1g clean
	make -C db/2g clean
	make -C dok/1g clean
	make -C kalk/1g clean
	make -C main/1g clean
	make -C main/2g clean
	make -C razdb/1g clean
	make -C razoff/1g clean
	make -C rpt/1g clean
	make -C server/1g clean
	make -C sif/1g clean
	make -C sirov/1g clean
	make -C smjene/1g clean
	make -C specif/planika/1g clean
	make -C specif/tigra/1g clean
	make -C specif/excl/1g clean
	make -C sql/1g clean
	make -C stela/1g clean
	make -C rabat/1g clean
	make -C fissta/1g clean
	make -C evidpl/1g clean
	make -C integ/1g clean
	make -C 1g clean

pos:	cleanall  liball

