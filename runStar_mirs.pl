#!
##############################
use Config::Simple;
use File::Path qw(make_path remove_tree);
##############################################################
#load_modules();
$genomeDir = "/shareDB/star/human_hg38";
$gftFile = "Gtfs/genecode.V25.mirBase.clean.gtf";
$adaptor = "AACTGTAGGCACCATCAAT";
$fastqD = "fastq";
($inName) = @ARGV;

$inFastq = "$fastqD/$inName".".fastq";
$UMI_Fastq = "$fastqD/$inName".".UMI.fastq";
read_umi($inFastq,$UMI_Fastq);

# cutadapt
$UMI_Fastq .=".gz";
$trimmed_reads = "$fastqD/$inName"."_trimmed.fastq.gz";
$log_cutadapt = $inName."_cutadapr.log";
$cmd="cutadapt -q 25 -a $adaptor --minimum-length 18 -e 0.25 -o $trimmed_reads $UMI_Fastq >& $log_cutadapt\n";

system("$cmd");

#STAR
$outName = 'Star_run/'."$inName";
$params.=" --runThreadN 8 ";
$params.="--sjdbGTFfile $gftFile ";
$params.="--readFilesCommand zcat ";
$params.="--alignEndsType EndToEnd ";
$params.="--outFilterMismatchNmax 7 ";
$params.="--outFilterMultimapScoreRange 0 ";
$params.="--quantMode TranscriptomeSAM GeneCounts ";
$params.="--outReadsUnmapped Fastx ";
$params.="--outSAMtype BAM SortedByCoordinate ";
$params.="--outFilterMultimapNmax 10 ";
$params.="--outSAMunmapped Within ";
$params.="--outFilterScoreMinOverLread 0 ";
$params.="--outFilterMatchNminOverLread 0 ";
$params.="--outFilterMatchNmin 16 ";
$params.="--alignSJDBoverhangMin 1000 ";
$params.="--alignIntronMax 1 ";
$params.="--outWigType wiggle ";
$params.="--outWigStrand Stranded ";
$params.="--outWigNorm RPM ";
$params .= "--outFileNamePrefix Star_run/$inName";



$cmd = "STAR --genomeDir $genomeDir --readFilesIn $trimmed_reads $params";
print "$cmd\n";
system("$cmd");

$alignedF = "Star_run/$inName"."Aligned.sortedByCoord.out.bam";
system("samtools index $alignedF");

sub read_umi{
# read in fastq file, move the umi to the header
# gzip both files
	
	my($infile,$outfile) = @_;
	
	# unzip fastq for reading
	my($infile_gz) = $infile.".gz";
	system("gunzip $infile_gz");
	open(IN,"$infile")||warn "no fastq file\n";
	open(OUT,">$outfile")|| warn "can not write to $outfile\n";
	$i=0;
	while($line = <IN>){
	  $i++;
	  if($i%4 == 1){
		 chomp($line);
		 (@data) = split(/ /,$line);

		 $line = <IN>;
		 $UMI='';
		($check,$UMI) = $line =~/($adaptor)([AGCTN]{12})/;
		$i++;
		print OUT "$data[0]:UMI:$UMI $data[1]\n$line";
	  }elsif(($i%4 == 3) or ($i%4==0)){
		print OUT "$line";
	  }

	}
	close(IN);
	close(OUT);
	
	# gz files
	system("gzip $infile");
	system("gzip $outfile");
	return();
}
####################################################################################
sub load_modules{
  do ('/apps/RH7U2/Modules/default/init/perl.pm');

  module('load star');
  module('load python/2.7');

   return();
}
