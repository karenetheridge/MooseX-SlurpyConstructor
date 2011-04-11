package MooseX::SlurpyConstructor;

use strict;
use warnings;

use Moose 0.94 ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use MooseX::SlurpyConstructor::Role::Object;
use MooseX::SlurpyConstructor::Trait::Class;
use MooseX::SlurpyConstructor::Trait::Attribute;

{
    my %meta_stuff = (
        class_metaroles => {
            class       => ['MooseX::SlurpyConstructor::Trait::Class'],
            attribute   => ['MooseX::SlurpyConstructor::Trait::Attribute'],
        },
# TODO: need to figure out where to put this.
# see MooseX::StrictConstructor and MooseX::ClassAttribute for role magic.
#        role_metaroles  => {
#            role        => ['MooseX::SlurpyConstructor::Trait::Class'],
#            attribute   => ['MooseX::SlurpyConstructor::Trait::Attribute'],
#        },
        base_class_roles => ['MooseX::SlurpyConstructor::Role::Object'],
    );

    if ( Moose->VERSION < 1.9900 ) {
        require MooseX::SlurpyConstructor::Trait::Method::Constructor;
        push @{$meta_stuff{class_metaroles}{constructor}}, 'MooseX::SlurpyConstructor::Trait::Method::Constructor';
    }
    else {
        1;
    }

    Moose::Exporter->setup_import_methods(
        %meta_stuff,
    );
}

1;

# ABSTRACT: Make your object constructors collect all unknown attributes

__END__

=pod

=head1 SYNOPSIS

    package My::Class;

    use Moose;
    use MooseX::SlurpyConstructor;

    TODO

=head1 DESCRIPTION

TODO

=head1 BUGS

Please report any bugs or feature requests to
C<bug-moosex-slurpyconstructor@rt.cpan.org>, or through the web
interface at L<http://rt.cpan.org>.  I will be notified, and then
you'll automatically be notified of progress on your bug as I make
changes.

# TODO: mention #moose irc channel and mailing list.

=cut
