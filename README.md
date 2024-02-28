# pass-select

pass-select is an extension for [password-store].
It empowers users to organize their password-store entries in their preferred file format.
It calls a user defined executable to retrieve the relevant part of an entry.

## Usage

Assuming the password-store entry "foo":
```yaml
super-secret-password
---
username: foo
url: foo.tld
```

Say a user wants to retrieve the username using [yq].

A user may do:
```console
$ export PASSWORD_STORE_CONTENT_SELECTOR=yq
$ pass select foo .username
bar
```

## Custom content selector

The interface is:
- /dev/stdin is given the unencrypted content of the password entry.
- The first argument is expression given to pass-select.
- The result must be sent to /dev/stdout.
- The result must be empty if it didn't find the given expression.
- A non zero exit status aborts the command.

For example, my own selector is:

```bash
grep -Pom1 "^$1: \K.*" | xargs -r
```

[password-store]: https://www.passwordstore.org/
[yq]: https://github.com/mikefarah/yq
