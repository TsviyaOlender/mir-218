#!
#use warnings;

$region = "chr5:168768146-168768238";
$strand = "-";
my($sampleF) = @ARGV;
open(IN,"$sampleF");
@samples = <IN>;
chomp(@samples);
close(IN);

$outFILE_noUMI="mirs_count_noUMIcollapse_181a-2.txt";
$outFILE_withUMI="mirs_count_withUMIcollapse_181a-2.txt";

# without UMI collapse
$INdir = "Star_run";
$OUTdir = "temp_noUMIredund";
$suffix = "Aligned.sortedByCoord.out.bam";
extract_region($INdir,$OUTdir,$suffix);
(%mirSeq)=generate_counts($OUTdir,$outFILE_noUMI);
# print data to outfile
print_results($outFILE_noUMI);

# with UMI collapse
$INdir = "align_noUMI7";
$OUTdir = "temp_UMI";
$suffix = "_f.bam";
extract_region($INdir,$OUTdir,$suffix);
(%mirSeq)=generate_counts($OUTdir,$outFILE_withUMI);
print_results($outFILE_withUMI);

############################################################################
sub print_results{
   #print
   my($outF) = @_;
  open(FILE,">",$outF)|| warn "cannot write to utfile $outF1\n";
  print FILE "\t";
  foreach $sample (@samples){
    print FILE "$sample\t";
    
  }
  print FILE "\n";
  
  foreach $isoMir (keys %mirSeq){
    print FILE "$isoMir\t";
    
    foreach $sample (@samples){
      if($mirSeq{$isoMir}{$sample} > 0){
        print FILE "$mirSeq{$isoMir}{$sample}\t";
      }else{
        print FILE "0\t";
      }
    }
    print FILE "\n";
    
  }
  close(FILE);
  return();
}
############################################################################
sub generate_counts{
  my($SAMdir,$outF1)=@_;
  my(%mirSeq)=();
  foreach $sample (@samples){
    $samFile = "$SAMdir/$sample".".sam";
    open(IN,"$samFile") || warn "can not find infile $samFile\n";
    while($line=$line = <IN>){
      chomp($line);
      (@data) = split(/\t/,$line);
       $mirSeq{$data[9]}{$sample}++;
       
    }
    close(IN);
  }
  return(%mirSeq);
 
}
############################################################################
sub extract_region{
  my($INdir,$OUTdir,$suffix)=@_;
  foreach $sample (@samples){
    $bamF = "$INdir/$sample".$suffix;
    $samO = "$OUTdir/$sample".".sam";
    $cmd = "samtools view $bamF $region > $samO";
    system("$cmd");
  }
  return();
}  
