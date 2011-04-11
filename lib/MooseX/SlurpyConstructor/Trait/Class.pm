package MooseX::SlurpyConstructor::Trait::Class;

# applied as class_metaroles => { class => [ __PACKAGE__ ] }.

use Moose::Role;

use namespace::autoclean;

use B ();

around '_inline_BUILDALL' => sub {
    my $orig = shift;
    my $self = shift;

    my @source = $self->$orig();

    my @attrs = (
        '__INSTANCE__ => 1,',
        map  { B::perlstring($_) . ' => 1,' }
        grep { defined }
        map  { $_->init_arg } $self->get_all_attributes
    );
print "### in inline_BUILDALL for ", $self->name, "\n";

    my $slurpy_attr = $self->slurpy_attr;
print "### when inlining BUILDALL for ", $self->name, ", found slurpy attr: ", ($slurpy_attr ? $slurpy_attr->name : "NOT FOUND" ), "\n";


# XXX TODO:
#    return (
my @code = (
        @source,
        'my %attrs = (' . ( join ' ', @attrs ) . ');',
        'my @extra = sort grep { !$attrs{$_} } keys %{ $params };',
'print "### got extra attrs: ", Data::Dumper::Dumper(\@extra);',
        'if (@extra){',

        !$slurpy_attr
            ? 'Moose->throw_error("Found extra construction arguments, but there is no \'slurpy\' attribute present!");'
            : (
                'my %slurpy_values;',
                '@slurpy_values{@extra} = @{$params}{@extra};',

'print "### (inlined constructor) assigning this to slurpy attr: ", Data::Dumper::Dumper( \%slurpy_values );',
                '$instance->meta->slurpy_attr->set_value( $instance, \%slurpy_values );',
            ),
        '}',
    );
print "### generated code for ", $self->name, ": ", Dumper(\@code);
return @code;
}
if Moose->VERSION >= 1.9900;

# quick access to the slurpy attribute
# (which holds the extra constructor arguments)
has slurpy_attr => (
    is => 'rw',
    isa => 'Maybe[Moose::Meta::Attribute]',
    weak_ref => 1,
);

# reader also looks up the class heirarchy
around slurpy_attr => sub {
    my $orig = shift;
    my $self = shift;

print "##### in accessor for slurpy_attr\n";
    # writer
print "### setting slurpy_attr on metaclass for ", $self->name, "\n" if @_;
    return $self->$orig(@_) if @_;

    # reader

    my $result = $self->$orig;
print "### found a slurpy_attr value on self; returning!\n" if $result;
    return $result if $result;

        # TODO: walk the isa tree looking for slurpy_attr
        # or can we simply do find_attribute_by_name?
    
print "### slurpy_attr reader called on ", $self->name, "\n";
my $i = 0;
print Carp::longmess("### linearized isa is: ", map { $_->meta->name } $self->linearized_isa); 
print "\n";
    my @slurpy_attr_values = map {
print "### ", $i++, " checking metaclass for ", $_->meta->name, " for slurpy_attr\n";
print "### found ", $_->meta->meta->get_attribute('slurpy_attr') || 'none', "\n";
        
        my $attr = $_->meta->meta->get_attribute('slurpy_attr');
        !$attr
            ? ()
            : $attr->get_value($_->meta) || ();
    }
    $self->linearized_isa;

print "!!!!!!!!\n";
{
local $Data::Dumper::Maxdepth = 2;
print "### found slurpy_attrs for ", $self->name, ": ", Data::Dumper::Dumper(\@slurpy_attr_values), "---\n";
}

$i = 0;
    foreach my $ancestor ($self->linearized_isa)
    {
print "### ", $i++, " checking metaclass for ", $ancestor->meta->name, " for slurpy_attr\n";

{
    local $Data::Dumper::Maxdepth = 2;
print " ------ all attrs found on this class and metaclass (without subclass traversal) are: ",
Dumper({
    class => [ $ancestor->meta->get_attribute_list ],
    metaclass => [ $ancestor->meta->meta->get_attribute_list ],
});
}

        my $attr = $ancestor->meta->meta->find_attribute_by_name('slurpy_attr');
print "### found ", $attr || 'none', "\n";
        next if not $attr;
        my $attr_value = $attr->get_value($ancestor->meta);
print "### ...but it has no value!\n" if not $attr_value;
print "###### returning $attr_value\n" if $attr_value;
        return $attr_value if $attr_value;
    }
print "### got to end, found no slurpy attrs. :(\n";
return;

};
use Data::Dumper;

after superclasses => sub
{
    my $self = shift;
    return if not @_;
print "### reapplying base_class_roles for ", $self->name, "\n";
    Moose::Util::MetaRole::apply_base_class_roles(
        for => $self->name,
        roles => ['MooseX::SlurpyConstructor::Role::Object'],
    )
};



1;

# ABSTRACT: A role to make immutable constructors strict

__END__

=pod

=head1 DESCRIPTION

This role simply wraps C<_inline_BUILDALL()> (from
C<Moose::Meta::Class>) so that immutable classes have a
strict constructor.

=cut
