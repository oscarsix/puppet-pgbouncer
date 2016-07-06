#
# == Define: pgbouncer::hba_rule
#
# Manage an individual rule that applies to the pgbouncer host based access
# file for a given pgbouncer instance.
#
# === Parameters
#
# [*description*]
#   A human-readable description of the rule.
#   String.
#   Default: title of the resource.
#
# [*type*]
#   The connection type this rule applies to, as described in the PostgreSQL
#   documentation at
#   http://www.postgresql.org/docs/9.4/static/auth-pg-hba-conf.html.
#   String.  (local|host|hostssl|hostnossl)
#   Required.
#
# [*database*]
#   The name of the database this rule applies to.  The value `all`
#   specifies that it matches all databases.  The value `sameuser` specifies
#   that it matches if the requested database has the same name as the
#   requested user.  A file containing one or more database names can be
#   specified by providing the filename prefixed with `@`.  Otherwise this
#   is the database name, multiple database names separated by commas, or an
#   array of database names.
#   String.  (all|sameuser|@file|<comma-separated database names>)
#   Array.  Database names.
#   Required.
#
# [*user*]
#   The name of the user this rule applies to.  The value `all` specifies
#   that it matches all users, otherwise this is one or more comma-separated
#   usernames or an array of usernames, or the `@`-prefixed name of a file
#   containing one or more usernames.
#   String.  (all|@file|<comma-separated usernames)
#   Array.  Usernames.
#   Required.
#
# [*address*]
#   An IPv4 or IPv6 address range specified in CIDR format.  Not required
#   for `local` rules.
#   String.
#
# [*auth_method*]
#   The authentication method to use when a connection matches this rule.
#   String.  (trust|reject|md5|password|peer|cert)
#   Required.
#
# [*order*]
#   Sequence number for this rule.  Rules will be ordered in the
#   configuration from lowest to highest sequence number.
#   String.  A zero-padded three digit number.
#   Default: '150'
#
# === Example usage
#
#  pgbouncer::hba_rule { 'localhost_trust':
#    type        => 'host',
#    database    => 'all',
#    user        => 'all',
#    address     => '127.0.0.1/32',
#    auth_method => 'trust',
#    order       => '150',
#  }
#

define pgbouncer::hba_rule(
  $type,
  $database,
  $user,
  $auth_method,
  $description = $title,
  $address     = undef,
  $order       = '150',
) {

  validate_re($type, '^(local|host|hostssl|hostnossl)$',
  "The type you specified [${type}] must be one of: local, host, hostssl, hostnossl")

  if ($type =~ /^host/ and $address == undef) {
    fail('You must specify an address property when type is host based')
  }

  validate_re($auth_method, '^(trust|reject|md5|password|peer|cert|ident)$',
  "The auth_method you specified [${auth_method}] must be one of: trust, reject, md5, password, peer, cert, ident")

  if is_array($database) {
    $databases = join($database, ',')
  } else {
    $databases = $database
  }

  if is_array($user) {
    $users = join($user, ',')
  } else {
    $users = $user
  }

  $fragname = "pgbouncer_hba_rule_${name}"
  concat::fragment { $fragname:
    target  => '/etc/pgbouncer/hba.conf',
    content => template('pgbouncer/pg_hba_rule.conf.erb'),
    order   => $order,
  }

}
