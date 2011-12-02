package App::PassManager::Role::Store;
use Moose::Role;

use File::Path 'make_path';

has '_master' => (
    is => 'rw',
    isa => 'Str',
    accessor => 'master',
    clearer => 'clear_master',
);

has '_user' => (
    is => 'rw',
    isa => 'Str',
    accessor => 'user',
    clearer => 'clear_user',
);

sub init_store {
    my $self = shift;

    if (-e $self->store_file) {
        my $store = $self->store;
        die qq{$0: password store "$store" already exists!\n};
    }

    make_path($self->store_home);
    make_path($self->user_home);
}

1;
