# --
# Kernel/Output/HTML/ITSMChangeMenuWorkOrdersNeeded.pm - Menu with check whether there are workorders
# Copyright (C) 2001-2013 OTRS AG, http://otrs.org/
# --
# $Id: ITSMChangeMenuWorkOrdersNeeded.pm,v 1.8 2013-02-05 20:24:55 ub Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::ITSMChangeMenuWorkOrdersNeeded;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.8 $) [1];

# As of 2010-03-19 this module is unused.
# But it is kept in the distribution, as it provides useful functionality for future use.

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (
        qw(ConfigObject EncodeObject LogObject DBObject LayoutObject ChangeObject UserID)
        )
    {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{Change} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need Change!',
        );
        return;
    }

    # check whether there are any workorders yet
    return $Param{Counter} if !$Param{Change}->{WorkOrderCount};

    # get config for the relevant action
    my $FrontendConfig
        = $Self->{ConfigObject}->Get("ITSMChange::Frontend::$Param{Config}->{Action}");

    # get the required privilege, 'ro' or 'rw'
    my $RequiredPriv;
    if ($FrontendConfig) {

        # get the required priv from the frontend configuration
        $RequiredPriv = $FrontendConfig->{Permission};
    }

    my $Access;
    if ( !$RequiredPriv ) {

        # Display the menu-link, when no privilege is required
        $Access = 1;
    }
    else {

        # check permissions, based on the required privilege
        $Access = $Self->{ChangeObject}->Permission(
            Type     => $RequiredPriv,
            Action   => $Param{Config}->{Action},
            ChangeID => $Param{Change}->{ChangeID},
            UserID   => $Self->{UserID},
            LogNo    => 1,
        );
    }

    return $Param{Counter} if !$Access;

    # output menu block
    $Self->{LayoutObject}->Block( Name => 'Menu' );

    # output seperator, when this is not the first menu item
    if ( $Param{Counter} ) {
        $Self->{LayoutObject}->Block( Name => 'MenuItemSplit' );
    }

    # output menu item
    $Self->{LayoutObject}->Block(
        Name => 'MenuItem',
        Data => {
            %Param,
            %{ $Param{Change} },
            %{ $Param{Config} },
        },
    );
    $Param{Counter}++;

    return $Param{Counter};
}

1;
