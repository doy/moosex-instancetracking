package MooseX::InstanceTracking;
use Moose::Role;
use Set::Object::Weak;

has _instances => (
    is      => 'ro',
    isa     => 'Set::Object::Weak',
    default => sub { Set::Object::Weak->new },
    handles => {
        instances => 'members',
        track_instance => 'insert',
    },
    lazy    => 1,
);

around 'construct_instance', 'clone_instance' => sub {
    my $orig = shift;
    my $self = shift;

    my $instance = $orig->($self, @_);
    $self->track_instance($instance);

    return $instance;
};

around rebless_instance => sub {
    my $orig     = shift;
    my $self     = shift;
    my $instance = shift;

    my $return = $orig->($self, $instance, @_);

    $self->track_instance($return);

    return $return;
};

before make_immutable => sub {
    confess "Instance tracking does not yet work with make_immutable.";
};

1;

