#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);

# File: Assignment4_Jenkins.pm
# Author: Frank Jenkins
# Date: 11 Nov 2017
#
# Purpose: Create web interface to prompt user to enter a FASTA file
# then read sequences from that file and generate a report




my $path = "/userhomes/students/fjenkin/public_html/cgi-bin";   # path to program directory
my $prog = "cpg.pl";                          # the program we want to run
my $url = "/fjenkin/public_html/cgi-bin/wrapper";              # the URL of this script
my $dir = "/tmp/CGI-$$";                        # working directory
$ENV{PATH} = "/bin:/usr/bin";                   # makes it OK to run other programs


# Create an HTML form with a FILE FIELD:
print header;
print start_html('A Web Interface'),
    h3("A Web Interface for $prog"),
    start_multipart_form,  p,
    "Click the button to choose the input file:",
    br, filefield('filename'), p,
    reset, submit('submit','Submit File'), end_form;

# This part processes the form after the user clicks on "Submit"
if (defined param()) {
    
    # get filehandle on file uploaded from internet
    my $filehandle = upload('filename');
    if (not defined $filehandle) {
        # the user did not enter a file name
        print p, strong("Please complete file field."), p,
              address( a({href=>$url}, "Try again."));
        exit;
    }

    # copy uploaded file to working directory
    mkdir $dir or die "Can't create directory $dir\n";
    chdir $dir or die "Can't change to directory $dir\n";
    print hr, p, "Working directory = $dir", p;
    
    my $infile = "in";
    open FH, ">$infile" or die "Can't open $infile";
    while (<$filehandle>) {
        s/\r//g;     # convert end-of-line character to Unix
        print FH;
    }
    close $filehandle;
    close FH;

    # display the input file on the web page
    print hr, p, "Input file = $infile", p;
    print_file($infile);

# run the program on the input file and save the output
    my $outfile = "out";
    
    # "$path/$prog" is the full path to the target Perl program
    my $command = "$path/$prog $infile > $outfile";
    
    # run the given command
    print hr, p, "Executing: <PRE>$command</PRE>", p;
    system $command;

    # display the output on the web page
    print hr, p, "Output:", p;
    print_file($outfile);

    # clean up (comment out when debugging)
    system "rm -rf $dir";

    # provide a link to run the wrapper again
    print hr, p;
    print address( a({href=>$url},"Click here to run the program again."));
}
print end_html;
exit;

sub print_file {
    my ($file) = @_;

    if (open(OUTFILE, "$file")) {
        my @output = <OUTFILE>;
        close OUTFILE;

        print "<PRE>";              # preformatted output
        foreach my $line (@output) {
            # convert any special HTML characters
	    # change "&" to "&amp;", "<" to "&lt;", ">" to "&gt;"
            $line = escapeHTML($line);
            print $line;
        }
        print '</PRE>';             # end preformatted output
    } else {
        print strong("<font color=red>Sorry,
           an error has occurred in reading the file \"$file\".</font>");
    }
}



