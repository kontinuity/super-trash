# Xcode auto-versioning script for Subversion by Axel Andersson
# Updated for git by Marcus S. Zarra and Matt Long
 
use strict;
 
# Get the current git commit hash and use it to set the CFBundleVersion value
my $REV = `git show --abbrev-commit | grep "^commit"`;
my $INFO = "build/Debug/shredder.app/Contents/Info.plist";
 
my $version = $REV;
if( $version =~ /^commit\s+([^.]+)\.\.\.$/ )
{ 
	$version = $1;
}
else
{
	$version = undef;
}
# die "$0: No Git revision found" unless $version;
 
open(FH, "$INFO") or die "$0: $INFO: $!";
my $info = join("", <FH>);
close(FH);
 
$info =~ s/([\t ]+<key>CFBundleVersion<\/key>\n[\t ]+<string>).*?(<\/string>)/$1$version$2/;
 
open(FH, ">$INFO") or die "$0: $INFO: $!";
print FH $info;
close(FH);