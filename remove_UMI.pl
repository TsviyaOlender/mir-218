#!usr/bin/perl
my($sample) = @ARGV;

$bamF = "Star_run/"."$sample"."Aligned.sortedByCoord.out.bam";
$samF1 = "$sample"."_t1.sam";
$samF2 = "$sample"."_t2.sam";
$finalBam = "align_noUMI7/".$sample."_f.bam";
$flagstatF = "align_noUMI7/".$sample.".flagstat";
system("samtools view -h $bamF > $samF1");

system("rm $samF2"); # file is first removed, because the script uses append
# first the header
system("samtools view -H $bamF > $samF2");

open(IN,"$samF1")|| warn "no infile $samF1\n";
open(OUT,">>$samF2")|| warn "can not append to $samF2\n";
while (<IN>) {
    chomp;
    @a=split('\t');
    ($umi)=$a[0] =~ /UMI:([AGCT]+)/;
    if($umi =~/[AGCT]/){
     $key = $umi."_".$a[2]."_".$a[3];
    unless (exists $h{$key}){
            print OUT "$_\n";
            $h{$key}=1;
    }
   }
}

close(IN);
close(OUT);

# sam to bam
system("samtools sort -O BAM -o $finalBam $samF2");
system("samtools index $finalBam");
# clean
#system("rm $samF1");
#system("rm $samF2");

# cheked number of reads after umi collapsed
system("samtools flagstat $finalBam > $flagstatF");
