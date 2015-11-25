# SYNOPSIS

Sparrow - is a tiny monitoring tool based on swat tests.

# FEATURES

* easy install and setup
* console client to setup and run swat test suites 
* ability to run tests remotely over rest API 
* custom plugin repositories support by design 

# INSTALL

cpanm Sparrow

# DEPENDENCIES 

curl, git, bash, swat

# USAGE


## create a project

*sparrow project $project_name create* - create a sparrow project, basically is a container to runs swat rests against different applications:

    sparrow project foo create

## download and install swat plugins

*sparrow plg install $plugin_name* - swat plugin is distributable swat test suite:

    sparrow plg list
    sparrow plg install nginx
    sparrow plg install tomcat

## attach plugins to project

*sparrow project $project_name add_plg $plugin_name* - swat project could contain one or more swat plugins:

    sparrow project foo add_plg nginx 
    sparrow project foo add_plg tomcat

## attach sites to project

*sparrow project $project_name add_site $site_name $base_url* - swat site - is a web application to run swat tests against. Base url parameter should be curl compliant:

    sparrow project foo add_site nginx_proxy http://127.0.0.1 
    sparrow project foo add_site tomcat_app 127.0.0.1:8080
    sparrow project foo add_site tomcat_app my.host/foo/bar

## run swat tests

*sparrow project $project_name check_site $site_name $plugin_name* - runs swat test suite against project's site:

    sparrow project foo check_site nginx_proxy nginx
    sparrow project foo check_site tomcat_app nginx

## customize swat settings for site

*sparrow project $project_name swat_setup $site_name $path_to_swat_ini_file* - setup [swat ini file](https://github.com/melezhik/swat#swat-ini-files) for given site:

    cat /path/to/swat.ini

        port=88
        prove_options='-sq'        

    sparrow project foo swat_setup nginx_proxy /path/to/swat.ini

More information in swat ini files syntax could be found here - (https://github.com/melezhik/swat#swat-ini-files)[https://github.com/melezhik/swat#swat-ini-files]

## run swat tests remotely

*GET /$project_name/check_site/$site_name/$plugin_name* - sparrow rest API allow to run swat test suites remotely over http:

    # runs sparrow rest API daemon
    sparrowd

    # runs swat tests via http call
    curl http://127.0.0.1:5090/foo/check_site/nginx_proxy/nginx


## misc commands 

Various commands not listed in main section:


    # list installed plugins
    sparrow plg list --local

# SWAT PLUGINS

Swat plugins are distributable swat test suites installed from github git repositories. 

By default sparrow does not install any plugins, but one could easily install ones using sparrow plugin list.

Sparrow plugin list is a text file, named *sparrow.list* with lines of following format:

*$plugin_name $git_repo_url*

Where git_repo_url is git repository URL, and plugin_name is name of swat plugin. For example:

    swat-yars https://github.com/melezhik/swat-yars.git
    metacpan https://github.com/CPAN-API/metacpan-monitoring.git

## Creating swat plugins

* get know what [swat](https://github.com/melezhik/swat) is and how to create swat tests for various web applications

* create your swat test suite:

    * create local git repository
    * create swat tests 
    * run swat test to ensure that they works fine
    * create README.md ( optional, but will be useful for  plugin users )
    * create cpanfile to declare perl dependencies
    * commit your changes
    * add remote git repository
    * push your changes


This is simple example of creating plugin with a  single swat story:

    git init .
    echo "local" > .gitignore
    echo "require 'swat'" > cpanfile
    echo 200 OK > get.txt
    git add .
    git commit -m 'my first swat plugin' -a
    git remote add origin $your-remote-git-repository
    git push origin master


That's it. To use your freshly baked plugin just say this:


    echo my-plugin $your-remote-git-repository >> swarrow.list
    swarrow plg install my-plugin






    

