requires "Cinnamon" => ">= 0.07";
requires "String::ShellQuote";

# on 'test' => sub {
    requires 'Test::More'     => '0.98';
    requires 'Test::Requires' => '0.06';
    requires 'Test::Exception::LessClever' => '0.006';
# };

# on 'development' => sub {
    requires 'Test::Perl::Critic';
    requires 'Test::Pod';
    requires 'Test::Pod::Coverage';
# };
