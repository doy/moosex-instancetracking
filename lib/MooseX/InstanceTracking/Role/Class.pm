package MooseX::InstanceTracking::Role::Class;
use Moose::Role;
use Set::Object::Weak;

our $VERSION = '0.02';

has _instances => (
    isa     => 'Set::Object::Weak',
    default => sub { Set::Object::Weak->new },
    lazy    => 1,
    handles => {
        instances         => 'members',
        _track_instance   => 'insert',
        _untrack_instance => 'remove',
    },
);

sub get_all_instances {
    my $self = shift;
    map { $_->meta->instances } $self->name, $self->subclasses;
}

around 'construct_instance', 'clone_instance' => sub {
    my $orig = shift;
    my $self = shift;

    my $instance = $orig->($self, @_);
    $self->_track_instance($instance);

    return $instance;
};

after rebless_instance => sub {
    my $self     = shift;
    my $instance = shift;

    $self->_track_instance($instance);
};

before rebless_instance_away => sub {
    my $self     = shift;
    my $instance = shift;

    $self->_untrack_instance($instance);
};

1;

