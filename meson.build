project('tomlc99',        # Declare a project 'tomlc99'...
  'c',                    # ... written in C
  version: '1.0',         # ... with version 1.0
  default_options: [      # ... using the default build options:
    'c_std=c99',          #     -std=c99
    'warning_level=3',    #     -Wall -Wextra -Wpedantic
  ]
)

# Build (and install) both static and shared libraries.
libtoml = both_libraries('toml', 'toml.c', install: true)

# Declare a dependecy for other projects to use.
libtoml_dep = declare_dependency(link_with: libtoml, include_directories: '.')

# Install 'toml.h' to '${prefix}/include/'
install_headers('toml.h')

# Build (but not install) toml_*.c
executable('toml_json',   'toml_json.c',    link_with: libtoml)
executable('toml_cat',    'toml_cat.c',     link_with: libtoml)
executable('toml_sample', 'toml_sample.c',  link_with: libtoml)

# Generate a pkg-config file.
pkg = import('pkgconfig')
pkg.generate(
  libraries: libtoml,
  name: 'libtoml',
  filebase: 'libtoml',
  description: 'TOML C library in c99.',
  url: 'https://github.com/cktan/tomlc99/',
)
