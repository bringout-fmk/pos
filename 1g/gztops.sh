#!bash

cd /H/SIGMA
echo "Kopiram TOPS.EXE u T.EXE ..."
cp TOPS.EXE T.EXE
echo "Iskopirao"
echo "Pokrecem gzip ..."
gzip -f TOPS.EXE
echo "Napravio TOPS.EXE.gz "
mv T.EXE TOPS.EXE
echo "Vracam T.EXE u TOPS.EXE ..."
echo "Kopiram TOPS.EXE.gz u download lokaciju..."
cp TOPS.EXE.gz /H/vsasa/downloads
echo "Iskopirano. Bye."



