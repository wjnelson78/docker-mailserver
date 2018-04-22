#!/usr/bin/env bats
@test "send mail to local address" {
    swaks --to admin@example.com
    [ "$?" -eq 0 ]
}

@test "send mail to local address with extension" {
    swaks --to admin-test@example.com
    [ "$?" -eq 0 ]
}

@test "send mail with smtp authentification" {
    swaks --to admin@example.com --from admin@example.com -a -au admin@example.com -ap changeme -s example.com -tls
    [ "$?" -eq 0 ]
}

@test "send mail to local alias" {
    swaks --to foo@example.com
    [ "$?" -eq 0 ]
}

@test "maildir contains files" {
    postqueue -f
    sleep 10

    files="$(ls -1 /var/vmail/example.com/admin/Maildir/new/ | wc -l)"
    [ "$files" -eq 4 ]
}

@test "send gtube mail is rejected" {
    run swaks --to admin@example.com --data /usr/share/gtube.txt -s mta
    [ "$status" -eq 26 ]
}

@test "virus is rejected" {
    run swaks --to admin@example.com --attach - --server mta < /usr/share/eicar.com
    [ "$status" -eq 26 ]
}

@test "send junk mail to local address" {
    swaks --to admin@example.com --data /usr/share/junk.txt
    [ "$?" -eq 0 ]
}

@test "count mails in junk via imap (sieve rule is working)" {
    postqueue -f
    sleep 10

    result="$(imap-tester test:count mda 143 admin@example.com changeme Junk)"
    [ "$result" -eq 1 ]
}

@test "count mails in inbox via imap" {
    result="$(imap-tester test:count mda 143 admin@example.com changeme INBOX)"
    [ "$result" -eq 4 ]
}

@test "count mails in inbox via imaps" {
    result="$(imap-tester test:count mda 993 admin@example.com changeme INBOX)"
    [ "$result" -eq 4 ]
}

@test "count mails in inbox via pop3" {
    result="$(imap-tester test:count mda 110 admin@example.com changeme INBOX)"
    [ "$result" -eq 4 ]
}

@test "count mails in inbox via pop3s" {
    result="$(imap-tester test:count mda 995 admin@example.com changeme INBOX)"
    [ "$result" -eq 4 ]
}
