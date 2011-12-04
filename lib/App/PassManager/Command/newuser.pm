package App::PassManager::Command::newuser;
use Moose;

extends 'MooseX::App::Cmd::Command';
with qw/
    App::PassManager::CommandRole::Help
    App::PassManager::Role::Files
    App::PassManager::Role::Git
    App::PassManager::Role::Store
    App::PassManager::Role::GnuPG
    App::PassManager::Role::CursesWin
    App::PassManager::Role::InitDialogs
/;

sub abstract {
    return "initialize git repository and password files";
}

sub description {
    return <<ENDDESC;
This command will initalize a new git repository, create a password store,
and ask the user for its master password, and their own user's password.
ENDDESC
}

sub execute {
    my ($self, $opt, $args) = @_;

    die qq{$0: no password store (need to init?)\n}
        unless -e $self->store_file;

    die qq{$0: git repo is dirty, but I don't yet know how to fix that!\n}
        if $self->git->status->is_dirty;

    die (sprintf qq{%s: no such user "%s" (need to adduser?)\n}, $0, $self->username)
        unless -e $self->user_file;

    die qq{$0: missing new username!\n}
        unless $args->[0];
    $self->newusername($args->[0]);

    # no stderr once we fire up Curses::UI
    open STDERR, '>/dev/null';

    $self->new_base_win;
    $self->get_user_win( sub { $self->save_user_and_quit } );
    $self->new_thing_win('user', 'get_user');

    $self->win->{user}->focus;
    $self->ui->mainloop;
}

1;
