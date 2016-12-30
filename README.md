# package-python

Python is a programming language that lets you work more quickly and integrate your systems more effectively. <https://www.python.org>

See <https://www.python.org/downloads/> for releases.

## Generating the RPM package

Edit the `Makefile` to ensure that you are setting the intended version, then run `make`.

```bash
make install-deps
make clean python27
make clean python33
make clean python34
make clean python35
make clean python36
```
