#!/usr/bin/env bash
# usage: nanosim.sh in.fa out.fa [nanosim options]
# -c ../mbovis/mbovis-nanosim-profile/mbovis 
set -x;
in=$1; shift;
out=$1; shift;

seqkit split -i $in
echo -n "" > $out

for fa in `ls emales.fna.split/*.fna`; do
    max=$(seq-len $fa | cut -f2)
    python3 ~/software/NanoSim-2.6.0/src/simulator.py genome \
      -rg $fa --seed 1337 -b guppy-flipflop -dna_type linear \
      -n 100 -max $max -min $(($max-300)) -s 1 -o $(basename $fa .fna)-sim \
      -med $(($max-150)) -sd 1 $@ # pass additional args (error profile)
    # fix header
    perl -F_ -ane 'if(/^>/ && $F[5]<100 && $F[7]<100){print; print scalar(<>); exit;}' $(basename $fa .fna)-sim_aligned_reads.fasta |
    sed 's/_.*//;s/-/_/g;' | sed 's/E4_10/E4-10/g'  >> $out
done;
