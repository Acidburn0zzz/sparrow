package Sparrow::Commands::Project;

use base 'Exporter';

use Sparrow::Constants;
use Sparrow::Misc;

use Carp;
use File::Basename;
use File::Path;

our @EXPORT = qw{

    show_projects
    create_project
    project_info
    add_plugin_to_project
    add_site_to_project

};


sub show_projects {

    print "sparrow project list:\n\n";

    my $root_dir = sparrow_root.'/projects/';

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p (sort { -M $root_dir.$a <=> -M $root_dir.$b } grep { ! /^\.{1,2}$/ } readdir($dh)){
        print basename($p),"\n";
    }

    closedir $dh;
}

sub create_project {

    my $project = shift;

    if ( -d sparrow_root."/projects/$project" ){
        print "project $project already exists - nothing to do here ... \n\n"
    } else {
        mkpath sparrow_root."/projects/$project";
        mkpath sparrow_root."/projects/$project/plugins";
        mkpath sparrow_root."/projects/$project/sites";
        print "project $project is successfully created\n\n"
    }


}

sub project_info {

    my $project = shift;

    print "project $project info:\n\n";

    print "plugins:\n\n";

    my $root_dir = sparrow_root."/projects/$project/plugins";

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $p (grep { ! /^\.{1,2}$/ } readdir($dh)){

        if ( link_is_dangling(sparrow_root."/projects/$project/plugins/$p") ){
            unlink sparrow_root."/projects/$project/plugins/$p";
        }else{
            print "\t", basename($p),"\n";
        }
    }

    closedir $dh;


    print "\n\n\sites:\n\n";

    my $root_dir = sparrow_root."/projects/$project/sites";

    opendir(my $dh, $root_dir) || confess "can't opendir $root_dir: $!";

    for my $s (grep { ! /^\.{1,2}$/ } readdir($dh)){
        my $base_url = site_base_url($project,basename($s));
        print "\t", basename($s)," [$base_url] \n";
    }

    closedir $dh;


}

sub add_plugin_to_project {

    my $project = shift or confess "usage: add_plugin_to_project(project,plugin)";
    my $pid = shift or confess "usage: add_plugin_to_project(project,plugin)";


    unless ( -d sparrow_root."/plugins/$pid" ){
        print "plugin $pid is not installed yet. run `sparrow plg install $pid` to install it\n";
        exit(1);
    }

    unless ( -d sparrow_root."/projects/$project" ){
        print "project $project does not exist. run `sparrow project $project create` to create it it\n";
        exit(1);
    }

    if ( -l sparrow_root."/projects/$project/plugins/$pid" ){

        print "projects/$project/plugins/$pid already exist - nothing to do here ... \n\n";

    }else{

        symlink File::Spec->rel2abs(sparrow_root."/plugins/$pid"), File::Spec->rel2abs(sparrow_root."/projects/$project/plugins/$pid") or
        confess "can't create symlink projects/$project/plugins/$pid ==> plugins/$pid";

        print "plugin $pid is successfully added to project $project\n\n";
    }

}

sub add_site_to_project {

    my $project = shift or confess "usage: add_site_to_project(project,site,base_url)";
    my $sid = shift or confess "usage: add_site_to_project(project,site,base_url)";
    my $base_url = shift or confess "usage: add_site_to_project(project,site,base_url)";

    if (-d sparrow_root."/projects/$project/sites/$sid" ){

        set_site_base_url($project,$sid,$base_url);

        print "site $sid is successfully updated at project $project\n\n";

    }else{

        mkpath sparrow_root."/projects/$project/sites/$sid";
        set_site_base_url($project,$sid,$base_url);
        print "site $sid is successfully added to project $project\n\n";

    }

}


sub site_base_url {

    my $project = shift or confess "usage: site_base_url(project,site)";
    my $sid = shift or confess "usage: site_base_url(project,site)";

    open F, sparrow_root."/projects/$project/sites/$sid/base_url" or confess "can't open file projects/$project/sites/$sid/base_url to read";
    my $base_url = <F>;
    chomp $base_url;
    close F;
    $base_url;

}

sub set_site_base_url {

    my $project = shift or confess "usage: set_site_base_url(project,site,base_url)";
    my $sid = shift or confess "usage: set_site_base_url(project,site,base_url)";
    my $base_url = shift or confess "usage: set_site_base_url(project,site,base_url)";

    open F, ">", sparrow_root."/projects/$project/sites/$sid/base_url" or 
        confess "can't open file to write: projects/$project/sites/$sid/base_url";
    print F $base_url;
    close F;

}


sub link_is_dangling {

    my $l = shift;
    return stat($l) ? 0 : 1;
}

1;

