- [Surround Source Code with UUID for Transclusion](#org0b0e699)
  - [Before](#org6b81a2e)
  - [After](#orgcecbd94)
- [Top Level Project](#org3d5f9b4)
- [Example Project](#org28ab923)



<a id="org0b0e699"></a>

# Surround Source Code with UUID for Transclusion

Surround the currently selected code with comments containing UUIDs that work as an org-link to use for [nobiot's org-transclusion](https://github.com/nobiot/org-transclusion). The package provides two interactive functions &ndash; `uuid-surround-region-transclude` and `uuid-surround-region` . The former puts the org-transclude statement into the kill ring for pasting into your org document. The latter just puts the comments in place, if you have some other mechanism for constructing the ~#+transclude ~.

The comment style is based on the mode of the current buffer. The comment will be placed at the beginning of the line containing the current region. The ending comment will be placed on the line after the current region, unless the ending line is blank, as defined by the syntax for the buffer.


<a id="org6b81a2e"></a>

## Before

```C++
#include <print>

int main() {
  std::println("Hello, world!");
}
```


<a id="orgcecbd94"></a>

## After

```C++
#include <print>

// 129c5ac0-442e-4bd5-b25d-6df372c0a4b5
int main() {
  std::println("Hello, world!");
}
// 129c5ac0-442e-4bd5-b25d-6df372c0a4b5 end
```


<a id="org3d5f9b4"></a>

# Top Level Project

The overdone project infrastructure in the top-level project is to support GitHub CI and various bits of code quality. The CI is mostly driven by shell scripts in the .ci directory, which are borrowed from the [Exordium Project](https://github.com/emacs-exordium/exordium) and were written by [Przemysław Kryger](https://github.com/pkryger) who despaired of us breaking our shared emacs configuration. The [pre-commit framework](https://github.com/pre-commit/pre-commit) infrastructure is my fault, but helps me keep YAML less broken, and reduced the number of spelling mistakes and formatting errors. Running it automatically keeps me honest.

I have vendored in via `git subtree` the checkdoc code from pkryger as well.

More interesting may be the .minimal-emacs.d vendored in from [James Cherti's minimal emacs.d project.](https://github.com/jamescherti/minimal-emacs.d) This was of great use in making sure there was a lightweight but fully functional emacs configuration to run batch jobs from the command line, driven by a [Makefile](./Makefile).


<a id="org28ab923"></a>

# Example Project

This is the reason for the whole tiny bit of code.

I live in great fear of putting broken code up in a presentation.

I want to test it, somehow.

Using org-babel has turned out to be more cumbersome than I would like, so I was very happy to find org-transclude. I can make building my presentation dependent on the tests passing and extract the code snippets I want to show by marking up the actual compiled source. The project in the `example` directory is a complete C++ hello world project, and the results in example.md and example.html are output from org-export. The export can be run by `make presentation`, which builds and runs the project and runs the org export. Although the dependencies are not quite right, yet.

This project also has overdone infrastructure, largely borrowed from the [Beman Project](https://github.com/bemanproject), reusing the infra from [bemanproject/infra](https://github.com/bemanproject/infra) and [bemanproject/exemplar](https://github.com/bemanproject/exemplar).
