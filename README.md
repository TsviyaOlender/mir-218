# mir-218
Counting miR-218-2-5p isotypes

1. runStar_mirs.pl is used for aligning the fastq data to the genome.
The script applies cutadapt to trim from adapters, and removal of low quality re
ads, followed by alignment using Star.
2. remove_UMI.pl is used for generating UMI collapsed alignment.
3. countIsoMirs_V2.pl- generates the isotypes counts
