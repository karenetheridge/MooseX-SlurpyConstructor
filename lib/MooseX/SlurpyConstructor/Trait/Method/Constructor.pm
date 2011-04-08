package MooseX::SlurpyConstructor::Trait::Method::Constructor;

# applied as class_metaroles => { constructor => [ __PACKAGE__ ] }, for Moose 1.2x

use Moose::Role;

use namespace::autoclean;

use B ();

around '_generate_BUILDALL' => sub {
    my $orig = shift;
    my $self = shift;

    my $source = $self->$orig();
    $source .= ";\n" if $source;

    my @attrs = (
        '__INSTANCE__ => 1,',
        map { B::perlstring($_) . ' => 1,' }
        grep {defined}
        map  { $_->init_arg() } @{ $self->_attributes() }
    );

    # XXX TODO
    $source .= <<"EOF";
my \%attrs = (@attrs);

my \@bad = sort grep { ! \$attrs{\$_} }  keys \%{ \$params };

if (\@bad) {
    Moose->throw_error("Found unknown attribute(s) passed to the constructor: \@bad");
}
EOF

    return $source;
};

1;

# ABSTRACT: A role to make immutable constructors slurpy

__END__

=pod

=head1 DESCRIPTION

This role simply wraps C<_generate_BUILDALL()> (from
C<Moose::Meta::Method::Constructor>) so that immutable classes have a
slurpy constructor.

=cut

