requires 'perl', '5.008001';
requires 'Class::Accessor::Lite';
requires 'Module::Load';
requires 'String::CamelCase';
requires 'Carp';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

