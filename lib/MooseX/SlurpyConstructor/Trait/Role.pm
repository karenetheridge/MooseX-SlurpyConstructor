package MooseX::SlurpyConstructor::Trait::Role;

use Moose::Role;

sub composition_class_roles { 'MooseX::SlurpyConstructor::Trait::Composite' }

no Moose::Role;

1;
