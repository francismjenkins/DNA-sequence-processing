#!/usr/bin/perl 
use strict;
use warnings;
use List::Util qw(shuffle);
use File::Basename;

#Name of file - Jenkins_assign2.pl
#Name         - Frank Jenkins
#Date         - October 7, 2017




# command line input
my $filename = <STDIN>;
my ($name,$path,$suffix) = fileparse($filename,".txt");


# read FASTA file  - Subroutine call
my ($headerRef,$sequenceRef) = read_fasta ($filename);


# stat FASTA - Subroutine call 
my ($ref_acount, $ref_ccount, $ref_gcount, $ref_tcount, $ref_cgcounts,
$ref_aprops, $ref_cprops, $ref_gprops, $ref_tprops, $ref_cgprops) = stat_fasta ("$name.ot", $headerRef, $sequenceRef); 
print ("Count of A: ", join (" ", @$ref_acount), "\n");                                            #dereferencing
print ("Count of C: ", join (" ", @$ref_ccount), "\n");
print ("Count of G: ", join (" ", @$ref_gcount), "\n");
print ("Count of T: ", join (" ", @$ref_tcount), "\n");
print ("Count of CG: ",join (" ", @$ref_cgcounts), "\n");
print ("Proportion of A: ",join (" ", @$ref_aprops), "\n");
print ("Proportion of C: ",join (" ", @$ref_cprops), "\n");
print ("Proportion of G: ",join (" ", @$ref_gprops), "\n");
print ("Proportion of T: ",join (" ", @$ref_tprops), "\n");
print ("Proportion of CG: ",join (" ", @$ref_cgprops), "\n");



# permute FASTA - Subroutine call
for (my $i = 0; $i < scalar @$sequenceRef; $i++) {
#print " Actual String: @$sequenceRef[$i] \n";
@$sequenceRef[$i]=permute_fasta (@$sequenceRef[$i]);
#print " Change String: @$sequenceRef[$i] \n";
}


# write FASTA - Subroutine call
write_fasta ("$name"."_permute.fsa", $headerRef, $sequenceRef);


# stat FASTA - Subroutine call
stat_fasta ("$name"."_permute.ot", $headerRef, $sequenceRef);

#print (@$headerRef);               #dereferencing 
#print (@$sequenceRef);               #dereferencing

#Subroutine definition
sub read_fasta
{
my ($filename) = @_;
open(INFILE, $filename) or die "Cannot open $filename\n";
my @header = ();		    # array of headers
my @sequence = ();		    # array of sequences
my $count = 0;	           # number of sequences

my $n = -1;			    # index of current sequence`
while (my $line = <INFILE>) {
    chomp $line;		    # remove training \n from line
    if ($line =~ /^>/) { 	    # line starts with a ">"
	$n++;			    # this starts a new header
	$header[$n] = $line;	    # save header line
	$sequence[$n] = "";	    # start a new (empty) sequence
    }
    else {
	next if not @header;	    # ignore data before first header
	$sequence[$n] .= $line     # append to end of current sequence
    }
}
$count = $n+1;			  # set count to the number of sequences
close INFILE;

# remove white space from all sequences
for (my $i = 0; $i < $count; $i++) 
    {
     $sequence[$i] =~ s/\s//g;
    }
return (\@header, \@sequence);                      #references to @header and @sequence
}

#Subroutine definition
sub write_fasta
{
my ($write_filename, $array_headerRef, $array_sequenceRef) = @_;
open (my $fh, '>', $write_filename) or die "Could not open file '$write_filename' $!";          
for (my $i = 0; $i < scalar @$array_headerRef; $i++)
   {
    print $fh @$array_headerRef[$i], "\n";                             #prints each header followed by its sequence
    print $fh @$array_sequenceRef[$i], "\n";
   }
close $fh;
}

#Subroutine definition
sub stat_fasta
{
my ($write_filename, $array_headerRef, $array_sequenceRef) = @_; 
open (my $file, '>', $write_filename) or die "cannot open file '$write_filename' $!";

## For each sequence
my (@a_counts, @c_counts, @g_counts, @t_counts, @cg_counts);
my (@a_props, @c_props, @g_propts, @t_props, @cg_props);

print ($file "There are ", scalar @$array_headerRef, " sequences in the file");           #to find the number of sequences in the given file
      
      my $total_length = 0;
      my $max_length = 0; 
      my $min_length = 0;
      my $avg_length = 0;
      
for (my $i = 0; $i < scalar @$array_headerRef; $i++)
    {
	  my $seq_length = length (@$array_sequenceRef[$i]);
	  $total_length = $total_length + $seq_length;    
      if ($i == 0) 
	  {
	  $max_length = $seq_length;                            # to find the Maximum sequence length
          $min_length = $seq_length;                       # to find the Minimum sequence length   
	  }
	  else
	  { 
	    if ($max_length < $seq_length)
		{
		  $max_length = $seq_length; 
	    }
		
		if ($min_length > $seq_length)
		{
		   $min_length = $seq_length;
		}
	  }
	  
    }
	 print ($file "\nTotal sequence length = $total_length\n");
	 print ($file "Maximum sequence length = $max_length\n");
	 print ($file "Minimum sequence length = $min_length\n");
	 
$avg_length = $total_length / scalar @$array_headerRef;                          # to find the Average sequence length
print ($file "Ave sequence length = $avg_length\n");


for (my $i = 0; $i < scalar @$array_headerRef; $i++) 
    {
	  my $acounts = 0;
      my $ccounts = 0;
      my $gcounts = 0;
      my $tcounts = 0;
	  my $cgcounts = 0;
	  my $seq_length = length (@$array_sequenceRef[$i]);
	  print ($file @$array_headerRef[$i], "\n");                    # to print the header line
	  print ($file "Length:", $seq_length, "\n");   	# to find out the length of each sequence
	  
	  	  
	  

    for (my $position = 0; $position < $seq_length; $position++)
	  {
	       my $base = substr (@$array_sequenceRef[$i], $position, 1);           #to find out the count of each nucleotide in the sequence
		   my $bases = substr (@$array_sequenceRef[$i], $position, 2);           #to find out the count of CpG dinucleotides in the sequence
	       if ($base =~ /a/ig) {$acounts++;}
		elsif ($base =~ /c/ig) {$ccounts++;}
		elsif ($base =~ /g/ig) {$gcounts++;}
		elsif ($base =~ /t/ig) {$tcounts++;}
		    if ($bases =~ /cg/ig) {$cgcounts++;}              #the variable $bases will consider two values and check if its CpG 
	  }                                           #if(condition) is yes then counts CpG, if(condition) is false goes to the start of for loop 
	
      my $aprops = 0;                            #to find out the proportion of nucleotides in sequence
	  my $cprops = 0;
	  my $gprops = 0;
	  my $tprops = 0;
	  my $cgprops = 0;                          
	 
	  $aprops = ($acounts / $seq_length);
	  $cprops = ($ccounts / $seq_length);
	  $gprops = ($gcounts / $seq_length);
	  $tprops = ($tcounts / $seq_length);
	  $cgprops = ($cgcounts / $seq_length );
	  
	  
	  $a_counts[$i] = $acounts;     # this variable $a_counts[$i] gets the count of A's found in each sequence. 
	  $c_counts[$i] = $ccounts;
	  $g_counts[$i] = $gcounts;
	  $t_counts[$i] = $tcounts;
	  $cg_counts[$i] = $cgcounts;
	  $a_props[$i] = $aprops;
	  $c_props[$i] = $cprops;
	  $g_propts[$i] = $gprops;
	  $t_props[$i] = $tprops;
          $cg_props[$i] = $cgprops;
	 
      printf $file ("A:%4d %1.2f\n", $acounts, $aprops);
      printf $file ("C:%4d %1.2f\n", $ccounts, $cprops);
      printf $file ("G:%4d %1.2f\n", $gcounts, $gprops);
      printf $file ("T:%4d %1.2f\n", $tcounts, $tprops);
      printf $file ("CG:%4d %1.2f\n", $cgcounts, $cgprops);   
    }
	close $file;
	 return (\@a_counts, \@c_counts, \@g_counts, \@t_counts, \@cg_counts, \@a_props, \@c_props, \@g_propts, \@t_props, \@cg_props);
}


#Subroutine definition
sub permute_fasta
{ 
my ($array_string) = @_;
my @array = split('', $array_string);                     #explodes the string into separate elements
my @shuffled = shuffle(@array);                   #shuffles the elements in array
my $string = join('', @shuffled);                           #joins them back to form a string
return $string;
}