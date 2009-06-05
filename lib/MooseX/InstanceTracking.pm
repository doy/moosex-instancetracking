package MooseX::InstanceTracking;
use strict;
use warnings;

use Moose::Exporter;
use MooseX::InstanceTracking::Role::Class;

our $VERSION = '0.04';

Moose::Exporter->setup_import_methods();

sub init_meta {
    shift;
    my %p = @_;

    Moose->init_meta(%p);

    return Moose::Util::MetaRole::apply_metaclass_roles(
        for_class  => $p{for_class},
        metaclass_roles => [ 'MooseX::InstanceTracking::Role::Class' ],
        constructor_class_roles => [ 'MooseX::InstanceTracking::Role::Constructor' ],
    );
}


1;

__END__

=head1 NAME

MooseX::InstanceTracking - Trait for tracking all instances of a class

=head1 SYNOPSIS

    package Employee;
    use Moose;
    use MooseX::InstanceTracking;

    my $merrill = Employee->new;
    my $howard = Employee->new;

    Employee->meta->instances; # $merrill, $howard (or $howard, $merrill)
    Employee->meta->get_all_instances; # $merrill, $howard (or $howard, $merrill)


    package Employee::Chef;
    use Moose;
    extends 'Employee';

    my $kalin = Employee::Chef->new;

    Employee->meta->instances; # $merrill, $howard (or $howard, $merrill)
    Employee->meta->get_all_instances; # $merrill, $howard, $kalin (or $howard,  $merrill, $kalin)

=head1 DESCRIPTION

This extends your metaclass by providing instance tracking. Every object
that is instantiated will be tracked on the metaclass. This can be useful if
you need to interact with all the live objects for some reason.

There are two traits: a class trait, which adds the instance store and
accessors for it; and a constructor trait, which ensures that even instances
generated by inlined constructors are tracked.

=head1 METACLASS METHODS

=over 4

=item instances

Returns the B<unordered> set of instances of this direct class. Instances of
subclasses are not included in this set.

=item get_all_instances

Returns the B<unordered> set of instances of this direct class and all of its
subclasses.

=back

=head1 PRIVATE METACLASS METHODS

You should probably not call these methods. If you extend Moose by adding some
way to construct objects outside of L<Moose::Meta::Class/construct_instance>,
you I<are> crazy but you'll need to call these methods.

=over 4

=item _track_instance

Begins tracking the instance(s) passed.

=item _untrack_instance

Explicitly stops tracking the instance(s) passed. You do not need to call this
if your instance is garbage collected, since we use L<Set::Object::Weak>.
However if your instance leaves the class some other way, you may need to
explicitly call this. For example, this can happen in core Moose when an
instance is reblessed.

=back

=head1 AUTHOR

Shawn M Moore, C<sartak@bestpractical.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 Shawn M Moore.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

