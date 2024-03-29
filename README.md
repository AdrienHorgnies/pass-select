# pass-select

pass-select is an extension for [password-store].
It helps users to select data from their password-store entries **using their preferred file format**.
It calls a user defined executable to retrieve the relevant part of an entry.
A good example would be [yq] which supports YAML, JSON and XML.

Without pass-select, a user may:
- Either pipe pass output into their tool, ex.: `pass foo | yq '.username' | wl-copy && sleep 45 && wl-copy -c &`
- Or get irrelevant metadata along the desired value, ex.: getting "username: foo" instead of "foo".

## Usage

Assuming the password-store entry "foo" formatted as YAML:
```yaml
super-secret-password
---
username: bar
url: foo.tld
```

A user may do:
```console
$ export PASSWORD_STORE_CONTENT_SELECTOR=yq
$ pass select foo .username
bar
```

By default, it sends the selected value to the standard output.
The option -c copies the selected value to the clipboard.
The option -q displays a QR code representation of the selected value.

## Custom content selector

The user can choose or create a custom content selector.

The interface is:
- /dev/stdin is given the unencrypted content of the password entry.
- The first argument is the expression given to pass-select.
- The result must be sent to /dev/stdout.
- The result must be empty if it didn't find the given expression.
- A non zero exit status aborts the command.

For example, my own selector is:

```bash
grep -Pom1 "^$1: \K.*" | xargs -r
```

Don't forget to define the env variable PASSWORD_STORE_CONTENT_SELECTOR to point to the executable.
The executable must be in the PATH, or be an absolute path.
Persist the variable by defining it in your .bashrc or equivalent.

## Install

Put the script "select.bash" in the password-store extensions.
For example:
```console
cd /usr/lib/password-store/extensions
sudo wget https://github.com/AdrienHorgnies/pass-select/releases/latest/download/select.bash
```

You'll also want to define PASSWORD_STORE_CONTENT_SELECTOR in your .bashrc or equivalent:

```bash
export PASSWORD_STORE_CONTENT_SELECTOR=<executable name/path>
```

## Uninstall

Simply remove the script:
```console
sudo rm /usr/lib/password-store/extensions/select.bash
```

[password-store]: https://www.passwordstore.org/
[yq]: https://github.com/mikefarah/yq
