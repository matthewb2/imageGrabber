
use LWP::UserAgent;
use autodie qw/ open close /;
use WWW::Mechanize;
use LWP::Simple qw($ua get);
 use List::MoreUtils qw(uniq);
 use Image::Size;
use URI::Escape;



my $qname = $ARGV[0];

print "passing argument : $qname\n";

my ($protocol, $domain, @page) = split ":*\/+", $qname;
$uri_page = join "/", @page;


print "created directory: $domain\n";

mkdir $domain;

chdir($domain) or die "can't change folder to $domain\n";
 
$ua->agent('My agent/1.0');

# create WWW::Mechanize object
# autocheck 1 checks each request to ensure it was successful
my $mech = WWW::Mechanize->new();


# retrieve page

sub Retrieve{
		my ($url) = @_;
		$url = uri_unescape($url);
		print $url;
        $mech->get($url);
		my $str = $mech->content();
		#treat when the source of image has a relative path???
		# find the last /
			
		
		my @exts = ("jpg", "png", "PNG", "JPG");
		foreach $ext(@exts){
			my @matches = ( $str =~ m/(src=.*?).$ext/g);
			
			
			if (@matches){
				foreach my $elem(@matches) {
					$elem =~ s/src=//g;
					$elem =~ s/"//g;
					$elem =~ s/'//g;
					$elem = $elem.".".$ext;
					my $sub_url = $elem;
					
					if ($sub_url =~ /http/)
					{ 
					  
					} else {
					#print "http missing ".$sub_url."\n";
					$url =~ m|^( .*?\. [^/]+ )|x;
					$sub_url = "$1.$sub_url\n";
					print $sub_url;
					}
					if (my $img = get $sub_url){
					
					my ($height, $width, $id) = imgsize(\$img);
						
					#my $varTemp = $img;
					#$varTemp =~ s/[\$#@~!&*()\[\];.,:?^ `\\\/]+//g;;
						if ($width >200 && $height>250){
						print $height . " " . $width . " " . $id." ";
							my $filename = int(rand(1000000000)).".".$ext;
							

							open FILE, ">$filename";
							binmode FILE;

							print FILE $img;
						}
					}
					else {print "can not get image\n";}
						 
				}
			}
		}
}

Retrieve(uri_escape($qname));


$mech->get($qname);

my @list = $mech->find_all_links(
		url_regex => qr/^.*\.(?!css|js|ico|jpg}png|bmp|svg|xml)[a-z0-9]+$/);  #find all links on this page that starts with http://www.tree.com

###
while (@list){
	my $new_link = shift @list;

	my $url = $new_link->url_abs();
	unless ($url =~ m/enjoyshoes/)
	{
		eval {
		$mech->get($url);
		#my $str = $mech->content();
		my @new_list = $mech->find_all_links(
				url_regex => qr/^.*\.(?!css|js|ico|jpg}png|bmp|svg|xml)[a-z0-9]+$/);  #find all links on this page that starts with http://www.tree.com
			foreach $new_node (@new_list){
				#print $new_node;
				my $link_node = $new_node->url_abs();
				#print $link_node."\n";
				
					eval{
					  $mech->get($link_node) ; 
						my $str = $mech->content();
						my @matches = ( $str =~ m/(src=".*?).jpg/g);
						#print $#matches;
						if ($#matches >= 5){   #mimimum number of images
							push @list, $new_node;
							#print "push succeed\n";
							#@list = uniq @list;
							#last
						}
					};				
				}
		};		
	#@list = uniq @list;
	Retrieve($url);
	}
	print $#list." nodes remained\n";
	#print $url;
	print "\n";
	@list = uniq @list;
}
###

