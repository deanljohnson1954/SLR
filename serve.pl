#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use File::Basename;

my $port = 3456;
my $root = dirname(__FILE__);

my %mime = (
    html => 'text/html',
    css  => 'text/css',
    js   => 'application/javascript',
    png  => 'image/png',
    jpg  => 'image/jpeg',
    jpeg => 'image/jpeg',
    gif  => 'image/gif',
    svg  => 'image/svg+xml',
    ico  => 'image/x-icon',
    woff => 'font/woff',
    woff2 => 'font/woff2',
    txt  => 'text/plain',
);

my $server = IO::Socket::INET->new(
    LocalPort => $port,
    Type      => SOCK_STREAM,
    Reuse     => 1,
    Listen    => 10,
) or die "Cannot create socket: $!";

print "Serving at http://localhost:$port\n";

while (my $client = $server->accept()) {
    my $request = '';
    while (my $line = <$client>) {
        $request .= $line;
        last if $line =~ /^\r?\n$/;
    }

    my ($method, $path) = $request =~ /^(\w+)\s+([^\s]+)/;
    $path = '/' unless defined $path;
    $path =~ s/\?.*$//;  # strip query string
    $path = '/index.html' if $path eq '/';
    $path =~ s|^/||;

    my $file = "$root/$path";
    $file =~ s|/|\\|g if $^O eq 'MSWin32';

    if (-f $file) {
        open(my $fh, '<:raw', $file) or do {
            print $client "HTTP/1.1 500 Error\r\nContent-Length: 5\r\n\r\nError";
            close $client;
            next;
        };
        local $/;
        my $content = <$fh>;
        close $fh;

        my ($ext) = $file =~ /\.(\w+)$/;
        my $type = $mime{lc($ext || '')} || 'application/octet-stream';
        my $len = length($content);

        print $client "HTTP/1.1 200 OK\r\nContent-Type: $type\r\nContent-Length: $len\r\nConnection: close\r\n\r\n$content";
    } else {
        print $client "HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\n\r\nNot found";
    }
    close $client;
}
