package MooseX::SlurpyConstructor::Role::Object;

# applied as base_class_roles => [ __PACKAGE__ ], for all Moose versions.
use Moose::Role;

use namespace::autoclean;

after BUILDALL => sub {
    my $self   = shift;
    my $params = shift;

    my %attrs = (
        __INSTANCE__ => 1,
        map  { $_ => 1 }
        grep { defined }
        map  { $_->init_arg } $self->meta->get_all_attributes
    );

print "### got attrs: ", Dumper(\%attrs);

    my @extra = sort grep { !$attrs{$_} } keys %{$params};

print "### got extra attrs: ", Dumper(\@extra);
    return if not @extra;

    # XXX TODO: stuff all these into the slurpy attr.

    # find the slurpy attr
    # TODO: use the metaclass slurpy_attr to find this:
    # if $self->meta->slurpy_attr
    # and then the check for multiple slurpy attrs can be done at
    # composition time.

    my $slurpy_attr = $self->meta->slurpy_attr;
print "### in BUILDALL, found slurpy attr: ", ($slurpy_attr ? $slurpy_attr->name : "NOT FOUND" ), "\n";

    Moose->throw_error('Found extra construction arguments, but there is no \'slurpy\' attribute present!') if not $slurpy_attr;

    my %slurpy_values;
    @slurpy_values{@extra} = @{$params}{@extra};

print "### assigning this to slurpy attr: ", Dumper( \%slurpy_values );
    $slurpy_attr->set_value( $self, \%slurpy_values );
};

use Data::Dumper;

1;

# ABSTRACT: A role which implements a strict constructor for Moose::Object

__END__

=pod

=head1 SYNOPSIS

  Moose::Util::MetaRole::apply_base_class_roles(
      for_class => $caller,
      roles =>
          ['MooseX::SlurpyConstructor::Role::Object'],
  );

=head1 DESCRIPTION

When you use C<MooseX::SlurpyConstructor>, your objects will have this
role applied to them. It provides a method modifier for C<BUILDALL()>
from C<Moose::Object> that implements strict argument checking for
your class.

=cut
