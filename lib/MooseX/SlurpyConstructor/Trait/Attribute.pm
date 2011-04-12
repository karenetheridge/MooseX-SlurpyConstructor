package MooseX::SlurpyConstructor::Trait::Attribute;

# applied as class_metaroles => { attribute => [ __PACKAGE__ ] }.

use Moose::Role;

use namespace::autoclean;

has slurpy => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

before attach_to_class => sub {
    my ($self, $meta) = @_;

    return if not $self->slurpy;

    # TODO: test these cases

    # save the slurpy attribute in the metaclass, for quick access at
    # object construction time.

    Moose->throw_error('Attempting to use slurpy attribute \'', $self->name,
        '\' in class ', $meta->name,
        ' that does not do the MooseX::SlurpyConstructor::Trait::Class role!')
#        if not $meta->does_role('MooseX::SlurpyConstructor::Trait::Class');
        if not $meta->meta->find_attribute_by_name('slurpy_attr');

    Moose->throw_error('Attempting to use slurpy attribute ', $self->name,
        ' in class ', $meta->name,
        ' that already has a slurpy attribute (', $meta->slurpy_attr->name, ')!')
        if $meta->slurpy_attr;

    $meta->slurpy_attr($self);
};

1;

# ABSTRACT: A role to store the slurpy attribute in the metaclass

__END__

=pod

=head1 NAME MooseX::SlurpyConstructor::Trait::Attribute

=head1 DESCRIPTION

Adds the 'slurpy' attribute to attributes used in
MooseX::SlurpyConstructor-aware classes, and checks that only one such
attribute is present at any time.

=cut
