package StorMan::Routes_Iscsi;

use 5.010;
use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use StorMan::Config;
use StorMan::Iscsi;

my $msg = '';

prefix '/maint/iscsi';

get '/iscsi_nodes_report' => require_role config->{admin_role} => sub {
    get_serverconfig();

    template 'dashboard-iscsi_nodes' => {
        section   => param('section'),
        nodesinfo => get_iscsi_nodes(),
        servers   => \%servers,
        },{
        layout => 0 };
};

get '/?:errcode?' => require_role config->{admin_role} => sub {
    my $errmsg  = '';
    my $errstatus = "";

    my $errcode = param('errcode');

    if ( defined($errcode) ) {
        if ( $errcode eq "0" ){
            $errmsg    = $msg;
            $errstatus = "success";
            $msg       = '';
        }else{
            $errmsg    = $msg;
            $errstatus = "error";
            $msg       = '';
        }
    }
    get_serverconfig();

    template 'maintenance-iscsi' => {
        section   => 'maintenance',
        errstatus => $errstatus,
        errmsg    => $errmsg,
        servers   => \%servers,
    };
};

post '/discovery' => require_role config->{admin_role} => sub {
    my $targetIP = param('discover');
    my $server   = param('server');

    info("iSCSI-Discovery $targetIP on $server by ". session('logged_in_user'));

    my ($err_code, $return_msg) = discover_new_target( $targetIP, $server );
    $msg = $return_msg;

    redirect "/maint/iscsi/$err_code";
};

post '/login' => require_role config->{admin_role} => sub {
    my $iqn      = param('iqn_arg');
    my $targetIP = param('hostip_arg');
    my $server   = param('server_arg');

    info("iSCSI-Login $targetIP - $iqn on $server by ". session('logged_in_user'));

    my ($err_code, $return_msg) = login_on_node( $iqn, $targetIP, $server );
    $msg = $return_msg;

    return $err_code;
};

1;
