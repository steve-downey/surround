# Building Presentations with Emacs and Org-Transclusion

This example project uses [nobiot's org-transclusion](https://github.com/nobiot/org-transclusion) and org-export to produce an HTML file for use in presentations. This allows checking that the code is correct but also limited to what is useful.

The export can be run by `make presentation`, which builds and runs the tests for the project and runs the org export afterwards.

The `infra` directory is vendored in from the Beman Project via `git subtree`.

The makefile provides a variety of tools. It will install most borrowing from PyPI as long as `uv` is available. The installation is in a local `.venv` so as not to mess up the rest of your environment.

```shell
(example) sdowney@pwyll:~/src/surround/example (main ±)
$ make help
clean                          Clean the build artifacts
clean-venv                     Delete python virtual env
compile                        Compile the project
compile_commands.json          symlink the current compile commands db
compile-headers                Compile the headers
coverage                       Build and run the tests with the GCOV profile and process the results
ctest                          Run CTest on current build
.DEFAULT                       Other targets passed through to cmake
dev-shell                      Shell with the venv activated
docs                           Build the docs with Doxygen
help                           Show this help.
install                        Install the project
install-uv                     install uv via `pipx install uv`
lint                           Run all configured tools in pre-commit
lint-manual                    Run all manual tools in pre-commit
mrdocs                         Build the docs with Doxygen
realclean                      Delete the build directory
show-venv                      Debugging target - show venv details
test                           Rebuild and run tests
testinstall                    Test the installed package
venv                           Create python virtual env
view-coverage                  View the coverage report
```

`docs` and `mrdocs` are not included in the example at the moment.
