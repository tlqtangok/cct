#!perl
# add by jd
# used to build intelligently on different platform

# usage
#   perl build.PL 

use strict;
use feature qw(say); 

&main(); 

### sub list ### 
sub main()
{
	my $platform = &get_platform(); 
	my $bin_pyinstaller = 	&ck_dependency_ret_bin($platform); 
	my $cmd_build = &gen_build_statement($platform, $bin_pyinstaller);
	say "- run build cmd for $platform\n\t$cmd_build ..."; 

	#system($cmd_build); 
}

sub ck_dependency_ret_bin($)
{
	my $platform = shift;

	my $bin_pyinstaller = "pyinstaller"; 	
	if ( $platform ne "pi" )
	{
		die "- no pyinstaller, please install pyinstaller\n" if  (`which pyinstaller` !~ m/pyinstaller/ );
	}
	else
	{
		assert($platform eq "pi");
		$bin_pyinstaller = "$ENV{t}/pyinstaller-develop/pyinstaller.py"; 
		die "- no $bin_pyinstaller" if ! -f $bin_pyinstaller; 
	}

	my $magic_num = 1234; 
	my $cml_ck_redis_module = qq{python3 -c 'import redis; print($magic_num)' };  
	$cml_ck_redis_module = qq{python -c "import redis; print ($magic_num)" } if $platform eq "win";

	my $res = qx{$cml_ck_redis_module}; 
	
	chomp($res); 

	die "- no module redis, please install it\n" if $res != $magic_num; 
	return $bin_pyinstaller; 
}

sub gen_build_statement($p)
{
	my $platform = shift; 
	my $bin_pyinstaller = shift;
	
	`mkdir -p ./rel/$platform`; 
	my $cmd_build = qq($bin_pyinstaller -F cct.py --distpath ./rel/$platform/); 
	return $cmd_build; 
}

sub get_platform()
{
	my $error_msg = "- no support platform"."\n"; 
	my $platform = "linux";  # pi, win
	if ($^O eq "linux")
	{
		my $issue_platform = `cat /etc/issue`; 

		if ($issue_platform =~ m/Rasp/i)
		{
			$platform = "pi"; 

		}
		elsif ($issue_platform =~ m/Ubuntu/i)
		{
			$platform = "linux"; 
		}
		else
		{
			die "$error_msg"; 
		}


	}
	elsif ($^O eq "MSWin32")
	{

		$platform = "win"; 

	}
	else
	{
		die "$error_msg"; 
	}

}
